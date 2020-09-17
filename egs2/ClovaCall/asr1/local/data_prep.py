
# Copyright 2020 Hoon Chung (hchung@etri.re.kr)
#  Apache 2.0  (http://www.apache.org/licenses/LICENSE-2.0)

import os
import sys
import re
import codecs
import json

if len(sys.argv) != 3:
  print("Usage : src-dir part")
  sys.exit()

src_dir = sys.argv[1]
part = sys.argv[2]

fname = sys.argv[1] + "/" + part + "_ClovaCall.json"

wav_scp = open("data/"+part+"/wav.scp", "w")
text = codecs.open("data/"+part+"/text", "w", encoding='utf-8')
utt2spk = open("data/"+part+"/utt2spk", "w")

data_tuples = []
with codecs.open(fname, encoding='utf-8') as json_file:
  json_data = json.load(json_file)

  for data in json_data:
    key = os.path.splitext(data['wav'])[0]
    wav = src_dir+"/wavs_"+part+"/"+data['wav'] 
    spk = data['speaker_id']
    txt = " ".join(re.split('\W+', data['text']))

    key = spk+"_"+key
    data_tuples.append((key, wav, txt, spk))

data_tuples.sort() 
for key, wav, txt, spk, in data_tuples:
  wav_scp.write("%s %s\n"%(key, wav))
  text.write("%s %s\n"%(key, txt))
  utt2spk.write("%s %s\n"%(key, spk))

wav_scp.close()
text.close()
utt2spk.close()
