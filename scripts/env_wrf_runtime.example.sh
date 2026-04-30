# Example: source before mpirun ./wrf or ./real if you see GLIBCXX_* errors from NetCDF/PnetCDF.
# Copy to env_wrf_runtime.sh (gitignored suggestion: keep local-only) or merge into job scripts.

if [[ -n "${CONDA_PREFIX:-}" && -d "${CONDA_PREFIX}/lib" ]]; then
  export LD_LIBRARY_PATH="${CONDA_PREFIX}/lib:${LD_LIBRARY_PATH:-}"
elif [[ -d "/global/software/rocky-8.x86_64/manual/modules/langs/anaconda3/2024.02-1/lib" ]]; then
  export LD_LIBRARY_PATH="/global/software/rocky-8.x86_64/manual/modules/langs/anaconda3/2024.02-1/lib:${LD_LIBRARY_PATH:-}"
fi
