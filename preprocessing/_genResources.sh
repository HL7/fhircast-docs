echo ------------------------------------
echo Clean results
echo ------------------------------------
rm -Rf results/*
mkdir results

echo ------------------------------------
echo R4
echo ------------------------------------
rm -Rf tmp
mkdir tmp
mkdir tmp/input
mkdir tmp/input/fsh

find base -name "*.fsh"             -exec awk '{sub(/{{R4}}/,"*"); sub(/{{R4b}}/,"//"); sub(/{{R5}}/,"//"); sub(/{{fhirVersionNumber}}/,"4.0.1"); sub(/{{fhirNoLc}}/,"r4"); sub(/{{fhirNoUc}}/,"R4"); print}' {} \; > tmp/input/fsh/r4.fsh
find base -name "sushi-config.yaml" -exec awk '{sub(/{{R4}}/,"*"); sub(/{{R4b}}/,"//"); sub(/{{R5}}/,"//"); sub(/{{fhirVersionNumber}}/,"4.0.1"); sub(/{{fhirNoLc}}/,"r4"); sub(/{{fhirNoUc}}/,"R4"); print}' {} \; > tmp/sushi-config.yaml

sushi tmp
cp tmp/fsh-generated/resources/* results

echo ------------------------------------
echo R4b
echo ------------------------------------
rm -Rf tmp
mkdir tmp
mkdir tmp/input
mkdir tmp/input/fsh

find base -name "*.fsh"             -exec awk '{sub(/{{R4}}/,"//"); sub(/{{R4b}}/,"*"); sub(/{{R5}}/,"//"); sub(/{{fhirVersionNumber}}/,"4.3.0"); sub(/{{fhirNoLc}}/,"r4b"); sub(/{{fhirNoUc}}/,"R4b"); print}' {} \; > tmp/input/fsh/r4b.fsh
find base -name "sushi-config.yaml" -exec awk '{sub(/{{R4}}/,"//"); sub(/{{R4b}}/,"*"); sub(/{{R5}}/,"//"); sub(/{{fhirVersionNumber}}/,"4.3.0"); sub(/{{fhirNoLc}}/,"r4b"); sub(/{{fhirNoUc}}/,"R4b"); print}' {} \; > tmp/sushi-config.yaml

sushi tmp
cp tmp/fsh-generated/resources/* results

echo ------------------------------------
echo R5
echo ------------------------------------
rm -Rf tmp
mkdir tmp
mkdir tmp/input
mkdir tmp/input/fsh

find base -name "*.fsh"             -exec awk '{sub(/{{R4}}/,"//"); sub(/{{R4b}}/,"*"); sub(/{{R5}}/,"//"); sub(/{{fhirVersionNumber}}/,"4.3.0"); sub(/{{fhirNoLc}}/,"r4b"); sub(/{{fhirNoUc}}/,"R4b"); print}' {} \; > tmp/input/fsh/r4b.fsh
find base -name "sushi-config.yaml" -exec awk '{sub(/{{R4}}/,"//"); sub(/{{R4b}}/,"*"); sub(/{{R5}}/,"//"); sub(/{{fhirVersionNumber}}/,"4.3.0"); sub(/{{fhirNoLc}}/,"r4b"); sub(/{{fhirNoUc}}/,"R4b"); print}' {} \; > tmp/sushi-config.yaml

sushi tmp
cp tmp/fsh-generated/resources/* results

echo ------------------------------------
echo R4b
echo ------------------------------------
rm -Rf tmp
mkdir tmp
mkdir tmp/input
mkdir tmp/input/fsh

find base -name "*.fsh"             -exec awk '{sub(/{{R4}}/,"//"); sub(/{{R4b}}/,"//"); sub(/{{R5}}/,"*"); sub(/{{fhirVersionNumber}}/,"5.0.0"); sub(/{{fhirNoLc}}/,"r5"); sub(/{{fhirNoUc}}/,"R5"); print}' {} \; > tmp/input/fsh/r5.fsh
find base -name "sushi-config.yaml" -exec awk '{sub(/{{R4}}/,"//"); sub(/{{R4b}}/,"//"); sub(/{{R5}}/,"*"); sub(/{{fhirVersionNumber}}/,"5.0.0"); sub(/{{fhirNoLc}}/,"r5"); sub(/{{fhirNoUc}}/,"R5"); print}' {} \; > tmp/sushi-config.yaml

sushi tmp
cp tmp/fsh-generated/resources/* results

echo ------------------------------------
echo Replace profiles
echo ------------------------------------
rm -Rf ../input/resources/*
cp results/* ../input/resources
