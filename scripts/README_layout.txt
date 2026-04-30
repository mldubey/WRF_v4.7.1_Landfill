WRF_v4.7.1_Landfill layout (this repo)
======================================

WRF_v4.7.1_Landfill (this directory)
  Primary working copy: configure, build, and keep _build/ here.
  Binaries: _build/main/wrf, _build/main/real, ndown, tc (Linux names; no .exe).

WRF_v4.7.1_Landfill_Clean (sibling directory)
  Same git history, no _build/: use for diffs, rebases, or a pristine tree.
  Re-sync phys/physics_mmm here if you rebuild from Clean (see below).

phys/physics_mmm/
  Not tracked in upstream WRF git; CMake still lists these sources.
  One-time (or after fresh clone): copy from a full 4.7.1 tree, e.g.
    rsync -a ../WRF-4.7.1-hybrid-base/phys/physics_mmm/ ./phys/physics_mmm/
  (Ignored by git in this fork so status stays clean.)

Scratch experiments
  Default root: $WRF_EXPERIMENT_ROOT or $SCRATCH/wrf_experiments or
  /global/scratch/users/mldubey96/wrf_experiments
  scripts/new_experiment.sh <name>  — creates <root>/<name>/{run,WPS,input,logs}
  and copies executables from this repo's _build/main into run/.

Typical cycle
  1) Build once in WRF_v4.7.1_Landfill (configure_new -x, cmake --build _build ...).
  2) new_experiment.sh my_methane_test
  3) cd $SCRATCH/.../my_methane_test/run — add namelist.input, link met_em*, wrfchemi*, run real/wrf.
