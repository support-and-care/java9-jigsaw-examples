#!/usr/bin/env bash
source ../env.sh

rm -rf classes/*
rm -rf amlib/*.jar
rm -rf cplib/*.jar

mkdir -p amlib
mkdir -p classes
mkdir -p cplib

rm -rf run-result
