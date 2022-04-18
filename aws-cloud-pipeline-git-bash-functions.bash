#!/usr/bin/bash
# shellcheck shell=bash

# git-bash shell functions for running CODEX preprocessing pipeline in multiple GPUs and CPU cores on Windows Server 2019

check() {
  [[ -z "$folders" ]] &&
    echo "environment variable 'folders' is not set" &&
    return 1

  [[ -z "$nGPU" ]] &&
    echo "environment variable 'nGPU' is not set" &&
    return 1

  [[ -z "$startCycle" ]] &&
    echo "environment variable 'startCycle' is not set" &&
    return 1

  [[ -z "$endCycle" ]] &&
    echo "environment variable 'endCycle' is not set" &&
    return 1

  [[ -z "$startRegion" ]] &&
    echo "environment variable 'startRegion' is not set" &&
    return 1

  [[ -z "$endRegion" ]] &&
    echo "environment variable 'endRegion' is not set" &&
    return 1

  echo "folders: $folders"
  echo "nGPU: $nGPU"
  echo "startCycle: $startCycle"
  echo "endCycle: $endCycle"
  echo "startRegion: $startRegion"
  echo "endRegion: $endRegion"
}

decon_runner() {
  check || return 1
  # run deconvolution, GPU only
  parallel --verbose --eta -j "$nGPU" --ungroup --resume-failed --joblog /y/parallel-deconv-$folders.log \
    "matlab -batch \"folder='{1}'; config; cyc_range={2}; gpu_id={%}; reg_range={3}; decon_runner;\"" \
    ::: $(echo $folders) ::: $(seq $startCycle $endCycle) ::: $(seq $startRegion $endRegion)
}

stitch_runner() {
  check || return 1
  # stitching, CPU only
  parallel --verbose --eta --ungroup --resume-failed --joblog /y/parallel-stitching-$folders.log \
    "matlab -batch \"folder='{1}'; config; cyc_range={2};reg_range={3}; stitching_runner;\"" \
    ::: $(echo $folders) ::: $(seq $startCycle $endCycle) ::: $(seq $startRegion $endRegion)
}

driftCompensate_runner() {
  check || return 1
  # driftCompensate_runner compensation, CPU and GPU
  parallel --verbose --eta --ungroup --resume-failed --joblog /y/parallel-driftCompensate-$folders.log \
    "matlab -batch \"gpu_id={%}; folder='{1}'; config; cyc_range={2}; reg_range={3}; driftCompensate_runner;\"" \
    ::: $(echo $folders) ::: $(seq $startCycle $endCycle) ::: $(seq $startRegion $endRegion)
}

bgSubtract_runner() {
  check || return 1
  # background subtraction, CPU only
  parallel --verbose --eta --ungroup --resume-failed --joblog /y/parallel-bgSub-$folders.log \
    "matlab -batch \"folder='{1}'; config; cyc_range={2}; reg_range={3}; bgSubtract_runner;\"" \
    ::: $(echo $folders) ::: $(seq $startCycle $endCycle) ::: $(seq $startRegion $endRegion)
}

hyperstack_runner() {
  check || return 1
  # hyperstack generation, IO, mem intensive
  parallel -j 6 --timeout 1600 --verbose --ungroup --retries 3 --resume-failed --joblog /y/parallel-hyperstack-$folders.log \
    "matlab -batch \"folder='{1}'; config; cyc_last=$endCycle; cyc_range=$cyc_range; reg_range={2};hyperstack_runner;\"" \
    ::: $(echo $folders) ::: $(seq $startRegion $endRegion)
}
