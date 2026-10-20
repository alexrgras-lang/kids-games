#!/bin/zsh
# Regenerate audio clips for the Word Quest game from the PROFILES lists in index.html.
# Usage: ./make_audio.sh   (run from this folder; only records clips that don't exist yet)
set -e
cd "$(dirname "$0")"; mkdir -p audio
node -e '
const fs=require("fs");const h=fs.readFileSync("index.html","utf8");
const js=h.match(/<script>([\s\S]*)<\/script>/)[1];
const src=js.slice(js.indexOf("const PROFILES"), js.indexOf("const MAX_LEVEL"));
const PROFILES=new Function(src+"; return PROFILES;")();
const PHRASES=eval(js.match(/const PHRASES = (\[[^\]]*\]);/)[1]);
const out={};
for(const [id,p] of Object.entries(PROFILES)) for(const it of (p.words||[]).concat(p.bonus||[])){ out["w_"+it.w]=it.w; out[(id==="camila"?"sc_":"s_")+it.w]=it.s.includes("___")?it.s.replace("___",it.w):it.s; }
for(const l of "abcdefghijklmnopqrstuvwxyz") out["l_"+l]=l;
PHRASES.forEach((t,i)=>out["p_"+i]=t);
fs.writeFileSync("/tmp/wq-manifest.json", JSON.stringify(out));'
python3 - <<'PY'
import json,subprocess,os
m=json.load(open("/tmp/wq-manifest.json")); n=0
for k,t in m.items():
    if os.path.exists(f"audio/{k}.mp4"): continue
    subprocess.run(["say","-v","Samantha","-r","150","-o",f"audio/{k}.aiff",t],check=True)
    subprocess.run(["afconvert","-f","mp4f","-d","aac","-b","40000",f"audio/{k}.aiff",f"audio/{k}.mp4"],check=True,capture_output=True)
    os.remove(f"audio/{k}.aiff"); n+=1
print(n,"new clips")
PY
