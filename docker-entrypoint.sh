#!/bin/bash

set -e

cd /pi-gen

./build.sh $*

rsync -av work/*/build.log deploy/

