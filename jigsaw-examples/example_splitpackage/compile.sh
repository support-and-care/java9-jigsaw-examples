#!/usr/bin/env bash

source ../env.sh

mkdir -p mods
mkdir -p mlib 

# does not compile
./compile-foo.sh

./compile-bar.sh
