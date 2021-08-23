#!/bin/bash

speed=35
ts_ms=1000
te_ms=2000
font="DejaVuSans.ttf"
fontsize=16
fontcolor="0xffffff"
fontba=100
textx=10
texty=85
nocode=
noplain=
img=cat0-512
noise=
noisevolume=75
flash=
sound="random"

rand () {
    echo $((1 + $RANDOM % ${1}))
}

print_usage () {
    echo "Usage: ${0} [options] \"meme text\""
    echo ""
    echo "Options:"
    echo "-i fname      image filename prefix"
    echo "-s n          Tx speed in WPM"
    echo "-ts n         start pause in ms"
    echo "-te n         end pause in ms"
    echo "-fs n         font size in px"
    echo "-fc color     font color (e.g 0xffffff)"
    echo "-fba n        font background alpha in %"
    echo "-tx n         text x pos in %"
    echo "-ty n         text y pos in %"
    echo "-nc           hide morse code text"
    echo "-np           hide plain text"
    echo "-n type       add background noise"
    echo "-nv n         noise volume [percent 0-100]"
    echo "-f            color flashes"
    echo "-st type      sound type"
    echo ""
    echo "Examples:"
    echo "      ${0} \"test\""
    echo "      ${0} -i doge0-512 \"much wow\""
    echo "      ${0} -s 50 \"2 fast\""
    echo "      ${0} -ts 3000 -s 50 \"pause\""
    echo "      ${0} -fs 48 \"big\""
}

POSITIONAL=()
while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
        -i|--image)
            img="$2"
            shift
            shift
            ;;
        -s|--speed)
            speed="$2"
            shift
            shift
            ;;
        -ts|--time-start)
            ts_ms="$2"
            shift
            shift
            ;;
        -te|--time-end)
            te_ms="$2"
            shift
            shift
            ;;
        -fs|--font-size)
            fontsize="$2"
            shift
            shift
            ;;
        -fc|--font-color)
            fontcolor="$2"
            shift
            shift
            ;;
        -fba|--font-background-alpha)
            fontba="$2"
            shift
            shift
            ;;
        -tx|--text-x)
            textx="$2"
            shift
            shift
            ;;
        -ty|--text-y)
            texty="$2"
            shift
            shift
            ;;
        -nc|--no-code)
            nocode=YES
            shift
            ;;
        -np|--no-plain)
            noplain=YES
            shift
            ;;
        -n|--noise)
            noise="$2"
            shift
            shift
            ;;
        -nv|--noise-volume)
            noisevolume="$2"
            shift
            shift
            ;;
        -st|--sound-type)
            sound="$2"
            shift
            shift
            ;;
        -f|--flash)
            flash=YES
            shift
            ;;
        -h|--help)
            print_help=YES
            shift
            ;;
        *)
            POSITIONAL+=("$1") # save it in an array for later
            shift
            ;;
    esac
done

if [ ${print_help} ] ; then
    print_usage
    exit 0
fi

valid_image () {
    if ! [ -f ${1} ] ; then
        echo "Cannot find '${1}'"
        exit 1
    fi

    if ! [[ $(file ${1} | grep PNG) = *PNG* ]] ; then
        echo "Invalid image '${1}' - not in PNG format"
        exit 1
    fi
}

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

valid_color () {
    if ! echo $1 | grep -G -q "^0x[0-9,a-f,A-F][0-9,a-f,A-F][0-9,a-f,A-F][0-9,a-f,A-F][0-9,a-f,A-F][0-9,a-f,A-F]$" ; then
        echo "Invalid color: ${1}"
        exit 1
    fi
}

valid_option () {
    if [ "${1}" ] && ! [[ ${3} =~ (^|[[:space:]])${1}($|[[:space:]]) ]] ; then
        echo "Invalid ${2}: ${1}, valid options are: ${3}"
        exit 1
    fi
}

img0="${img}-0.png"
img1="${img}-1.png"

valid_image ${img0}
valid_image ${img1}

valid_integer "${speed}" "speed" "wpm" 5 140
valid_integer "${ts_ms}" "time-start" "ms" 0 5000
valid_integer "${te_ms}" "time-end" "ms" 0 10000
valid_integer "${fontsize}" "fontsize" "px" 8 256
valid_integer "${textx}" "textx" "%" 0 100
valid_integer "${texty}" "texty" "%" 0 100

valid_color   "${fontcolor}"
valid_integer "${fontba}" "font-background-alpha" "%" 0 100

valid_option "${noise}" "noise" "low mid high helicopter truck submarine"
valid_integer "${noisevolume}" "noise volume" "" 0 100

valid_option "${sound}" "sound" "random"

set -- "${POSITIONAL[@]}" # restore positional parameters

# ^ - dot
# | - dash
read -r -d '' mapping << EOM
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
EOM

read -r -d '' mapping_latin << EOM
а#a
б#b
ц#c
д#d
е#e
ф#f
г#g
х#h
и#i
й#j
к#k
л#l
м#m
н#n
о#o
п#p
щ#q
р#r
с#s
т#t
у#u
ж#v
в#w
ь#x
ъ#y
з#z
EOM

#inp=$(echo "$1" | tr -s ' ' | sed 's/[^[:alnum:]\ .,\x27\?!/()&:;=+_"$@-]//g')
inp=$(echo "$1" | tr -s ' ' | sed 's/[^[:alnum:] .,?!/();=_"@-]//g')

# plain english text
plain="${inp}"

if [ "${plain}" = "" ] ; then
    print_usage
    exit 1
fi

# to lowercase
#inp=$(echo "${plain}" | tr [:upper:] [:lower:])
inp=$(echo "${plain}" | sed 's/.*/\L&/')

# convert to latin
for pair in ${mapping_latin} ; do
    letter=$(echo ${pair} | cut -d \# -f 1)
    code=$(echo ${pair} | cut -d \# -f 2)
    out=$(echo ${inp} | sed "s/${letter}/${code}/g")
    inp="${out}"
done

plain_latin=${inp}

# convert to morse code text
for pair in ${mapping} ; do
    letter=$(echo ${pair} | cut -d \# -f 1)
    code=$(echo ${pair} | cut -d \# -f 2)
    out=$(echo ${inp} | sed "s/${letter}/${code}#/g")
    inp="${out}"
done

out=$(echo ${inp} | sed 's/\^/./g' | sed 's/|/-/g' | sed 's| | / |g' | sed 's/\#/ /g')

# morse code text, example: ... --- ... / -.-. --.-
morse="${out}"

dtms=$(echo "scale=2;1200/${speed}" | bc)
 dts=$(echo "scale=3;${dtms}/1000" | bc)
 fps=$(echo "scale=0;1000/${dtms} + 1" | bc)
  te=$(echo "scale=0;${te_ms}/${dtms}" | bc)
  ts=$(echo "scale=0;${ts_ms}/${dtms}" | bc)
 fba=$(echo "scale=2;${fontba}/100" | bc)

echo " - image:         ${img}"
echo " - text:          ${plain}"
echo " - morse:         ${morse}"
echo " - speed:         ${speed} wpm"
echo " - dot:           ${dtms} ms"
echo " - fps:           ${fps}"
echo " - font:          ${font}"
echo " - fontsize:      ${fontsize} px"
echo " - fontcolor:     ${fontcolor}"
echo " - fontba:        ${fontba} %"
echo " - textx:         ${textx} %"
echo " - texty:         ${texty} %"
echo " - nocode:        ${nocode}"
echo " - noplain:       ${noplain}"
echo " - timestart:     ${ts_ms} ms"
echo " - timeend:       ${te_ms} ms"
echo " - noise:         ${noise}"
echo " - noisevolume:   ${noisevolume}"
echo " - flash:         ${flash}"

dt=1
cc=0
j=0

dst="/tmp/morse-meme-wip"
mkdir -p ${dst}
rm ${dst}/*

sub="drawtext=fontfile=${font}:text=''"
sub2="drawtext=fontfile=${font}:text=''"
sub3="drawtext=fontfile=${font}:text=''"

jj=$(($j + $ts*$dt - 1))
for k in $(seq -f "%05g" $j $jj); do cp ${img0} ${dst}/img$k.png; done
j=$(($jj + 1))
jj0=$j
for (( i=0; i<${#morse}; i++ )); do
    j0=$j
    t0=$(echo "scale=3;${j0}*${dts}" | bc)

    c="${morse:$i:1}"
    if [ "$c" = "." ] ; then
        jj=$(($j + $dt - 1))
        for k in $(seq -f "%05g" $j $jj); do cp ${img1} ${dst}/img$k.png; done
        j=$(($jj + 1))

        t1=$(echo "scale=3;${j}*${dts}" | bc)
        [ "${flash}" ] && sub3="${sub3}, hue=H=20*PI*t:s=cos(2*PI*t)+5+t:enable='between(t,${t0},${t1})'"

        jj=$(($j + $dt - 1))
        for k in $(seq -f "%05g" $j $jj); do cp ${img0} ${dst}/img$k.png; done
    elif [ "$c" = "-" ] ; then
        jj=$(($j + 3*$dt - 1))
        for k in $(seq -f "%05g" $j $jj); do cp ${img1} ${dst}/img$k.png; done
        j=$(($jj + 1))

        t1=$(echo "scale=3;${j}*${dts}" | bc)
        [ "${flash}" ] && sub3="${sub3}, hue=H=20*PI*t:s=cos(2*PI*t)+5+t:enable='between(t,${t0},${t1})'"

        jj=$(($j + $dt - 1))
        for k in $(seq -f "%05g" $j $jj); do cp ${img0} ${dst}/img$k.png; done
    elif [ "$c" = "/" ] ; then
        jj=$(($j + 0*$dt - 1))
        for k in $(seq -f "%05g" $j $jj); do cp ${img0} ${dst}/img$k.png; done
    else
        jj=$(($j + 2*$dt - 1))
        for k in $(seq -f "%05g" $j $jj); do cp ${img0} ${dst}/img$k.png; done
    fi
    ii=$(($i + 1))
    j=$(($jj + 1))

    t1=$(echo "scale=3;${j}*${dts}" | bc)
    if [ "$ii" = "${#morse}" ] ; then
        t1=9999
    fi
    if ! [ "${nocode}" ] ; then
        sub="${sub}, drawtext=fontfile=${font}:text='${morse:0:$ii}':fontcolor=${fontcolor}:fontsize=${fontsize}:shadowx=2:shadowy=2:box=1:boxcolor=black@${fba}:boxborderw=5:x=${textx}*main_w/100:y=${texty}*main_h/100:enable='between(t,${t0},${t1})'"
    fi

    if [ "$c" = " " ] ; then
        t0=$(echo "scale=3;${jj0}*${dts}" | bc)
        t1=$(echo "scale=3;${j}*${dts}" | bc)
        cc=$(($cc + 1))
        if [ "$cc" = "${#plain}" ] ; then
            #sub3="hue=H=20*PI*t:s=cos(2*PI*t)+5+t:enable='between(t,0.75,${t1})'"
            t1=9999
        fi
        if ! [ "${noplain}" ] ; then
            sub2="${sub2}, drawtext=fontfile=${font}:text='${plain:0:$cc}':fontcolor=${fontcolor}:fontsize=${fontsize}:shadowx=2:shadowy=2:box=1:boxcolor=black@${fba}:boxborderw=5:x=${textx}*main_w/100:y=${texty}*main_h/100 + 1.25*${fontsize}:enable='between(t,${t0},${t1})'"
        fi
        jj0=$j
    elif [ "$c" = "/" ] ; then
        cc=$(($cc - 1))
    fi
done

jj=$(($j + $te*$dt - 1))
for k in $(seq -f "%05g" $j $jj); do cp ${img0} ${dst}/img$k.png; done
j=$(($jj + 1))

ffmpeg -hide_banner -loglevel error -y -r 1000/${dtms} -i ${dst}/img%05d.png -c:v libx264 -pix_fmt yuv420p -vf "${sub},${sub2},${sub3}" -r ${fps} ${dst}/out.mp4

ls=$(echo "scale=3;${dts}*(${j}-1)" | bc)
ls=$(LANG=C LC_NUMERIC=C printf "%.3f" ${ls})
os=$(echo "scale=3;${dts}*(${ts}-1)" | bc)
os=$(LANG=C LC_NUMERIC=C printf "%.3f" ${os})
osn=$(echo "scale=3;0.5*${dts}*(${ts}-1)" | bc)
osn=$(LANG=C LC_NUMERIC=C printf "%.3f" ${osn})
osms=$(echo "scale=3;${dtms}*(${ts}-1)" | bc)
osms=$(LANG=C LC_NUMERIC=C printf "%.3f" ${osms})

echo " - start:     ${os} s / ${osms} ms"
echo " - length:    ${ls} s"

nf=$(rand 10)
mix=""

for f in `seq 0 1 ${nf}` ; do
    freq=$((200 + $(rand 1500)))
    vol=$((20 + $(rand 80)))
    curl -sS "https://ggmorse-to-file.ggerganov.com/?m=${plain_latin}&f=${freq}&w=${speed}&s=48000&v=${vol}" --output ${dst}/out${f}.wav
    mix="${mix} '|sox ${dst}/out${f}.wav -p'"
done

eval sox --norm -m ${mix} ${dst}/out.wav

#curl -sS "https://ggmorse-to-file.ggerganov.com/?m=${plain_latin}&f=500&w=${speed}&s=48000&v=100" --output ${dst}/out0.wav
#
#rand () {
#    echo $((1 + $RANDOM % ${1}))
#}
#
#nr=$(rand 3)
#nh=$(rand 6)
#echo "repeat    : ${nr}"
#echo "harmonics : ${nh}"
#
#for k in `seq 1 1 ${nr}` ; do
#    mix="'|sox ${dst}/out0.wav -p gain 0'"
#    for i in `seq 1 1 ${nh}` ; do
#        p=$(rand 2000)
#        g=$((10 + $(rand 10)))
#        mix="${mix} '|sox ${dst}/out0.wav -p pitch ${p} gain -${g}'"
#    done
#    eval sox --norm -m ${mix} ${dst}/out.wav
#    cp ${dst}/out.wav ${dst}/out0.wav
#done

#sox --norm -m "|sox ${dst}/out0.wav -p gain 0" "|sox ${dst}/out0.wav -p pitch 400 gain -6" "|sox ${dst}/out0.wav -p pitch 600 gain -4" "|sox ${dst}/out0.wav -p pitch 800 gain -2" ${dst}/out.wav
#ffmpeg -hide_banner -loglevel error -y -i ${dst}/out0.wav -i ${dst}/out1.wav -i ${dst}/out2.wav -i ${dst}/out3.wav -filter_complex amix=inputs=4:duration=first:dropout_transition=0 ${dst}/out.wav

if [ "${noise}" == "low" ] ; then
    sox -n ${dst}/noise.wav synth ${ls} brownnoise band -n 155 95 tremolo 1.3 10.0 fade q ${osn} ${ls} 1
elif [ "${noise}" == "mid" ] ; then
    sox -n ${dst}/noise.wav synth ${ls} brownnoise band -n 500 125 tremolo 1.3 10.0 fade q ${osn} ${ls} 1
elif [ "${noise}" == "high" ] ; then
    sox -n ${dst}/noise.wav synth ${ls} brownnoise band -n 2000 500 tremolo 1.3 10.0 fade q ${osn} ${ls} 1
elif [ "${noise}" == "helicopter" ] ; then
    sox -m "|sox -n -p synth ${ls} brownnoise band -n 500 50 tremolo 1.3 10.0 fade q ${osn} ${ls} 1" "|sox -n -p synth ${ls} pinknoise band -n 500 250 tremolo 10.0 90.0 fade q ${osn} ${ls} 1 gain 2" ${dst}/noise.wav
elif [ "${noise}" == "truck" ] ; then
    sox -m "|sox -n -p synth ${ls} brownnoise band -n 500 125 tremolo 1.3 20.0 fade q ${osn} ${ls} 1" "|sox -n -p synth ${ls} brownnoise band -n 155 95 tremolo 4.3 50.0 fade q ${osn} ${ls} 1 gain 2" ${dst}/noise.wav
elif [ "${noise}" == "submarine" ] ; then
    sox -m "|sox -n -p synth ${ls} brownnoise band -n 500 125 tremolo 4.3 50.0 fade q ${osn} ${ls} 1 gain 2" "|sox -n -p synth ${ls} brownnoise band -n 155 95 tremolo 1.3 20.0 fade q ${osn} ${ls} 1 gain 1" ${dst}/noise.wav
else
    sox -n ${dst}/noise.wav synth ${ls}
    noisevolume=0
fi

noisevolume_db=$(echo "scale=3;20*l(${noisevolume}/100)" | bc -l)

sox -m "|sox ${dst}/out.wav -p pad ${os}" "|sox ${dst}/noise.wav -p gain ${noisevolume_db}" ${dst}/out1.wav
#ffmpeg -hide_banner -loglevel error -y -i ${dst}/noise.wav -i ${dst}/out.wav -filter_complex "[0]volume=${noisevolume_f}[a];[1]adelay=${osms}|${osms}[b];[a][b]amix=inputs=2:duration=first:dropout_transition=10" ${dst}/out.wav

ffmpeg -hide_banner -loglevel error -y -i ${dst}/out.mp4 -itsoffset 00:00:00 -i ${dst}/out1.wav -map 0:0 -map 1:0 -c:v copy -c:a aac -async 1 final.mp4

echo " - size:      $(du -h final.mp4 | awk '{print $1}')"
