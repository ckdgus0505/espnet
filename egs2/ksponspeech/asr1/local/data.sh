#!/bin/bash
# Copyright 2020 Electronics and Telecommunications Research Institute (Hoon Chung)
# Apache 2.0  (http://www.apache.org/licenses/LICENSE-2.0)

# Set bash to 'debug' mode, it will exit on :
# -e 'error', -u 'undefined variable', -o ... 'error in pipeline', -x 'print commands',
set -e
set -u
set -o pipefail

log() {
    local fname=${BASH_SOURCE[1]##*/}
    echo -e "$(date '+%Y-%m-%dT%H:%M:%S') (${fname}:${BASH_LINENO[0]}:${FUNCNAME[1]}) $*"
}
SECONDS=0

stage=1
stop_stage=100000

pipe_wav=false

log "$0 $*"
. utils/parse_options.sh

if [ $# -gt 1 ]; then
    log "Error: Positional arguments are required."
    exit 2
fi

. ./db.sh
. ./path.sh
. ./cmd.sh

datadir=$1

if [ ${stage} -le 1 ] && [ ${stop_stage} -ge 1 ]; then
  local/trans_prep.sh ${datadir} data/local/KsponSpeech
  for x in train dev eval_clean eval_other; do
    local/data_prep.sh ${datadir} data/local/KsponSpeech data/${x}
  done
fi

log "Successfully finished. [elapsed=${SECONDS}s]"
