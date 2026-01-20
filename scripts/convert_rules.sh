#!/usr/bin/env bash
set -euo pipefail

# Subconverter service endpoint (Docker image should be serving this URL).
BASE_URL="${SUBCONVERTER_URL:-https://wizardly_mclaren.orb.local/sub}"

# Output root folder.
OUT_DIR="${OUT_DIR:-./output}"

# Input files (local paths).
INPUTS=(
  "/Volumes/Data/Github/SyncnextProjects/SyncnextClash/proxy-classical.yaml"
  "/Volumes/Data/Github/SyncnextProjects/SyncnextClash/Unbreak-classical.yaml"
)

# Supported targets from subconverter README.
TARGETS=(
  "clash"
  "clashr"
  "quan"
  "quanx"
  "loon"
  "ss"
  "sssub"
  "ssd"
  "ssr"
  "surfboard"
  "surge&ver=2"
  "surge&ver=3"
  "surge&ver=4"
  "v2ray"
)

# Optional path remapping for containerized services.
# Example: PATH_PREFIX_FROM="/Volumes/Data/Github/SyncnextProjects/SyncnextClash" \
#          PATH_PREFIX_TO="/data"  (if the container mounts repo at /data)
PATH_PREFIX_FROM="${PATH_PREFIX_FROM:-}"
PATH_PREFIX_TO="${PATH_PREFIX_TO:-}"

urlencode() {
  python3 - <<'PY' "$1"
import sys, urllib.parse
print(urllib.parse.quote(sys.argv[1], safe=""))
PY
}

map_path() {
  local path="$1"
  if [[ -n "${PATH_PREFIX_FROM}" || -n "${PATH_PREFIX_TO}" ]]; then
    if [[ -z "${PATH_PREFIX_FROM}" || -z "${PATH_PREFIX_TO}" ]]; then
      echo "PATH_PREFIX_FROM and PATH_PREFIX_TO must both be set" >&2
      exit 1
    fi
    if [[ "${path}" != "${PATH_PREFIX_FROM}"* ]]; then
      echo "Input path does not start with PATH_PREFIX_FROM: ${path}" >&2
      exit 1
    fi
    echo "${PATH_PREFIX_TO}${path#${PATH_PREFIX_FROM}}"
    return
  fi
  echo "${path}"
}

build_target_query() {
  local target="$1"
  if [[ "${target}" == surge\&ver=* ]]; then
    echo "target=surge&ver=${target#*ver=}"
  else
    echo "target=${target}"
  fi
}

fetch_one() {
  local input_path="$1"
  local input_base
  input_base="$(basename "${input_path}")"
  input_base="${input_base%.*}"

  local mapped_path
  mapped_path="$(map_path "${input_path}")"

  local encoded_url
  encoded_url="$(urlencode "${mapped_path}")"

  local input_out_dir="${OUT_DIR}/${input_base}"
  mkdir -p "${input_out_dir}"

  local target
  for target in "${TARGETS[@]}"; do
    local target_query
    target_query="$(build_target_query "${target}")"

    local target_slug
    target_slug="${target//&/-}"
    target_slug="${target_slug//=/-}"

    local out_file="${input_out_dir}/${target_slug}.txt"
    local request_url="${BASE_URL}?${target_query}&url=${encoded_url}"

    echo "[request] input=${input_base} target=${target} output=${out_file}"
    echo "[request] url=${request_url}"
    curl -fsS "${request_url}" -o "${out_file}"
  done
}

main() {
  echo "[start] subconverter=${BASE_URL}"
  echo "[start] output_dir=${OUT_DIR}"
  if [[ -n "${PATH_PREFIX_FROM}" || -n "${PATH_PREFIX_TO}" ]]; then
    echo "[start] path_map=${PATH_PREFIX_FROM:-<unset>} -> ${PATH_PREFIX_TO:-<unset>}"
  else
    echo "[start] path_map=disabled"
  fi
  echo "[start] inputs=${#INPUTS[@]} targets=${#TARGETS[@]}"
  local input
  for input in "${INPUTS[@]}"; do
    if [[ ! -f "${input}" ]]; then
      echo "Missing input file: ${input}" >&2
      exit 1
    fi
    echo "[input] ${input}"
    fetch_one "${input}"
  done
  echo "Done. Output in ${OUT_DIR}/"
}

main "$@"
