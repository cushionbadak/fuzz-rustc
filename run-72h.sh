#!/bin/bash
# 72-hour fuzzing run in background

nohup bash -c '
  date "+START %Y-%m-%d %H:%M:%S" > date.txt
  ./run-fuzzer.sh -jobs=32 -fork=1 -ignore_crashes=1 -max_total_time=259200 > /dev/null 2>&1
  date "+END   %Y-%m-%d %H:%M:%S" >> date.txt
' &

echo "Fuzzing started (PID: $!)"
echo "  date.txt  → start/end times"
echo "  fuzz.log  → fuzzer output"
