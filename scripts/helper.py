#!/usr/bin/env python3
import re
import sys
from pathlib import Path

SKIP_NAMES = {".DS_Store", ".gitkeep", "Thumbs.db"}

def existing_sources(device_mk: Path) -> set[str]:
    text = device_mk.read_text(errors="ignore")
    pattern = r"\$\(DEVICE_PATH\)/([^:\s]+):\$\(TARGET_COPY_OUT_RECOVERY\)"
    return set(re.findall(pattern, text))

def scan(tree_root: Path):
    root_dir = tree_root / "recovery" / "root"
    files, zero_byte = [], []
    for path in sorted(root_dir.rglob("*")):
        if path.is_dir() or path.is_symlink() or path.name in SKIP_NAMES:
            continue
        rel = path.relative_to(tree_root).as_posix()
        files.append(rel)
        if path.stat().st_size == 0:
            zero_byte.append(rel)
    return files, zero_byte

def main():
    if len(sys.argv) < 2:
        print("Usage: gen_copy_files.py <device_tree_root> [path/to/device.mk]", file=sys.stderr)
        sys.exit(1)

    tree_root = Path(sys.argv[1]).resolve()
    mk_path = Path(sys.argv[2]).resolve() if len(sys.argv) > 2 else tree_root / "device.mk"

    already = existing_sources(mk_path) if mk_path.exists() else set()
    all_files, zero_byte = scan(tree_root)
    new_files = [f for f in all_files if f not in already]

    if not new_files:
        print("# All files in recovery/root/ are listed in device.mk")
    else:
        print("PRODUCT_COPY_FILES += \\")
        for i, rel in enumerate(new_files):
            dst_rel = "/".join(rel.split("/")[1:])  # drop leading 'recovery/'
            src = f"$(DEVICE_PATH)/{rel}"
            dst = f"$(TARGET_COPY_OUT_RECOVERY)/{dst_rel}"
            suffix = " \\" if i < len(new_files) - 1 else ""
            print(f"    {src}:{dst}{suffix}")

    if zero_byte:
        print("\n# WARNING: still 0 bytes, fill it before building:")
        for rel in zero_byte:
            print(f"#   {rel}")

if __name__ == "__main__":
    main()