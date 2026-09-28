import json
import os
import sys
from unittest.mock import patch, MagicMock
from update import main, prs_allowed

def create_mock_run(input_data):
    """Helper to mock subprocess.run for nix eval and shell commands."""
    def mock_run(cmd, *args, **kwargs):
        mock_result = MagicMock()
        if 'builtins.currentSystem' in cmd:
            mock_result.stdout = "x86_64-linux\n"
        elif '--json' in cmd:
            mock_result.stdout = json.dumps(input_data)
        return mock_result
    return mock_run

def run_main_with_argv(argv):
    """Run main() with a given sys.argv, restoring it afterwards."""
    old_argv = sys.argv
    sys.argv = argv
    try:
        main()
    finally:
        sys.argv = old_argv

def test_update_basic():
    input_data = [{"name": "pkg1"}]
    with patch("subprocess.run") as mock_run:
        mock_run.side_effect = create_mock_run(input_data)
        run_main_with_argv(["update.py"])
        mock_run.assert_any_call(
            ['nix', 'shell', 'nixpkgs#nix-update', '-c', 'nix-update', '--flake', 'pkg1'],
            check=True
        )

def test_update_with_extra_args():
    input_data = [{"name": "pkg2", "extraArgs": ["--version=1.0.0"]}]
    with patch("subprocess.run") as mock_run:
        mock_run.side_effect = create_mock_run(input_data)
        run_main_with_argv(["update.py"])
        mock_run.assert_any_call(
            ['nix', 'shell', 'nixpkgs#nix-update', '-c', 'nix-update', '--flake', 'pkg2', '--version=1.0.0'],
            check=True
        )

def test_update_with_update_script():
    input_data = [{"name": "pkg3", "useUpdateScript": True}]
    with patch("subprocess.run") as mock_run:
        mock_run.side_effect = create_mock_run(input_data)
        run_main_with_argv(["update.py"])
        mock_run.assert_any_call(
            ['nix', 'shell', 'nixpkgs#nix-update', '-c', 'nix-update', '--flake', 'pkg3', '--use-update-script'],
            check=True
        )

def test_update_with_both():
    input_data = [{"name": "pkg4", "extraArgs": ["--build"], "useUpdateScript": True}]
    with patch("subprocess.run") as mock_run:
        mock_run.side_effect = create_mock_run(input_data)
        run_main_with_argv(["update.py"])
        mock_run.assert_any_call(
            ['nix', 'shell', 'nixpkgs#nix-update', '-c', 'nix-update', '--flake', 'pkg4', '--use-update-script', '--build'],
            check=True
        )

def test_update_multiple_packages():
    input_data = [
        {"name": "pkg5"},
        {"name": "pkg6", "useUpdateScript": True}
    ]
    with patch("subprocess.run") as mock_run:
        mock_run.side_effect = create_mock_run(input_data)
        run_main_with_argv(["update.py"])
        assert mock_run.call_count == 4 # 2 eval calls + 2 shell calls
        mock_run.assert_any_call(
            ['nix', 'shell', 'nixpkgs#nix-update', '-c', 'nix-update', '--flake', 'pkg5'],
            check=True
        )
        mock_run.assert_any_call(
            ['nix', 'shell', 'nixpkgs#nix-update', '-c', 'nix-update', '--flake', 'pkg6', '--use-update-script'],
            check=True
        )

def test_update_with_build_flag():
    """When --build is passed to update.py, nix-update gets --build appended."""
    input_data = [
        {"name": "pkg7"},
        {"name": "pkg8", "useUpdateScript": True, "extraArgs": ["--version=branch"]}
    ]
    with patch("subprocess.run") as mock_run:
        mock_run.side_effect = create_mock_run(input_data)
        run_main_with_argv(["update.py", "--build"])
        mock_run.assert_any_call(
            ['nix', 'shell', 'nixpkgs#nix-update', '-c', 'nix-update', '--flake', 'pkg7', '--build'],
            check=True
        )
        mock_run.assert_any_call(
            ['nix', 'shell', 'nixpkgs#nix-update', '-c', 'nix-update', '--flake', 'pkg8', '--use-update-script', '--build', '--version=branch'],
            check=True
        )

def test_update_without_build_flag():
    """Without --build, nix-update does NOT get --build (backward compat)."""
    input_data = [{"name": "pkg9"}]
    with patch("subprocess.run") as mock_run:
        mock_run.side_effect = create_mock_run(input_data)
        run_main_with_argv(["update.py"])
        mock_run.assert_any_call(
            ['nix', 'shell', 'nixpkgs#nix-update', '-c', 'nix-update', '--flake', 'pkg9'],
            check=True
        )
        # Ensure --build was NOT added
        for call in mock_run.call_args_list:
            assert '--build' not in call.args[0], "nix-update should not get --build without the flag"

def test_update_build_skipped_for_unfree():
    """With --build, unfree packages use --file mode (impure, honors NIXPKGS_ALLOW_UNFREE) instead of --flake (pure, disallows it). Both get --build."""
    input_data = [
        {"name": "pkg-free", "unfree": False},
        {"name": "pkg-unfree", "unfree": True}
    ]
    with patch("subprocess.run") as mock_run:
        mock_run.side_effect = create_mock_run(input_data)
        run_main_with_argv(["update.py", "--build"])
        # Free package uses --flake with --build
        mock_run.assert_any_call(
            ['nix', 'shell', 'nixpkgs#nix-update', '-c', 'nix-update', '--flake', 'pkg-free', '--build'],
            check=True
        )
        # Unfree package omits --flake (uses default.nix via --file) with --build
        mock_run.assert_any_call(
            ['nix', 'shell', 'nixpkgs#nix-update', '-c', 'nix-update', 'pkg-unfree', '--build'],
            check=True
        )
        # Unfree package must NOT use --flake
        for call in mock_run.call_args_list:
            if 'pkg-unfree' in call.args[0]:
                assert '--flake' not in call.args[0], "unfree package should not use --flake with --build"

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
        main()
    finally:
        sys.argv = old_argv
        if old_env is None:
            os.environ.pop("GITHUB_ACTIONS", None)
        else:
            os.environ["GITHUB_ACTIONS"] = old_env

def test_open_prs_refused_outside_ci():
    """--open-prs outside CI must not touch git/gh: PRs would be user-authored."""
    input_data = [{"name": "pkg-pr", "prReview": True}]
    with patch("subprocess.run") as mock_run:
        mock_run.side_effect = create_mock_run(input_data)
        run_main_with_env(["update.py", "--open-prs"], None)
        # Only the 2 nix-eval calls for get_targets; no checkout/nix-update/gh.
        assert mock_run.call_count == 2
        for call in mock_run.call_args_list:
            assert "checkout" not in call.args[0]
            assert "nix-update" not in str(call.args[0])

def test_open_prs_allowed_with_override():
    """--open-prs --allow-local-prs reaches the per-target PR updater."""
    input_data = [{"name": "pkg-pr", "prReview": True}]
    with (
        patch("subprocess.run") as mock_run,
        patch("update.update_pr_review_target") as mock_pr,
    ):
        mock_run.side_effect = create_mock_run(input_data)
        run_main_with_env(["update.py", "--open-prs", "--allow-local-prs"], None)
        mock_pr.assert_called_once()

def test_prs_allowed_helper():
    """prs_allowed: CI or explicit override, and only with --open-prs."""
    import argparse

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
