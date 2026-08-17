import json
import sys
from unittest.mock import patch, MagicMock
from update import main

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
    """With --build, unfree packages are updated without --build (pure flake eval disallows it)."""
    input_data = [
        {"name": "pkg-free", "unfree": False},
        {"name": "pkg-unfree", "unfree": True}
    ]
    with patch("subprocess.run") as mock_run:
        mock_run.side_effect = create_mock_run(input_data)
        run_main_with_argv(["update.py", "--build"])
        # Free package gets --build
        mock_run.assert_any_call(
            ['nix', 'shell', 'nixpkgs#nix-update', '-c', 'nix-update', '--flake', 'pkg-free', '--build'],
            check=True
        )
        # Unfree package does NOT get --build
        mock_run.assert_any_call(
            ['nix', 'shell', 'nixpkgs#nix-update', '-c', 'nix-update', '--flake', 'pkg-unfree'],
            check=True
        )
        for call in mock_run.call_args_list:
            if 'pkg-unfree' in call.args[0]:
                assert '--build' not in call.args[0], "unfree package should not get --build"
