#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Usage: $(basename "$0") [input_dir] [output_file]

Merge 115 cloud drive segmented video files into a single MP4.

Arguments:
  input_dir    Directory containing .m3u8 and ts_* files (default: .)
  output_file  Output MP4 path (default: <input_name>_merged.mp4 next to m3u8)

Examples:
  115-merge
  115-merge /path/to/download/dir
  115-merge /path/to/download/dir /path/to/output.mp4
EOF
  exit 0
}

# --- Parse args ---
[[ "${1:-}" == "-h" || "${1:-}" == "--help" ]] && usage

input_dir="${1:-.}"
input_dir="${input_dir%/}"
output="${2:-}"

# --- Find .m3u8 file ---
m3u8=$(find "$input_dir" -maxdepth 1 -name '*.m3u8' 2>/dev/null | head -1)
if [[ -z "$m3u8" ]]; then
  echo "Error: No .m3u8 file found in '$input_dir'" >&2
  exit 1
fi

# --- Determine output path ---
if [[ -z "$output" ]]; then
  output="${m3u8%.m3u8}_merged.mp4"
else
  [[ "$output" != /* ]] && output="$PWD/$output"
fi

# --- Resolve m3u8 and input_dir to absolute paths ---
m3u8_dir=$(dirname "$(realpath "$m3u8")")
m3u8_base=$(basename "$m3u8")

echo "Merging: $m3u8_base"
echo "Output:  $output"

# --- Create concat file list from m3u8 ---
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
concat_list="$tmpdir/concat.txt"

# Extract segment files from m3u8 (skip comment lines, skip empty lines)
while IFS= read -r line; do
  line="${line#"${line%%[![:space:]]*}"}"  # trim leading whitespace
  line="${line%"${line##*[![:space:]]}"}"  # trim trailing whitespace
  if [[ -n "$line" && "$line" != \#* ]]; then
    echo "file '$m3u8_dir/$line'" >> "$concat_list"
  fi
done < "$m3u8"

if [[ ! -s "$concat_list" ]]; then
  echo "Error: No segment files found in m3u8" >&2
  exit 1
fi

segment_count=$(wc -l < "$concat_list")
echo "Segments: $segment_count"

# --- Merge ---
ffmpeg -f concat -safe 0 -i "$concat_list" -c copy -y "$output" -stats

echo "Done!"
