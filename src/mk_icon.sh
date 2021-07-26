#!/usr/bin/env bash
rm -rf bitmap
rm -rf icons
	
./render_bitmap.sh

      

mkdir -p icons/{128-48,256-96,384-144}
cp -r bitmap/{big_128/*.png,small_48/*.png} icons/128-48
cp -r bitmap/{big_256/*.png,small_96/*.png} icons/256-96 
cp -r bitmap/{big_384/*.png,small_144/*.png} icons/384-144

exit 0
