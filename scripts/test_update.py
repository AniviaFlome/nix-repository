import sys
import json
from unittest.mock import patch, MagicMock
from io import StringIO
import pytest
from update import main

def test_update_basic(monkeypatch):
    input_data = [{"name": "pkg1"}]
    mock_stdin = StringIO(json.dumps(input_data))
    monkeypatch.setattr("sys.stdin", mock_stdin)

    with patch("subprocess.run") as mock_run:
        main()
        mock_run.assert_called_once_with(
            ['nix', 'shell', 'nixpkgs#nix-update', '-c', 'nix-update', '--flake', 'pkg1'],
            check=True
        )

def test_update_with_extra_args(monkeypatch):
    input_data = [{"name": "pkg2", "extraArgs": ["--version=1.0.0"]}]
    mock_stdin = StringIO(json.dumps(input_data))
    monkeypatch.setattr("sys.stdin", mock_stdin)

    with patch("subprocess.run") as mock_run:
        main()
        mock_run.assert_called_once_with(
            ['nix', 'shell', 'nixpkgs#nix-update', '-c', 'nix-update', '--flake', 'pkg2', '--version=1.0.0'],
            check=True
        )

def test_update_with_update_script(monkeypatch):
    input_data = [{"name": "pkg3", "useUpdateScript": True}]
    mock_stdin = StringIO(json.dumps(input_data))
    monkeypatch.setattr("sys.stdin", mock_stdin)

    with patch("subprocess.run") as mock_run:
        main()
        mock_run.assert_called_once_with(
            ['nix', 'shell', 'nixpkgs#nix-update', '-c', 'nix-update', '--flake', 'pkg3', '--use-update-script'],
            check=True
        )

def test_update_with_both(monkeypatch):
    input_data = [{"name": "pkg4", "extraArgs": ["--build"], "useUpdateScript": True}]
    mock_stdin = StringIO(json.dumps(input_data))
    monkeypatch.setattr("sys.stdin", mock_stdin)

    with patch("subprocess.run") as mock_run:
        main()
        mock_run.assert_called_once_with(
            ['nix', 'shell', 'nixpkgs#nix-update', '-c', 'nix-update', '--flake', 'pkg4', '--use-update-script', '--build'],
            check=True
        )

def test_update_multiple_packages(monkeypatch):
    input_data = [
        {"name": "pkg5"},
        {"name": "pkg6", "useUpdateScript": True}
    ]
    mock_stdin = StringIO(json.dumps(input_data))
    monkeypatch.setattr("sys.stdin", mock_stdin)

    with patch("subprocess.run") as mock_run:
        main()
        assert mock_run.call_count == 2
        mock_run.assert_any_call(
            ['nix', 'shell', 'nixpkgs#nix-update', '-c', 'nix-update', '--flake', 'pkg5'],
            check=True
        )
        mock_run.assert_any_call(
            ['nix', 'shell', 'nixpkgs#nix-update', '-c', 'nix-update', '--flake', 'pkg6', '--use-update-script'],
            check=True
        )
