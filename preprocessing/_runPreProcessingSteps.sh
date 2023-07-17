echo =====================================
echo Create EBNF images
cd ebnf 
./_createAllEbnfPng.sh
cd ..

echo =====================================
echo Create R5 profiles
sushi R5/
cp R5/fsh-generated/resources/* results

echo =====================================
echo Create R5 profiles
sushi R4/
cp R4/fsh-generated/resources/* results

echo =====================================
echo Create R5 profiles
sushi R4b/
cp R4b/fsh-generated/resources/* results

echo =====================================
echo Replace profiles
rm -Rf ../input/resources/*
cp results/* ../input/resources
