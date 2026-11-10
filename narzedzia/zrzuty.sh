#!/bin/bash
# uruchamia gre pod wirtualnym ekranem i robi zrzuty do ${WYJSCIE:-/tmp/op_zrzuty}
rm -rf ${WYJSCIE:-/tmp/op_zrzuty}; mkdir -p ${WYJSCIE:-/tmp/op_zrzuty}
cd "$(dirname "$0")/.."
timeout ${1:-170} xvfb-run -a -s "-screen 0 1920x1080x24" ${GODOT:-godot} --rendering-driver opengl3 --resolution 1920x1080 --audio-driver Dummy -- --zrzut=${WYJSCIE:-/tmp/op_zrzuty} 2>&1 | grep -vE '^\s*$' | grep -vE 'Godot Engine|OpenGL API|^$' | head -${2:-40}
ls ${WYJSCIE:-/tmp/op_zrzuty}
