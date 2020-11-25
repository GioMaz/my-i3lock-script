#!/bin/sh

# LABEL
LABEL="Bruh"

# TAKE A SCREENSHOT
SCREENSHOT=/tmp/screen.png
scrot $SCREENSHOT

# GET PREVALENT COLOR (HEX)
convert $SCREENSHOT -gravity center -crop 300x80+0+0 /tmp/center.png
HEX=$(convert /tmp/center.png -scale 50x50! -depth 8 +dither -colors 8 -format "%c" histogram:info: | \
		sed -n 's/^[ ]*\(.*\):.*[#]\([0-9a-fA-F]*\) .*$/\1,#\2/p' | sort -r -n -k 1 -t "," | head -n 1 | cut -d "," -f2)


HEX="${HEX//#}"

# CONVERT TO RGB
RGB=$(printf "%d %d %d\n" 0x${HEX:0:2} 0x${HEX:2:2} 0x${HEX:4:2})
R=$(echo $RGB | awk '{print $1;}')
G=$(echo $RGB | awk '{print $2;}')
B=$(echo $RGB | awk '{print $3;}')
SR=$(echo "$R*0.2126" | bc)
SG=$(echo "$R*0.7152" | bc)
SB=$(echo "$R*0.0722" | bc)
LUMA=$(echo "$SR+$SG+$SG" | bc)
LUMA=${LUMA%.*}

# USE DARK OR LIGHT TEXT
echo "$LUMA"
if [ "$LUMA" -lt 396 ]
then
  echo "BIANCO"
  convert $SCREENSHOT \
  	-filter Gaussian -resize 50% -define filter:sigma=5 -resize 200% \
  	-font /usr/share/fonts/OpenSans/OpenSans-Light.ttf \
  	-gravity Center \
  	-pointsize 40 \
  	-fill white \
	-annotate 0 "$LABEL" \
  	$SCREENSHOT
else
  echo "NERO"
  convert $SCREENSHOT \
  	-filter Gaussian -resize 50% -define filter:sigma=5 -resize 200% \
  	-font /usr/share/fonts/OpenSans/OpenSans-Light.ttf \
  	-gravity Center \
  	-pointsize 40 \
  	-fill black \
	-annotate 0 "$LABEL" \
  	$SCREENSHOT
fi

i3lock -u --ignore-empty-password --show-failed-attempts --nofork --image $SCREENSHOT
rm $SCREENSHOT
rm /tmp/center.png

#  TEXT SHADOW
#  convert $SCREENSHOT \
#  	-font /usr/share/fonts/OpenSans/OpenSans-Light.ttf \
#  	-gravity Center \
#  	-pointsize 40 \
#  	-fill "#333333" \
#  	-annotate +0+0 'Ciao, Giovanni' \
#  	-filter Gaussian -resize 50% -define filter:sigma=5 -resize 200% \
#  	-fill white \
#  	-annotate 0 'Ciao, Giovanni' \
#  	$SCREENSHOT
