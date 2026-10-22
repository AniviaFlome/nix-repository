import sys

ORIG_URL = "https://github.com/dan0v/AmplitudeSoundboard/releases/latest/download/version.txt"
PREFIX = "https://127.0.0.1:9/nix-no-update-"
REPL_URL = PREFIX + "x" * (len(ORIG_URL) - len(PREFIX))
assert len(REPL_URL) == len(ORIG_URL), (len(REPL_URL), len(ORIG_URL))


def main() -> None:
    dll_path = sys.argv[1]
    orig_b = ORIG_URL.encode("utf-16-le")
    repl_b = REPL_URL.encode("utf-16-le")
    assert len(orig_b) == len(repl_b)

    with open(dll_path, "rb") as f:
        data = f.read()

    count = data.count(orig_b)
    if count == 0:
        print(f"warning: version-check URL not found in {dll_path}, skipping patch")
        return

    data = data.replace(orig_b, repl_b)

    with open(dll_path, "wb") as f:
        f.write(data)

    print(f"patched {count} occurrence(s) of version-check URL in {dll_path}")


if __name__ == "__main__":
    main()
