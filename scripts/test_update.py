import argparse
import json
import os
import subprocess
import sys
from unittest.mock import MagicMock, patch

import pytest

from update import main, nix_build_cmd, nix_update_cmd, prs_allowed


def create_mock_run(input_data, fail_on_cmds=None, fail_build_on=None, status_seq=None):
    """Helper to mock subprocess.run for nix eval, git status, nix-update, and nix build."""
    fail_on_cmds = fail_on_cmds or set()
    fail_build_on = fail_build_on or set()
    status_iter = iter(status_seq) if status_seq is not None else None

    def mock_run(cmd, *args, **kwargs):
        mock_result = MagicMock()
        if "--json" in cmd:
            mock_result.stdout = json.dumps(input_data)
            return mock_result
        if cmd[:2] == ["git", "status"]:
            if status_iter is not None:
                mock_result.stdout = next(status_iter, "")
            else:
                mock_result.stdout = ""
            return mock_result
        for target_name in fail_on_cmds:
            if target_name in cmd and "nix-update" in " ".join(cmd):
                raise subprocess.CalledProcessError(1, cmd)
        for target_name in fail_build_on:
            if cmd[:2] == ["nix", "build"] and target_name in cmd:
                raise subprocess.CalledProcessError(1, cmd)
        mock_result.stdout = ""
        return mock_result

    return mock_run


def run_main_with_argv(argv, nix_update_bin="/usr/bin/nix-update"):
    """Run main() with a given sys.argv and mocked shutil.which, restoring argv."""
    old_argv = sys.argv
    sys.argv = argv
    try:
        with patch("shutil.which", return_value=nix_update_bin):
            main()
    finally:
        sys.argv = old_argv


def test_nix_update_cmd_uses_direct_binary_when_on_path():
    with patch("shutil.which", return_value="/nix/store/xxx/bin/nix-update"):
        cmd = nix_update_cmd({"name": "pkg1", "hasUpdateScript": True})
    assert cmd == ["nix-update", "pkg1", "--use-update-script"]


def test_nix_update_cmd_falls_back_to_nix_shell():
    with patch("shutil.which", return_value=None):
        cmd = nix_update_cmd({"name": "pkg1", "hasUpdateScript": True})
    assert cmd == [
        "nix",
        "shell",
        "nixpkgs#nix-update",
        "-c",
        "nix-update",
        "pkg1",
        "--use-update-script",
    ]


def test_nix_build_cmd():
    assert nix_build_cmd("mpvScripts.pkg7") == [
        "nix",
        "build",
        "--no-link",
        "-L",
        "-f",
        ".",
        "mpvScripts.pkg7",
    ]


def test_update_basic_file_mode():
    input_data = [{"name": "pkg1"}]
    with patch("subprocess.run") as mock_run:
        mock_run.side_effect = create_mock_run(input_data)
        run_main_with_argv(["update.py"])
        mock_run.assert_any_call(["nix-update", "pkg1"], check=True)
        for call in mock_run.call_args_list:
            assert "--flake" not in call.args[0]


def test_update_with_update_script():
    input_data = [{"name": "pkg3", "hasUpdateScript": True}]
    with patch("subprocess.run") as mock_run:
        mock_run.side_effect = create_mock_run(input_data)
        run_main_with_argv(["update.py"])
        mock_run.assert_any_call(["nix-update", "pkg3", "--use-update-script"], check=True)


def test_update_skips_targets_without_update_script():
    input_data = [
        {"name": "adore", "hasUpdateScript": False},
        {"name": "pkg-ok", "hasUpdateScript": True},
    ]
    with patch("subprocess.run") as mock_run:
        mock_run.side_effect = create_mock_run(input_data)
        run_main_with_argv(["update.py"])
        for call in mock_run.call_args_list:
            assert "adore" not in call.args[0]
        mock_run.assert_any_call(["nix-update", "pkg-ok", "--use-update-script"], check=True)


def test_update_multiple_packages_and_build_only_when_changed():
    input_data = [
        {"name": "pkg5", "hasUpdateScript": True},
        {"name": "pkg6", "hasUpdateScript": False},
        {"name": "mpvScripts.pkg7", "hasUpdateScript": True},
    ]
    # pkg5 changes a file (should trigger nix build); pkg7 has no changes (should skip nix build).
    status_seq = [
        "",
        " M pkgs/pkg5/default.nix\n",
        " M pkgs/pkg5/default.nix\n",
        " M pkgs/pkg5/default.nix\n",
    ]
    with patch("subprocess.run") as mock_run:
        mock_run.side_effect = create_mock_run(input_data, status_seq=status_seq)
        run_main_with_argv(["update.py", "--build"])
        # 1 eval + pkg5 (before, nix-update, after, nix build) + pkg7 (before, nix-update, after) = 8
        assert mock_run.call_count == 8
        mock_run.assert_any_call(["nix-update", "pkg5", "--use-update-script"], check=True)
        mock_run.assert_any_call(nix_build_cmd("pkg5"), check=True)
        mock_run.assert_any_call(["nix-update", "mpvScripts.pkg7", "--use-update-script"], check=True)
        for call in mock_run.call_args_list:
            assert call.args[0] != nix_build_cmd("mpvScripts.pkg7")


def test_failed_build_rolls_back_changed_package():
    input_data = [{"name": "pkg-broken", "hasUpdateScript": True}]
    status_seq = [
        "",
        " M pkgs/pkg-broken/default.nix\n",
        " M pkgs/pkg-broken/default.nix\n",
    ]
    with patch("subprocess.run") as mock_run:
        mock_run.side_effect = create_mock_run(
            input_data,
            fail_build_on={"pkg-broken"},
            status_seq=status_seq,
        )
        with pytest.raises(SystemExit) as exc:
            run_main_with_argv(["update.py", "--build"])
        assert exc.value.code == 1
        mock_run.assert_any_call(nix_build_cmd("pkg-broken"), check=True)
        mock_run.assert_any_call(
            ["git", "checkout", "--", "pkgs/pkg-broken/default.nix"],
            check=True,
        )


def test_update_without_build_flag():
    input_data = [{"name": "pkg9", "hasUpdateScript": True}]
    status_seq = ["", " M pkgs/pkg9/default.nix\n"]
    with patch("subprocess.run") as mock_run:
        mock_run.side_effect = create_mock_run(input_data, status_seq=status_seq)
        run_main_with_argv(["update.py"])
        mock_run.assert_any_call(["nix-update", "pkg9", "--use-update-script"], check=True)
        for call in mock_run.call_args_list:
            assert call.args[0][:2] != ["nix", "build"]


def test_failed_update_rolls_back_only_new_dirty_files_and_exits_nonzero(tmp_path):
    summary = tmp_path / "summary.md"
    input_data = [
        {"name": "pkg-ok", "hasUpdateScript": True},
        {"name": "pkg-fail", "hasUpdateScript": True},
    ]
    # Sequence of `git status --porcelain` calls:
    # 1. before pkg-ok: clean
    # 2. after pkg-ok: pkg-ok dirty
    # 3. before pkg-fail: pkg-ok dirty
    # 4. after pkg-fail failed: pkg-ok + pkg-fail dirty
    status_seq = [
        "",
        " M pkgs/pkg-ok/default.nix\n",
        " M pkgs/pkg-ok/default.nix\n",
        " M pkgs/pkg-ok/default.nix\n M pkgs/pkg-fail/default.nix\n",
    ]
    old_summary = os.environ.get("GITHUB_STEP_SUMMARY")
    os.environ["GITHUB_STEP_SUMMARY"] = str(summary)
    try:
        with patch("subprocess.run") as mock_run:
            mock_run.side_effect = create_mock_run(
                input_data,
                fail_on_cmds={"pkg-fail"},
                status_seq=status_seq,
            )
            with pytest.raises(SystemExit) as exc:
                run_main_with_argv(["update.py", "--build"])
            assert exc.value.code == 1

            mock_run.assert_any_call(
                ["git", "checkout", "--", "pkgs/pkg-fail/default.nix"],
                check=True,
            )
            for call in mock_run.call_args_list:
                assert call.args[0] != ["git", "checkout", "--", "pkgs/pkg-ok/default.nix"]
    finally:
        if old_summary is None:
            os.environ.pop("GITHUB_STEP_SUMMARY", None)
        else:
            os.environ["GITHUB_STEP_SUMMARY"] = old_summary

    text = summary.read_text(encoding="utf-8")
    assert "`pkg-ok`" in text
    assert "`pkg-fail`" in text


def run_main_with_env(argv, env):
    """Run main() with a given sys.argv and os.environ patch, restoring both."""
    old_argv = sys.argv
    old_env = os.environ.get("GITHUB_ACTIONS")
    if env is None:
        os.environ.pop("GITHUB_ACTIONS", None)
    else:
        os.environ["GITHUB_ACTIONS"] = env
    sys.argv = argv
    try:
        with patch("shutil.which", return_value="/usr/bin/nix-update"):
            main()
    finally:
        sys.argv = old_argv
        if old_env is None:
            os.environ.pop("GITHUB_ACTIONS", None)
        else:
            os.environ["GITHUB_ACTIONS"] = old_env


def test_open_prs_refused_outside_ci():
    """--open-prs outside CI must not touch git/gh: PRs would be user-authored."""
    input_data = [{"name": "pkg-pr", "hasUpdateScript": True, "prReview": True}]
    with patch("subprocess.run") as mock_run:
        mock_run.side_effect = create_mock_run(input_data)
        run_main_with_env(["update.py", "--open-prs"], None)
        # Only the 1 nix-eval call for get_targets; no checkout/nix-update/gh.
        assert mock_run.call_count == 1
        for call in mock_run.call_args_list:
            assert "checkout" not in call.args[0]
            assert "nix-update" not in str(call.args[0])


def test_open_prs_allowed_with_override():
    """--open-prs --allow-local-prs reaches the per-target PR updater."""
    input_data = [{"name": "pkg-pr", "hasUpdateScript": True, "prReview": True}]
    with (
        patch("subprocess.run") as mock_run,
        patch("update.update_pr_review_target", return_value=False) as mock_pr,
    ):
        mock_run.side_effect = create_mock_run(input_data)
        run_main_with_env(["update.py", "--open-prs", "--allow-local-prs"], None)
        mock_pr.assert_called_once()


def test_prs_allowed_helper():
    """prs_allowed: CI or explicit override, and only with --open-prs."""

    def ns(open_prs, allow=False):
        return argparse.Namespace(open_prs=open_prs, allow_local_prs=allow)

    old = os.environ.get("GITHUB_ACTIONS")
    try:
        os.environ.pop("GITHUB_ACTIONS", None)
        assert prs_allowed(ns(True)) is False
        assert prs_allowed(ns(True, allow=True)) is True
        assert prs_allowed(ns(False, allow=True)) is False
        os.environ["GITHUB_ACTIONS"] = "true"
        assert prs_allowed(ns(True)) is True
    finally:
        if old is None:
            os.environ.pop("GITHUB_ACTIONS", None)
        else:
            os.environ["GITHUB_ACTIONS"] = old
