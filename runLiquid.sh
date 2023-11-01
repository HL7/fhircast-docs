#!/bin/sh

rm -f input/liquid/*.liquid.json
rm -f input/liquid/*.liquid.1
rm -f input/includes/*.liquid.json

sushi .

echo RUN LIQUID
find input/liquid/*.liquid -exec sh -c 'npx --yes liquidjs -t @"$1" > "$1".1' x {} \;
echo RUN JQ
find input/liquid/*.liquid -exec sh -c 'cat "$1".1 | jq > "$1.json"' x {} \;
echo RUN MOVE
mv input/liquid/*.liquid.json input/includes
rm -f input/liquid/*.liquid.1
