echo $1
# create image zip
java -jar rr.war -png $1 > output.zip

# unzip and remove unrequired files.
unzip -o output.zip
rm -f index.html
rm -f output.zip
rm -f diagram/Railroad-Diagram-Generator.png

