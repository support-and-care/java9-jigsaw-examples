. ../env.sh

./mvnw --version --fail-at-end
cd src/modmain
../../mvnw -s ../../mvn_settings.xml clean --fail-at-end 2>&1
cd - >/dev/null 2>&1

cd src/moda
../../mvnw -s ../../mvn_settings.xml clean --fail-at-end 2>&1
cd - >/dev/null 2>&1

rm -rf doc
