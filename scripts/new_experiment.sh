#!/usr/bin/env bash
# Create a scratch experiment workspace and stage WRF executables into run/.
set -euo pipefail

NAME="${1:?Usage: $0 <experiment_short_name>}"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WRF_REPO="$(cd "${SCRIPT_DIR}/.." && pwd)"

EXP_ROOT="${WRF_EXPERIMENT_ROOT:-}"
if [[ -z "${EXP_ROOT}" ]]; then
  if [[ -n "${SCRATCH:-}" ]]; then
    EXP_ROOT="${SCRATCH}/wrf_experiments"
  else
    EXP_ROOT="/global/scratch/users/mldubey96/wrf_experiments"
  fi
fi

EXP="${EXP_ROOT}/${NAME}"
mkdir -p "${EXP}/run" "${EXP}/WPS" "${EXP}/input" "${EXP}/logs"

export WRF_REPO
# Prefer prebuilt binaries (e.g. sibling hybrid build) if this tree is not compiled.
if [[ ! -x "${WRF_REPO}/_build/main/wrf" ]] && [[ -z "${WRF_PREBUILT_MAIN:-}" ]]; then
  SIBLING="${WRF_REPO}/../WRF-4.7.1-hybrid-base/_build/main"
  if [[ -x "${SIBLING}/wrf" ]]; then
    export WRF_PREBUILT_MAIN="${SIBLING}"
    echo "Using WRF_PREBUILT_MAIN=${WRF_PREBUILT_MAIN}"
  fi
fi

"${SCRIPT_DIR}/copy_wrf_executables.sh" "${EXP}/run"

cat > "${EXP}/README_scratch.txt" <<EOF
Experiment: ${NAME}
Created: $(date -u +%Y-%m-%dT%H:%M:%SZ)

run/       — staged wrf/real binaries; place namelist.input here + link inputs.
WPS/       — geo_grid, metgrid, ungrib work (optional symlink to WPS build).
input/     — archived met_em*, wrfchemi*, ancillary files before linking.
logs/      — suggested place for rsl.* copies or job logs.

Next: cd ${EXP}/run
  ln -sf .../namelist.input .
  ln -sf .../met_em*.nc .
  (optional wrfchem) ln -sf .../wrfchemi*_d* .
Then: mpirun -np N ./real.exe
      mpirun -np N ./wrf.exe
EOF

echo "Experiment layout ready: ${EXP}"
echo " cd ${EXP}/run"
