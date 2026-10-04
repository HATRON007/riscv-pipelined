#!/usr/bin/env python3
"""
verilog_to_txt.py
Converts Verilog/SystemVerilog source files (.v, .sv, .vh) to .txt.
Supports individual mirroring and merged single-file output.
"""

import argparse
import sys
from pathlib import Path

VALID_EXTENSIONS = {".v", ".sv", ".vh"}


def find_files(src_dir: Path, recursive: bool = True):
    """Find all Verilog/SystemVerilog files in the source directory."""
    matcher = src_dir.rglob("*") if recursive else src_dir.glob("*")
    return [
        p for p in matcher if p.is_file() and p.suffix.lower() in VALID_EXTENSIONS
    ]


def convert_mirror(files, src_dir: Path, out_dir: Path, overwrite: bool):
    """Convert each file to an individual .txt file, preserving folder hierarchy."""
    out_dir.mkdir(parents=True, exist_ok=True)
    converted, skipped, errors = 0, 0, 0

    for file_path in files:
        rel_path = file_path.relative_to(src_dir)
        target_path = (out_dir / rel_path).with_suffix(".txt")

        if target_path.exists() and not overwrite:
            print(f"[SKIP] Already exists: {target_path}")
            skipped += 1
            continue

        try:
            target_path.parent.mkdir(parents=True, exist_ok=True)
            content = file_path.read_text(encoding="utf-8", errors="replace")
            target_path.write_text(content, encoding="utf-8")
            print(f"[OK]   {rel_path} -> {target_path.name}")
            converted += 1
        except Exception as e:
            print(f"[ERR]  Failed to process {rel_path}: {e}", file=sys.stderr)
            errors += 1

    return converted, skipped, errors


def convert_merge(files, src_dir: Path, out_file: Path, overwrite: bool):
    """Merge all files into a single .txt file with clear separators."""
    if out_file.exists() and not overwrite:
        print(f"[SKIP] Target merged file already exists: {out_file}")
        return 0, len(files), 0

    out_file.parent.mkdir(parents=True, exist_ok=True)
    converted, errors = 0, 0

    try:
        with out_file.open("w", encoding="utf-8") as outfile:
            for file_path in files:
                rel_path = file_path.relative_to(src_dir)
                try:
                    content = file_path.read_text(
                        encoding="utf-8", errors="replace"
                    )
                    outfile.write(f"\n{'=' * 70}\n")
                    outfile.write(f"FILE: {rel_path.as_posix()}\n")
                    outfile.write(f"{'=' * 70}\n\n")
                    outfile.write(content)
                    outfile.write("\n")
                    print(f"[MERGED] {rel_path}")
                    converted += 1
                except Exception as e:
                    print(
                        f"[ERR]    Failed to read {rel_path}: {e}",
                        file=sys.stderr,
                    )
                    errors += 1

        print(f"\nSuccessfully wrote merged archive to: {out_file.resolve()}")
    except Exception as e:
        print(f"[FATAL] Could not open output file {out_file}: {e}", file=sys.stderr)
        return 0, 0, len(files)

    return converted, 0, errors


def main():
    parser = argparse.ArgumentParser(
        description="Convert .v, .sv, and .vh files to .txt"
    )
    parser.add_argument(
        "-i",
        "--input",
        type=Path,
        default=Path("."),
        help="Input folder containing Verilog files (default: current directory)",
    )
    parser.add_argument(
        "-o",
        "--output",
        type=Path,
        default=None,
        help="Output folder (or output file path if using --merge)",
    )
    parser.add_argument(
        "-m",
        "--merge",
        action="store_true",
        help="Combine all found files into a single .txt file",
    )
    parser.add_argument(
        "--no-recursive",
        action="store_true",
        help="Do not scan subfolders (top-level only)",
    )
    parser.add_argument(
        "--overwrite",
        action="store_true",
        help="Overwrite existing files without prompting",
    )

    args = parser.parse_args()
    src_dir = args.input.resolve()

    if not src_dir.is_dir():
        print(f"Error: Input path '{src_dir}' is not a directory.", file=sys.stderr)
        sys.exit(1)

    # Collect source files
    files = sorted(find_files(src_dir, recursive=not args.no_recursive))
    if not files:
        print(f"No .v, .sv, or .vh files found in: {src_dir}")
        sys.exit(0)

    print(f"Found {len(files)} Verilog file(s) in '{src_dir}'.\n")

    if args.merge:
        # If output is not specified or is an existing directory, name the file automatically
        if args.output is None:
            out_file = src_dir / "verilog_merged.txt"
        elif args.output.is_dir():
            out_file = args.output / "verilog_merged.txt"
        else:
            out_file = args.output.with_suffix(".txt")

        converted, skipped, errors = convert_merge(
            files, src_dir, out_file, args.overwrite
        )
    else:
        out_dir = args.output.resolve() if args.output else src_dir / "txt_output"
        converted, skipped, errors = convert_mirror(
            files, src_dir, out_dir, args.overwrite
        )

    # Summary
    print(f"\nDone: {converted} converted, {skipped} skipped, {errors} errors.")


if __name__ == "__main__":
    main()

# python verilog_to_txt.py -i ./my_rtl_project -o ./txt_output (convert all individual files to a new folder)
# python verilog_to_txt.py -i ./my_rtl_project -m -o ./full_context.txt (for merging all files into a single .txt file)