import json
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

def test_update_basic():
    input_data = [{"name": "pkg1"}]
    with patch("subprocess.run") as mock_run:
        mock_run.side_effect = create_mock_run(input_data)
        main()
        mock_run.assert_any_call(
            ['nix', 'shell', 'nixpkgs#nix-update', '-c', 'nix-update', '--flake', 'pkg1'],
            check=True
        )

def test_update_with_extra_args():
    input_data = [{"name": "pkg2", "extraArgs": ["--version=1.0.0"]}]
    with patch("subprocess.run") as mock_run:
        mock_run.side_effect = create_mock_run(input_data)
        main()
        mock_run.assert_any_call(
            ['nix', 'shell', 'nixpkgs#nix-update', '-c', 'nix-update', '--flake', 'pkg2', '--version=1.0.0'],
            check=True
        )

def test_update_with_update_script():
    input_data = [{"name": "pkg3", "useUpdateScript": True}]
    with patch("subprocess.run") as mock_run:
        mock_run.side_effect = create_mock_run(input_data)
        main()
        mock_run.assert_any_call(
            ['nix', 'shell', 'nixpkgs#nix-update', '-c', 'nix-update', '--flake', 'pkg3', '--use-update-script'],
            check=True
        )

def test_update_with_both():
    input_data = [{"name": "pkg4", "extraArgs": ["--build"], "useUpdateScript": True}]
    with patch("subprocess.run") as mock_run:
        mock_run.side_effect = create_mock_run(input_data)
        main()
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
        main()
        assert mock_run.call_count == 4 # 2 eval calls + 2 shell calls
        mock_run.assert_any_call(
            ['nix', 'shell', 'nixpkgs#nix-update', '-c', 'nix-update', '--flake', 'pkg5'],
            check=True
        )
        mock_run.assert_any_call(
            ['nix', 'shell', 'nixpkgs#nix-update', '-c', 'nix-update', '--flake', 'pkg6', '--use-update-script'],
            check=True
        )
