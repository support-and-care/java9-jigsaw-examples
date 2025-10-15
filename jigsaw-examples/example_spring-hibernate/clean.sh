. ../env.sh

pushd src > /dev/null 2>&1

./mvnw --version

./mvnw -s ../mvn_settings.xml -e clean --fail-at-end 2>&1

popd >/dev/null 2>&1 
