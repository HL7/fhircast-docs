#!/bin/bash

# copies all sections to a single markdown file and adds it to the site so it can be build
# this is usefull for review.

sushiconfig="../sushi-config.yaml"
fullspec="fullspec.md"

rm -Rf $fullspec
rm -Rf $fullspec.tmp

echo "#" FHIRcast > $fullspec
echo >> FHIRcast.md

echo 1. The generated Toc will be an ordered list >> $fullspec
echo {:toc} >> $fullspec
echo >> $fullspec

# cat $sushiconfig |  sed -ne '/pages/,$ p'

cat $sushiconfig |  sed -ne '/pages/,$ p'| grep -e .md -e title: | while read line1
do
    read line2
    echo title-: $line2
    echo md----: $line1 

    echo "##" ${line2#title:} >> $fullspec
    echo >> $fullspec
    fn=../input/pagecontent/${line1%":"}
    cat $fn >> $fullspec
done

mv $fullspec ../temp/pages/_includes
cp -f fullspec-md.html ../temp/pages/_includes
cp fullspec.html ../temp/pages

# cd ../temp/pages

# jekyll b

# cd output
# mv ../$fullspec .
# kramdown --auto-ids $fullspec > FHIRcast.html
