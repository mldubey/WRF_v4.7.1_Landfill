#!/usr/bin/env bash
# Sanity check that wrf launches under MPI without requiring met_em/wrfinput.
# Expect failure about missing inputs; verifies binary + mpi + shared libs resolve.
set -euo pipefail

NP="${1:-2}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WRF_REPO="$(cd "${SCRIPT_DIR}/.." && pwd)"

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
OUT="$("${MPIRUN[@]}" -np "${NP}" "${TMP}/wrf" 2>&1)"
RC=$?
set -e

echo "${OUT}" | head -n 28
echo "--- exit code ${RC} (nonzero expected without namelist/inputs; goal is linking + MPI startup) ---"
