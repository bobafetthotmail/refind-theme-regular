#!/usr/bin/env bash

if [ -d fonts ]
    then
        rm -r fonts
fi 

mkdir -p fonts
y_pos=0
for font in  "Source-Code-Pro-ExtraLight" "Nimbus-Mono" "Ubuntu-Mono"
    do
    	case "$font" in
    		"Source-Code-Pro-ExtraLight")
   	            y_pos="-9%"
                ;;
    		"Nimbus-Mono")
   	            y_pos="-12%"
                ;; 
    		"Ubuntu-Mono")
   	            y_pos=0
                ;;                               
        esac
        for size in  14 16 18 28 30 32 42 44 46
            do
                ./font2png.sh -f $font -s $size -y $y_pos "fonts/${font,,}-$size.png"
        done           
done 

exit 0
