#!/bin/bash
# podglad.sh nazwa_modelu [ukryj=a,b]  -> ${WYJSCIE:-/tmp/op_podglad}/*.png
cd "$(dirname "$0")/.."
${GODOT:-godot} --headless --import >/dev/null 2>&1
mkdir -p ${WYJSCIE:-/tmp/op_podglad}
timeout 90 xvfb-run -a -s "-screen 0 1600x900x24" ${GODOT:-godot} --rendering-driver opengl3 --resolution 1600x900 --audio-driver Dummy res://sceny/podglad.tscn -- --model=res://zasoby/modele/$1.glb --wyjscie=${WYJSCIE:-/tmp/op_podglad} ${2:+--ukryj=$2} 2>&1 | grep -E 'ERROR|SCRIPT|error' | head
ls ${WYJSCIE:-/tmp/op_podglad} | grep $1 | tr '\n' ' '
