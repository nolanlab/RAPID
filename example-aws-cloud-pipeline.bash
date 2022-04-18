#!/usr/bin/bash
# shellcheck shell=bash

# git-bash script for running CODEX preprocessing pipeline in multiple GPUs and CPU cores on Windows Server 2019

# environment variables to run Matlab subprocesses using GNU Parallel
# folders to process (one per experiment)
export folders="codex-processing-pipeline-test-data-20211216"
# total number of GPUs
export nGPU=1
# first and last cycle
export startCycle=1
export endCycle=8
# first and last region
export startRegion=1
export endRegion=4
export cyc_range="$startCycle":"$endCycle"
export reg_range="$startRegion":"$endRegion"

# navigate to src directory
cd "/c/Program Files/codex-preprocess"

# run pipeline

decon_runner
stitch_runner
driftCompensate_runner
bgSubtract_runner
hyperstack_runner

###

# convenance git-bash command to stop GNU Parallel but let current jobs finish
# ps | grep perl | tr -s ' ' | cut -f2 -d' ' | xargs -n 1 kill -s SIGHUP
