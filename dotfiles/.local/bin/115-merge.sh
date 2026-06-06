#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Usage: $(basename "$0") [--batch | -b] [input_dir] [output_file]

Merge 115 cloud drive segmented video files into a single MP4.

Arguments:
  --batch, -b  Batch mode: traverse subdirectories and merge all found videos
  input_dir    Directory containing .m3u8 and ts_* files (default: .)
  output_file  Output MP4 path (default: <input_name>_merged.mp4 next to m3u8)

Examples:
  115-merge
  115-merge --batch /path/to/download/dir
  115-merge /path/to/download/dir
  115-merge /path/to/download/dir /path/to/output.mp4
EOF
  exit 0
}

# --- Parse args ---
[[ "${1:-}" == "-h" || "${1:-}" == "--help" ]] && usage

batch_mode=false
if [[ "${1:-}" == "--batch" || "${1:-}" == "-b" ]]; then
  batch_mode=true
  shift
fi

input_dir="${1:-.}"
input_dir="${input_dir%/}"
output_path="${2:-}"

# ---------- Merge one video ----------
# Usage: merge_one <dir_with_m3u8> [parent_dir]
#   parent_dir set  -> output placed in parent_dir (batch mode)
#   parent_dir unset -> output placed next to m3u8 (single mode)
merge_one() {
  local input_dir="$1"
  local parent_dir="${2:-}"

  local m3u8
  m3u8=$(find "$input_dir" -maxdepth 1 -name '*.m3u8' 2>/dev/null | head -1)
  if [[ -z "$m3u8" ]]; then
    echo "Error: No .m3u8 file found in '$input_dir'" >&2
    return 1
  fi

  local output
  if [[ -n "$parent_dir" ]]; then
    local m3u8_name
    m3u8_name=$(basename "$m3u8" .m3u8)
    output="$parent_dir/${m3u8_name}_merged.mp4"
    if [[ -f "$output" ]]; then
      echo "Skipped (exists): $output"
      return 0
    fi
  else
    if [[ -z "$output_path" ]]; then
      output="${m3u8%.m3u8}_merged.mp4"
    else
      output="$output_path"
      [[ "$output" != /* ]] && output="$PWD/$output"
    fi
  fi

  local m3u8_dir
  m3u8_dir=$(dirname "$(realpath "$m3u8")")
  local m3u8_base
  m3u8_base=$(basename "$m3u8")

  echo "Merging: $m3u8_base"
  echo "Output:  $output"

  local tmpdir
  tmpdir=$(mktemp -d)
  local concat_list="$tmpdir/concat.txt"

  while IFS= read -r line; do
    line="${line#"${line%%[![:space:]]*}"}"
    line="${line%"${line##*[![:space:]]}"}"
    if [[ -n "$line" && "$line" != \#* ]]; then
      echo "file '$m3u8_dir/$line'" >> "$concat_list"
    fi
  done < "$m3u8"

  if [[ ! -s "$concat_list" ]]; then
    echo "Error: No segment files found in m3u8" >&2
    rm -rf "$tmpdir"
    return 1
  fi

  local segment_count
  segment_count=$(wc -l < "$concat_list")
  echo "Segments: $segment_count"

  ffmpeg -f concat -safe 0 -i "$concat_list" -c copy -y "$output" -stats
  rm -rf "$tmpdir"
  echo "Done!"
}

# ---------- Batch mode ----------
if [[ "$batch_mode" == true ]]; then
  for subdir in "$input_dir"/*/; do
    [[ -d "$subdir" ]] || continue
    m3u8_candidate=$(find "$subdir" -maxdepth 1 -name '*.m3u8' 2>/dev/null | head -1)
    [[ -n "$m3u8_candidate" ]] || continue
    merge_one "$subdir" "$input_dir" || echo "  Failed: $subdir" >&2
  done
else
  merge_one "$input_dir" ""
fi
