#!/usr/bin/env bash
# Sanity check that wrf launches under MPI without requiring met_em/wrfinput.
# Expect nonzero exit (missing namelist/input); goal is MPI + shared libs + process start.
set -euo pipefail

NP="${1:-1}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WRF_REPO="$(cd "${SCRIPT_DIR}/.." && pwd)"

# CMake build may link pnetcdf/netcdf against libstdc++; system /lib64 may be too old on RHEL8-class nodes.
if [[ -n "${CONDA_PREFIX:-}" && -f "${CONDA_PREFIX}/lib/libstdc++.so.6" ]]; then
  export LD_LIBRARY_PATH="${CONDA_PREFIX}/lib${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"
elif [[ -f "/global/software/rocky-8.x86_64/manual/modules/langs/anaconda3/2024.02-1/lib/libstdc++.so.6" ]]; then
  _L="/global/software/rocky-8.x86_64/manual/modules/langs/anaconda3/2024.02-1/lib"
  export LD_LIBRARY_PATH="${_L}${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"
fi

if [[ ! -x "${WRF_REPO}/_build/main/wrf" ]] && [[ -z "${WRF_PREBUILT_MAIN:-}" ]]; then
  H="${WRF_REPO}/../WRF-4.7.1-hybrid-base/_build/main"
  if [[ -x "${H}/wrf" ]]; then
    export WRF_PREBUILT_MAIN="${H}"
  fi
fi

TMP="$(mktemp -d /tmp/wrf_smoke_mpi.XXXXXX)"
trap 'rm -rf "${TMP}"' EXIT

"${SCRIPT_DIR}/copy_wrf_executables.sh" "${TMP}"

MPIRUN=(mpiexec)
if command -v mpirun >/dev/null 2>&1; then
  MPIRUN=(mpirun)
elif command -v srun >/dev/null 2>&1; then
  MPIRUN=(srun)
fi

set +e
if command -v timeout >/dev/null 2>&1; then
  OUT="$(timeout 25 "${MPIRUN[@]}" -np "${NP}" "${TMP}/wrf" 2>&1)"
  RC=$?
else
  OUT="$("${MPIRUN[@]}" -np "${NP}" "${TMP}/wrf" 2>&1)"
  RC=$?
fi
set -e

echo "${OUT}" | head -n 28
echo "--- exit code ${RC} (nonzero/124 are fine; look for 'starting wrf task'; 124 = timeout) ---"
