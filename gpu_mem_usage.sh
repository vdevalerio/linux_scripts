#!/bin/bash

# Get used and total GPU memory (in MiB)
USED_MEM=$(nvidia-smi --query-gpu=memory.used --format=csv,noheader,nounits)
TOTAL_MEM=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits)

# Calculate percentage (avoid division by zero)
if [ "$TOTAL_MEM" -gt 0 ]; then
    PERCENTAGE=$(awk "BEGIN {printf \"%.0f\", ($USED_MEM/$TOTAL_MEM)*100}")
else
    PERCENTAGE="0.00"
fi

echo "$PERCENTAGE"
