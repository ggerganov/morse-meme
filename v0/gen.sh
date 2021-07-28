#!/bin/bash

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

inp=`echo "$1" | tr -s ' ' | sed 's/[^[:alnum:]\ .,\x27\?!/()&:;=+_"$@-]//g' | tr '[A-Z]' '[a-z]'`
p="$inp"

for pair in $mapping ; do
    letter=$(echo $pair | cut -d \# -f 1)
    code=$(echo $pair | cut -d \# -f 2)
    out=`echo $inp | sed "s/$letter/$code#/g"`
    inp="$out"
done

out=`echo $inp | sed 's/\^/./g' | sed 's/|/-/g' | sed 's| | / |g' | sed 's/\#/ /g'`
t="$out"

wpm=15
dt=1
j=0
ts=20
te=30

dtms=`echo "scale=2;1200/${wpm}" | bc`
echo $dtms
dts=`echo "scale=3;${dtms}/1000" | bc`
echo $dts
fps=`echo "scale=2;1000/${dtms}" | bc`
echo $fps

echo $t

rm img*

jj=$(($j + $ts*$dt - 1))
for k in $(seq -f "%05g" $j $jj); do cp ../cat0-final.png ./img$k.png; done
j=$(($jj + 1))

sub="drawtext=fontfile=/path/to/font.ttf:text='':fontcolor=white:fontsize=48:box=1:boxcolor=black@0.5:boxborderw=5:x=(w)/6:y=4*(h-text_h)/5:enable='between(t,0,0)'"
sub2="drawtext=fontfile=/path/to/font.ttf:text='':fontcolor=white:fontsize=48:box=1:boxcolor=black@0.5:boxborderw=5:x=(w)/6:y=4*(h-text_h)/5:enable='between(t,0,0)'"

cc=0

jj0=$j
for (( i=0; i<${#t}; i++ )); do
    j0=$j
    c="${t:$i:1}"
    echo $c;
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
    if [ "$ii" = "${#t}" ] ; then
        t1=9999
    fi
    sub="${sub}, drawtext=fontfile=/path/to/font.ttf:text='${t:0:$ii}':fontcolor=white:fontsize=48:box=1:boxcolor=black@1.0:boxborderw=5:x=(w)/6:y=4*(h-text_h)/5:enable='between(t,${t0},${t1})'"

    if [ "$c" = " " ] ; then
        t0=`echo "scale=3;${jj0}*${dts}" | bc`
        t1=`echo "scale=3;${j}*${dts}" | bc`
        cc=$(($cc + 1))
        if [ "$cc" = "${#p}" ] ; then
            t1=9999
        fi
        sub2="${sub2}, drawtext=fontfile=/path/to/font.ttf:text='${p:0:$cc}':fontcolor=white:fontsize=48:box=1:boxcolor=black@1.0:boxborderw=5:x=(w)/6:y=4*(h+text_h)/5:enable='between(t,${t0},${t1})'"
        jj0=$j
    elif [ "$c" = "/" ] ; then
        cc=$(($cc - 1))
    fi
done

jj=$(($j + $te*$dt - 1))
for k in $(seq -f "%05g" $j $jj); do cp ../cat0-final.png ./img$k.png; done
j=$(($jj + 1))

echo $sub
echo $sub2
ffmpeg -y -r 1000/${dtms} -i img%05d.png -c:v libx264 -pix_fmt yuv420p -vf "${sub},${sub2}" -r 25 out.mp4

os=`echo "scale=3;$dts*($ts-1)" | bc`
os=`LANG=C LC_NUMERIC=C printf "%06.3f" $os`
echo "XXX $os"

curl -sS "https://ggmorse-to-file.ggerganov.com/?m=${p}&f=500&w=${wpm}&s=20000" --output out0.wav
curl -sS "https://ggmorse-to-file.ggerganov.com/?m=${p}&f=700&w=${wpm}&s=20000" --output out1.wav
curl -sS "https://ggmorse-to-file.ggerganov.com/?m=${p}&f=1500&w=${wpm}&s=20000" --output out2.wav
curl -sS "https://ggmorse-to-file.ggerganov.com/?m=${p}&f=2100&w=${wpm}&s=20000" --output out3.wav

#curl -sS "https://ggmorse-to-file.ggerganov.com/?m=${p}&f=300&w=${wpm}" --output out0.wav
#curl -sS "https://ggmorse-to-file.ggerganov.com/?m=${p}&f=400&w=${wpm}" --output out1.wav
#curl -sS "https://ggmorse-to-file.ggerganov.com/?m=${p}&f=500&w=${wpm}" --output out2.wav
#curl -sS "https://ggmorse-to-file.ggerganov.com/?m=${p}&f=750&w=${wpm}" --output out3.wav

ffmpeg -y -i out0.wav -i out1.wav -i out2.wav -i out3.wav -filter_complex amix=inputs=4:duration=first:dropout_transition=0 out.wav

ffmpeg -y -i out.mp4 -itsoffset 00:00:${os} -i out.wav -map 0:0 -map 1:0 -c:v copy -c:a aac -async 1 final.mp4

#ffmpeg -r $r -i img%05d.png -c:v libx264 -vf fps=25 -pix_fmt yuv420p -vf "\
#drawtext=fontfile=/path/to/font.ttf:text='a':fontcolor=white:fontsize=32:box=1:boxcolor=black@0.5:boxborderw=5:x=(w-text_w)/2:y=4*(h-text_h)/5:enable='between(t,1,2.5)', \
#drawtext=fontfile=/path/to/font.ttf:text='b':fontcolor=white:fontsize=32:box=1:boxcolor=black@0.5:boxborderw=5:x=(w-text_w)/2:y=4*(h-text_h)/5:enable='between(t,2.7,4.0)', \
#drawtext=fontfile=/path/to/font.ttf:text='c':fontcolor=white:fontsize=32:box=1:boxcolor=black@0.5:boxborderw=5:x=(w-text_w)/2:y=4*(h-text_h)/5:enable='between(t,5.7,7.0)'" \
#out.mp4


