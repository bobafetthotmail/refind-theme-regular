#!/usr/bin/env bash
#
# Apply from mkfont.sh (by Roderick W. Smith)
# 
# This program is licensed under the terms of the GNU GPL, version 3,
# or (at your option) any later version.
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

CONVERT=`which convert 2> /dev/null`

FONT_NAME=""
FONT_SIZE=""
Y_POS=0

function print_help(){
    echo "Generate a PNG file suitable for use as a rEFInd font"
    echo "Usage:"
    echo "$0 [[-f|--font] <font_name>] [[-s|--size] <number>] <outfile.png>"
    echo "or"
    echo "$0 [options]... <outfile.png>"
    echo ""
    echo "Options:"
    echo "-f,--font: <font_name>              Name of font"      
    echo "-s,--size: <number>                 Font size in points"
    echo "-y,--y-pos: <number> or <number%>   Y offset position in pixels"
    echo "                                      or in percentage by font height"
    echo ""
    echo ""
    echo "-l,--list-font                      Display fonts list and exit"
    echo "-h,--help                           Display this help message and exit"
    echo ""
    exit 1
}


if [ $# -ne 0 ]
    then
        ARGS=`getopt -a -o hlf:s:y: -l help,list-font,font:,size:,y-pos: -n "$0" -- "$@"`
        eval set -- "$ARGS"

        while [ $# -ne 0 ]
            do
                case "$1" in
                    -h|--help)
                        print_help
                        exit 1
                        ;;
                    -l|--list-font)
                        $CONVERT -list font
                        exit 1
                        ;;    
                    -f|--font)
                        FONT_NAME=$2
                        shift 2
                        ;;
                    -s|--size)
                        FONT_SIZE=$2
                        shift 2
                        ;;
                    -y|--y-pos)
                        Y_POS=$2
                        shift 2
                        ;;   
                    --) 
                        shift
                        break
                        ;;
                esac
        done
    else
        echo "Try \`$0 --help' for more information." 1>&2
        exit 1
fi


#font-name
if [[ $FONT_NAME == "" ]]
    then
        echo "$0 --font must be specified." 1>&2
        exit 1
fi        
#font-size
if [[ $FONT_SIZE == "" ]]
    then
        echo "$0 --size must be specified." 1>&2
        exit 1
elif [[  $FONT_SIZE =~ ^[0-9]+([.][0-9]+)?$ ]] || [[  $FONT_SIZE =~ ^-?[0-9]+([.][0-9]+)?$ ]]
    then
        font_size=`echo $FONT_SIZE | sed 's/^-//g'` #convert to positive 
        FONT_SIZE=${font_size%.*}
    else
        echo "$0 --size \`$FONT_SIZE' wrong numerical." 1>&2
        exit 1      
fi
#y-pos default=0
if [[ $Y_POS =~ ^[0-9]+([.][0-9]+)?$ ]] || [[ $Y_POS =~ ^-?[0-9]+([.][0-9]+)?$ ]] #y-pos in pixels
    then
        v=${Y_POS%.*}
        Y_POS=$v
elif [[ $Y_POS =~ ^[0-9]+([.][0-9]+)?%$ ]] #y-pos in percentage
    then
        v=`echo $Y_POS | sed 's/^-//g; s/%$//g'`
        let y_position=(${FONT_SIZE}*${v%.*})/100
        Y_POS=$y_position
elif [[ $Y_POS =~ ^-?[0-9]+([.][0-9]+)?%$ ]] #y-pos in percentage(negative)
    then
        v=`echo $Y_POS | sed 's/^-//g; s/%$//g'`
        let y_position=(${FONT_SIZE}*${v%.*})/100
        Y_POS=`echo "-$y_position"`      
    else
        echo "$0 --y-pos \`$Y_POS' wrong numerical." 1>&2
        exit 1
fi    
#output_file
if [ $# -gt 0 ]
    then
        OUTPUT_PNG=$1
        shift $#
    else
        echo "$0 Output file must be specified." 1>&2
        exit 1
fi

if [[ ! $OUTPUT_PNG =~ .png$ ]]
    then
        echo "$0 \`$OUTPUT_PNG', output file must be PNG." 1>&2
        exit 1            
fi



HEIGHT=$FONT_SIZE
let CEllWIDTH=(${HEIGHT}*6+5)/10
let WIDTH=${CEllWIDTH}*96
echo "Creating ${WIDTH}x${HEIGHT} font bitmap...."
$CONVERT -size ${WIDTH}x${HEIGHT} xc:transparent \
-gravity SouthWest \
-font $FONT_NAME \
-pointsize $FONT_SIZE \
-draw "text 0,$Y_POS ' !\"#\$%&\'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_\`abcdefghijklmnopqrstuvwxyz{|}~?'" \
$OUTPUT_PNG
