cd temp/pages
cp ../../input/pagecontent/* _includes/; jekyll b

echo updated site: temp/pages/_site

cp _site/* ../../output