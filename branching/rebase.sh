#!/bin/bash
# display command line options

#try again

count=1
for param in "$@"; do
    echo "\$@ Parameter #$count = $param"
    echo "Next parameter: $param"
    count=$(( $count + 1 ))
done

echo "====="

#changed in main branch