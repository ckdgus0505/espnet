#!/bin/bash
# Set bash to 'debug' mode, it will exit on :
# -e 'error', -u 'undefined variable', -o ... 'error in pipeline', -x 'print commands',
set -e
set -u
set -o pipefail

train_set="train_nodev"
valid_set="train_dev"
test_sets="test_clean"

feats_type=raw
local_data_opts=""
speed_perturb_factors="0.9 1.0 1.1"

if [ "${feats_type}" = fbank_pitch ]; then
    local_data_opts+="---pipe_wav true "
fi

inference_config=conf/decode_asr.yaml

./asr.sh \
    --token_type char \
    --local_data_opts "${local_data_opts}" \
    --nbpe 2000 \
    --use_lm false \
    --fs 8k \
    --max_wav_duration 60 \
    --lang kr \
    --lm_config conf/tuning/train_lm.yaml \
    --asr_config conf/tuning/train_asr_transformer6.yaml \
    --inference_config "${inference_config}"  \
    --train_set "${train_set}" \
    --valid_set "${valid_set}" \
    --test_sets "${test_sets}" \
    --speed_perturb_factors "${speed_perturb_factors}" \
    --srctexts "data/train/text" "$@"
