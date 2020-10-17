#!/bin/bash
# Set bash to 'debug' mode, it will exit on :
# -e 'error', -u 'undefined variable', -o ... 'error in pipeline', -x 'print commands',
set -e
set -u
set -o pipefail

feats_type=raw
local_data_opts=""    # Specifiy KSponSpeech directory

train_set="train"
valid_set="dev"
test_sets="eval_clean eval_other"

if [ "${feats_type}" = fbank_pitch ]; then
    local_data_opts+="---pipe_wav true "
fi

inference_config=conf/decode_asr.yaml

bpe_nlsyms='[unk]'

./asr.sh \
    --local_data_opts "${local_data_opts}" \
    --token_type bpe \
    --nbpe 2310 \
    --bpe_nlsyms "${bpe_nlsyms}" \
    --max_wav_duration 30 \
    --use_lm false \
    --ngpu 4 \
    --inference_nj 8 \
    --lang kr \
    --lm_config conf/tuning/train_lm.yaml \
    --asr_config conf/tuning/train_asr_transformer2_ddp.yaml \
    --inference_config "${inference_config}"  \
    --train_set "${train_set}" \
    --valid_set "${valid_set}" \
    --test_sets "${test_sets}" \
    --srctexts "data/train/text" "$@"
