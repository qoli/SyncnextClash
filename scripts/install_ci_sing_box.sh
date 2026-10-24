#!/usr/bin/env bash
set -euo pipefail

if [[ "$#" -ne 1 ]]; then
  echo "usage: $0 <install-directory>" >&2
  exit 2
fi

version="1.13.15"
system="$(uname -s)"
machine="$(uname -m)"
case "${system}-${machine}" in
  Linux-x86_64)
    platform="linux-amd64"
    archive_sha256="a3a3ff223b23c3f4731d0a17cb0ef94c97ce257c70721a5b07dc7ca079203c9f"
    ;;
  Darwin-arm64)
    platform="darwin-arm64"
    archive_sha256="3452d866834c9572389e5ca73e60d4ee45a7d5b79332188c9a9e533c5fd40a6d"
    ;;
  *)
    echo "unsupported platform: ${system}-${machine}" >&2
    exit 1
    ;;
esac

archive_name="sing-box-${version}-${platform}.tar.gz"
install_dir="$1"
temporary_root="${RUNNER_TEMP:-${TMPDIR:-/tmp}}"
download_dir="$(mktemp -d "${temporary_root%/}/syncnext-sing-box-${version}.XXXXXX")"
trap 'rm -rf "${download_dir}"' EXIT
archive_path="${download_dir}/${archive_name}"
extracted_path="${download_dir}/sing-box-${version}-${platform}/sing-box"

mkdir -p "${download_dir}" "${install_dir}"
curl -fsSL \
  "https://github.com/SagerNet/sing-box/releases/download/v${version}/${archive_name}" \
  -o "${archive_path}"
if [[ "${system}" == "Darwin" ]]; then
  printf '%s  %s\n' "${archive_sha256}" "${archive_path}" | shasum -a 256 --check --status
else
  printf '%s  %s\n' "${archive_sha256}" "${archive_path}" | sha256sum --check --status
fi
tar -xzf "${archive_path}" -C "${download_dir}"
install -m 0755 "${extracted_path}" "${install_dir}/sing-box"
"${install_dir}/sing-box" version
