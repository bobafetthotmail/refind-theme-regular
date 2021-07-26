#!/bin/sh

icons_folders="128-48 256-96 384-144 512-192"

cd ..

for i in $icons_folders ; do

    mkdir -p "icons/$i"

    big_size="$(echo $i | awk -F"-" '{print $1}')"
    small_size="$(echo $i | awk -F"-" '{print $2}')"

    cp -av "./src/bitmap/big_$big_size/." "./icons/$i"
    cp -av "./src/bitmap/small_$small_size/." "./icons/$i"

done
