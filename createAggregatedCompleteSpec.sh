#!/bin/bash

rm -Rf FHIRcast.md

#sushiconfig1=$(cat sushi-config.yaml | grep -e .md -e title: )
#echo $sushiconfig1

sushiconfig="sushi-config.yaml"

echo "#" FHIRcast > FHIRcast.md
echo > FHIRcast.md

echo 1. The generated Toc will be an ordered list > FHIRcast.md
echo {:toc} > FHIRcast.md
echo > FHIRcast.md

cat $sushiconfig | grep -e .md -e title: | while read line1
do
    read line2
    # echo title: $line2
    # echo md: $line1

    echo "##" ${line2#title:} >> FHIRcast.md
    echo >> FHIRcast.md
    fn=./input/pagecontent/${line1%":"}
    cat $fn >> FHIRcast.md
    
done

cd output
mv ../FHIRcast.md .
kramdown --auto-ids FHIRcast.md > FHIRcast.html

