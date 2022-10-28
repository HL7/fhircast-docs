echo $1
java -jar rr.war -suppressebnf $1  > $1.xhtml
xmllint --format $1.xhtml > $1.nice.xhtml
cat $1.nice.xhtml |   sed -n '/<svg/,/svg>/ p' > $1.svg
cat $1.svg | sed -n '/<svg/,/svg>/ d' >t $1.svg
