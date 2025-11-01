#!/usr/bin/env bash
source ../env.sh

rm -rf mods/*
rm -rf mlib/*.jar

rm -rf apps

# if you want to keep the app.json files:
# rm -rf apps/*/mlib/*.jar

mkdir -p mods
mkdir -p mlib

rm -rf doc
rm -rf run-result
