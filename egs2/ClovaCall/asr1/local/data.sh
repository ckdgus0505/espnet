#!/bin/bash

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

log "$0 $*"

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <ClovaCall-dir>"
  echo "e.g.: $0 /NASdata/splDB/clovacall_data"
  exit 1
fi

datadir=$1
ndev_utt=600

train_set="train_nodev"
train_dev="train_dev"
test_set="test_clean"

for part in train test; do
  mkdir -p data/${part}
  python3 local/data_prep.py ${datadir} ${part}
  utils/utt2spk_to_spk2utt.pl data/${part}/utt2spk > data/${part}/spk2utt
done
    
# shuffle whole training set
utils/shuffle_list.pl data/train/utt2spk > utt2spk.tmp

# make a dev set
head -${ndev_utt} utt2spk.tmp | \
utils/subset_data_dir.sh --utt-list - data/train "data/${train_dev}"

# make a traing set
n=$(($(wc -l < data/train/text) - ndev_utt))
tail -${n} utt2spk.tmp | \
utils/subset_data_dir.sh --utt-list - data/train "data/${train_set}"
  
rm -f utt2spk.tmp

utils/copy_data_dir.sh data/test "data/${test_set}"

log "Successfully finished. [elapsed=${SECONDS}s]"
