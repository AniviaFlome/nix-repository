import sys
import json
import subprocess

def main():
    targets = json.load(sys.stdin)
    for target in targets:
        name = target['name']
        extra_args = target.get('extraArgs', [])

        print(f'Updating {name}...')

        cmd = ['nix', 'shell', 'nixpkgs#nix-update', '-c', 'nix-update', '--flake', name]

        # Use package's custom updateScript if it has one
        if target.get('useUpdateScript', False):
            cmd.append('--use-update-script')

        cmd.extend(extra_args)
        subprocess.run(cmd, check=True)

if __name__ == '__main__':
    main()
