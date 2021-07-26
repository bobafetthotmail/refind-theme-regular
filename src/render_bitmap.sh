#!/usr/bin/env bash
#

INKSCAPE=`which inkscape 2> /dev/null`
OPTIPNG=`which optipng 2> /dev/null`

OUT="bitmap"
BIG_ICON_SRC_DIR="svg/big"
SMALL_ICON_SRC_DIR="svg/small"
REG_BIG_ICON_FILENAME='s/^svg\/big\///g;s/.svg$//g'
REG_SMALL_ICON_FILENAME='s/^svg\/small\///g;s/.svg$//g'
DPI=96
SCALE_PRESET=(1 2 3 4)
SCALE=1
SRC_DIR=""
OUT_DIR=""
REG=''

function render_bitmap(){
    for svgfile in $(ls $SRC_DIR | grep .svg)
        do
            filename=$(echo $svgfile | sed $REG)
            if [ -f "$OUT_DIR/$filename.png" ]
                then
                    echo "'$OUT_DIR/$filename.png' already exists"
                else
                    echo "Creating... $OUT_DIR/$filename.png"
                	$INKSCAPE --export-area-page \
                              --export-overwrite \
                              --export-dpi=$(($SCALE*$DPI)) \
                              --export-filename="$OUT_DIR/$filename.png" $SRC_DIR/$svgfile> /dev/null \
                    &&
                    if [[ -x $OPTIPNG ]]
                        then
                            $OPTIPNG -o7 --quiet "$OUT_DIR/$filename.png"
                    fi

            fi
        done

        if [ -f $OUT_DIR/os_unknown.png ]
            then
                for f in os_clover os_gummiboot os_hwtest os_refit os_network os_systemd-boot
                    do
                        echo "Copying... $OUT_DIR/$f.png"
                        cp -f "$OUT_DIR/os_unknown.png" "$OUT_DIR/$f.png"
                done
     	fi

        if [ -f $OUT_DIR/tool_rescue.png ]
            then
                for f in tool_apple_rescue tool_windows_rescue
                    do
                        echo "Copying... $OUT_DIR/$f.png"
                        cp -f "$OUT_DIR/tool_rescue.png" "$OUT_DIR/$f.png"
                done

        fi
}
function render_big_icon(){
    SCALE=$i
    REG=$REG_BIG_ICON_FILENAME
    SRC_DIR=$BIG_ICON_SRC_DIR
    OUT_DIR="$OUT/big_$(($i*128))"
    mkdir -p $OUT_DIR
    render_bitmap
}
function render_small_icon(){
    SCALE=$i
    REG=$REG_SMALL_ICON_FILENAME
    SRC_DIR=$SMALL_ICON_SRC_DIR
    OUT_DIR="$OUT/small_$(($i*48))"
    mkdir -p $OUT_DIR
    render_bitmap
}

for i in ${SCALE_PRESET[@]}
   do
        render_big_icon
   	    render_small_icon
done
exit 0
