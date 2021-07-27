# Call this script with the name of a single image
# e.g. ./intentions-wallpaper.sh "myimage.jpg"

# Install ImageMagick for all image tools: https://imagemagick.org/
# YMMV - Check your alias location with e.g. 'which convert'
alias convert=/usr/local/bin/convert
alias identify=/usr/local/bin/identify

cd ~/bmwallpapers/ # Add full path to your wallpapers directory
image=$1
intention=$(cat ./intentions.txt)
efforts=$(cat ./main_efforts.txt)

# Get dominant colour from wallpaper image
domcol=$(convert $image -scale 50x50! -depth 8 +dither -colors 8 -format "%c" histogram:info: |\
sed -n 's/^[ ]*\(.*\):.*[#]\([0-9a-fA-F]*\) .*$/\1,#\2/p' | sort -r -n -k 1 -t "," | head -1 | sed 's/.*,//')
# Get second dominant colour from wallpaper image
seccol=$(convert $image -scale 50x50! -depth 8 +dither -colors 8 -format "%c" histogram:info: |\
sed -n 's/^[ ]*\(.*\):.*[#]\([0-9a-fA-F]*\) .*$/\1,#\2/p' | sort -r -n -k 1 -t "," | head -2 | tail -1 | sed 's/.*,//')

# Get image dimensions
dims=$(identify -format "%wx%h" $image)
w=$(echo $dims | sed 's/x[0-9]*//')
h=$(echo $dims | sed 's/^[0-9]*x//')

# Set box dimensions - "Intentions rectangle"
bh=$(bc --mathlib <<< "$h * 0.1")
bw=$(bc --mathlib <<< "$w * 0.06")
bw1=$(bc --mathlib <<< "$w * 0.34")
bh1=$(bc --mathlib <<< "$h * 0.15")

# Text dimensions - "Intentions box"
# Height / width of black opaque rectangle
th=$(bc --mathlib <<< "$h * 0.13")
tw=$(bc --mathlib <<< "$w * 0.07")
# Text pointsize
points=$(bc --mathlib <<< "$w * 0.01")
points=${points%.*}

# Set box dimensions - main efforts
meh=$(bc --mathlib <<< "$h * 0.17")
mew=$bw
mew1=$(bc --mathlib <<< "$w * 0.25")
meh1=$(bc --mathlib <<< "$h * 0.3")

# Text dimensions - main efforts
meth=$(bc --mathlib <<< "$h * 0.2")

# Combine images - intentions rectangle, intentions text, main efforts rectangle, main efforts text, 
convert $image 	\
	-fill '#0008' -draw "roundrectangle $bw,$bh $bw1,$bh1, 10,10" \
	-font Palatino-Bold -pointsize $points -fill white -annotate +$tw+$th "Today's intentions: $intention" \
	-fill '#0008' -draw "roundrectangle $mew,$meh $mew1,$meh1, 10,10" 	\
	-pointsize $points -fill white 	-annotate +$tw+$meth "Main efforts:\n$efforts" \
	"./annotated_$1"

echo "$(date), $intention" >> ~/intentions_log.txt