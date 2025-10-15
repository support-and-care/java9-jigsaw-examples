. ../env.sh

./mvnw --version --fail-at-end 2>&1

cd src/moda
../../mvnw -s ../../mvn_settings.xml install 2>&1
cd - >/dev/null 2>&1

cd src/modmain
../../mvnw -s ../../mvn_settings.xml test 2>&1
cd - >/dev/null 2>&1
