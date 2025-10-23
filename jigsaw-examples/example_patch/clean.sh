#!/usr/bin/env bash
source ../env.sh

rm -rf mods/*
rm -rf patches/*
rm -rf mlib/*.jar
rm -rf patchlib/*.jar

mkdir -p mods
mkdir -p patches
mkdir -p mlib
mkdir -p patchlib
rm -rf run-result
