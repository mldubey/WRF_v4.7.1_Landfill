#!/usr/bin/env bash
# Copy CMake-built WRF executables into an experiment run/ directory (Linux names: wrf, real, …).
set -euo pipefail

WRF_REPO="$(cd "$(dirname "$0")/.." && pwd)"
DEST="${1:?Usage: $0 /path/to/experiment/run}"

SRC=""
if [[ -x "${WRF_REPO}/_build/main/wrf" ]]; then
  SRC="${WRF_REPO}/_build/main"
elif [[ -n "${WRF_PREBUILT_MAIN:-}" ]] && [[ -x "${WRF_PREBUILT_MAIN}/wrf" ]]; then
  SRC="${WRF_PREBUILT_MAIN}"
else
  echo "ERROR: No wrf binary found." >&2
  echo "  Build in ${WRF_REPO} (_build/main) or set WRF_PREBUILT_MAIN to .../_build/main" >&2
  exit 1
fi

mkdir -p "${DEST}"

for exe in wrf real ndown tc; do
  [[ -x "${SRC}/${exe}" ]] && cp -a "${SRC}/${exe}" "${DEST}/" && chmod a+x "${DEST}/${exe}" || echo "SKIP missing ${exe}"
done

chmod a+x "${DEST}/wrf" "${DEST}/real" "${DEST}/ndown" "${DEST}/tc" 2>/dev/null || true

# Optional symlink names for scripting habits (-help is not universally supported).
cd "${DEST}"
ln -sf wrf wrf.exe 2>/dev/null || true
ln -sf real real.exe 2>/dev/null || true

echo "Copied from ${SRC} -> ${DEST}"
ls -la "${DEST}"/{wrf,real,ndown,tc} 2>/dev/null || true
