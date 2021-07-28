#!/bin/bash

speed=15
ts_ms=1000
te_ms=1000
font="DejaVuSans.ttf"
fontsize=48
fontcolor="white"

POSITIONAL=()
while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
        -s|--speed)
            speed="$2"
            shift # past argument
            shift # past value
            ;;
        -ts|--time-start)
            ts_ms="$2"
            shift # past argument
            shift # past value
            ;;
        -te|--time-end)
            te_ms="$2"
            shift # past argument
            shift # past value
            ;;
        -fs|--font-size)
            fontsize="$2"
            shift # past argument
            shift # past value
            ;;
        -fc|--font-color)
            fontcolor="$2"
            shift # past argument
            shift # past value
            ;;
        --default)
            DEFAULT=YES
            shift # past argument
            ;;
        *)    # unknown option
            POSITIONAL+=("$1") # save it in an array for later
            shift # past argument
            ;;
    esac
done

valid_integer () {
    if ! [ "${1}" -eq "${1}" ] 2> /dev/null; then
        echo "Invalid ${2}: ${1} ${3} - must be an integer"
        exit 1
    fi

    if [ ${1} -lt ${4} ] ; then
        echo "Invalid ${2}: ${1} ${3} - must be at least ${4} ${3}"
        exit 1
    fi

    if [ ${1} -gt ${5} ] ; then
        echo "Invalid ${2}: ${1} ${3} - must be less than ${5} ${3}"
        exit 1
    fi
}

valid_integer "${speed}" "speed" "wpm" 5 140
valid_integer "${ts_ms}" "time-start" "ms" 0 5000
valid_integer "${te_ms}" "time-end" "ms" 0 10000
valid_integer "${fontsize}" "fontsize" "px" 8 256

set -- "${POSITIONAL[@]}" # restore positional parameters

# ^ - dot
# | - dash
mapping=$(cat <<EOF
a#^|
b#|^^^
c#|^|^
d#|^^
e#^
f#^^|^^
g#||^
h#^^^^
i#^^
j#^|||
k#|^|
l#^|^^
m#||
n#|^
o#|||
p#^||^
q#||^|
r#^|^
s#^^^
t#|
u#^^|
v#^^^|
w#^||
x#|^^|
y#|^||
z#||^^
1#^||||
2#^^|||
3#^^^||
4#^^^^|
5#^^^^^
6#|^^^^
7#||^^^
8#|||^^
9#||||^
0#|||||
\\.#^|^|^|
,#||^^||
?#^^||^^
'#^||||^
!#|^|^||
\\/#|^^|^
(#|^||^
)#|^||^|
&#^|^^^
\\:#|||^^^
;#|^|^|^
=#|^^^|
\\+#^|^|^
-#|^^^^|
_#^^||^|
"#^|^^|^
\\\$#^^^|^^|
@#^||^|^
EOF
)

inp=`echo "$1" | tr -s ' ' | sed 's/[^[:alnum:]\ .,\x27\?!/()&:;=+_"$@-]//g'`

# plain english text
plain="${inp}"

# to lowercase
inp=`echo "$plain" | tr '[A-Z]' '[a-z]'`

# convert to morse code text
for pair in ${mapping} ; do
    letter=$(echo ${pair} | cut -d \# -f 1)
    code=$(echo ${pair} | cut -d \# -f 2)
    out=`echo ${inp} | sed "s/${letter}/${code}#/g"`
    inp="$out"
done

out=`echo ${inp} | sed 's/\^/./g' | sed 's/|/-/g' | sed 's| | / |g' | sed 's/\#/ /g'`

# morse code text, example: ... --- ... / -.-. --.-
morse="${out}"

dtms=`echo "scale=2;1200/${speed}" | bc`
 dts=`echo "scale=3;${dtms}/1000" | bc`
 fps=`echo "scale=0;1000/${dtms} + 1" | bc`
  te=`echo "scale=0;${te_ms}/${dtms}" | bc`
  ts=`echo "scale=0;${ts_ms}/${dtms}" | bc`

echo " - text:      ${plain}"
echo " - morse:     ${morse}"
echo " - speed:     ${speed} wpm"
echo " - dot:       ${dtms} ms"
echo " - fps:       ${fps}"
echo " - font:      ${font}"
echo " - fontsize:  ${fontsize} px"
echo " - fontcolor: ${fontcolor}"

dt=1
cc=0
j=0

rm img*

sub="drawtext=fontfile=${font}:text=''"
sub2="drawtext=fontfile=${font}:text=''"

jj=$(($j + $ts*$dt - 1))
for k in $(seq -f "%05g" $j $jj); do cp ../cat0-final.png ./img$k.png; done
j=$(($jj + 1))
jj0=$j
for (( i=0; i<${#morse}; i++ )); do
    j0=$j
    c="${morse:$i:1}"
    if [ "$c" = "." ] ; then
        jj=$(($j + $dt - 1))
        for k in $(seq -f "%05g" $j $jj); do cp ../cat1-final.png ./img$k.png; done
        j=$(($jj + 1))
        jj=$(($j + $dt - 1))
        for k in $(seq -f "%05g" $j $jj); do cp ../cat0-final.png ./img$k.png; done
    elif [ "$c" = "-" ] ; then
        jj=$(($j + 3*$dt - 1))
        for k in $(seq -f "%05g" $j $jj); do cp ../cat1-final.png ./img$k.png; done
        j=$(($jj + 1))
        jj=$(($j + $dt - 1))
        for k in $(seq -f "%05g" $j $jj); do cp ../cat0-final.png ./img$k.png; done
    elif [ "$c" = "/" ] ; then
        jj=$(($j + 0*$dt - 1))
        for k in $(seq -f "%05g" $j $jj); do cp ../cat0-final.png ./img$k.png; done
    else
        jj=$(($j + 2*$dt - 1))
        for k in $(seq -f "%05g" $j $jj); do cp ../cat0-final.png ./img$k.png; done
    fi
    ii=$(($i + 1))
    j=$(($jj + 1))

    t0=`echo "scale=3;${j0}*${dts}" | bc`
    t1=`echo "scale=3;${j}*${dts}" | bc`
    if [ "$ii" = "${#morse}" ] ; then
        t1=9999
    fi
    sub="${sub}, drawtext=fontfile=${font}:text='${morse:0:$ii}':fontcolor=${fontcolor}:fontsize=${fontsize}:shadowx=2:shadowy=2:box=1:boxcolor=black@1.0:boxborderw=5:x=(w)/6:y=4*(h-text_h)/5:enable='between(t,${t0},${t1})'"

    if [ "$c" = " " ] ; then
        t0=`echo "scale=3;${jj0}*${dts}" | bc`
        t1=`echo "scale=3;${j}*${dts}" | bc`
        cc=$(($cc + 1))
        if [ "$cc" = "${#plain}" ] ; then
            sub3="hue=H=20*PI*t:s=cos(2*PI*t)+5+t:enable='between(t,0.75,${t1})'"
            t1=9999
        fi
        sub2="${sub2}, drawtext=fontfile=${font}:text='${plain:0:$cc}':fontcolor=${fontcolor}:fontsize=${fontsize}:shadowx=2:shadowy=2:box=1:boxcolor=black@1.0:boxborderw=5:x=(w)/6:y=5*(h)/6:enable='between(t,${t0},${t1})'"
        jj0=$j
    elif [ "$c" = "/" ] ; then
        cc=$(($cc - 1))
    fi
done

jj=$(($j + $te*$dt - 1))
for k in $(seq -f "%05g" $j $jj); do cp ../cat0-final.png ./img$k.png; done
j=$(($jj + 1))

#ffmpeg -hide_banner -loglevel error -y -r 1000/${dtms} -i img%05d.png -c:v libx264 -pix_fmt yuv420p -vf "${sub},${sub2}",${sub3} -r ${fps} out.mp4
ffmpeg -hide_banner -loglevel error -y -r 1000/${dtms} -i img%05d.png -c:v libx264 -pix_fmt yuv420p -vf "${sub},${sub2}" -r ${fps} out.mp4

os=`echo "scale=3;$dts*($ts-1)" | bc`
os=`LANG=C LC_NUMERIC=C printf "%06.3f" $os`

curl -sS "https://ggmorse-to-file.ggerganov.com/?m=${plain}&f=500&w=${speed}&s=20000" --output out0.wav
curl -sS "https://ggmorse-to-file.ggerganov.com/?m=${plain}&f=700&w=${speed}&s=20000" --output out1.wav
curl -sS "https://ggmorse-to-file.ggerganov.com/?m=${plain}&f=1500&w=${speed}&s=20000" --output out2.wav
curl -sS "https://ggmorse-to-file.ggerganov.com/?m=${plain}&f=2100&w=${speed}&s=20000" --output out3.wav

ffmpeg -hide_banner -loglevel error -y -i out0.wav -i out1.wav -i out2.wav -i out3.wav -filter_complex amix=inputs=4:duration=first:dropout_transition=0 out.wav
ffmpeg -hide_banner -loglevel error -y -i out.mp4 -itsoffset 00:00:${os} -i out.wav -map 0:0 -map 1:0 -c:v copy -c:a aac -async 1 final.mp4
