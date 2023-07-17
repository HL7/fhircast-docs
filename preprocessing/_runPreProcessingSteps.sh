echo =====================================
echo Create EBNF images
cd ebnf 
./_createAllEbnfPng.sh
cd ..

echo =====================================
echo Create profiles
./_genResources.sh

echo =====================================
echo Replace profiles
rm -Rf ../input/resources/*
cp results/* ../input/resources
