# remove old files
rm -f diagram/*.png

# create new files for all files in input
find input/ -name *.ebnf -exec ./_createEbnfPng.sh {} \;

# copy to input/images
cp diagram/*.png ../../input/images/
