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

inp=`echo "$@" | tr -s ' ' | sed 's/[^[:alnum:]\ .,\x27\?!/()&:;=+_"$@-]//g' | tr '[A-Z]' '[a-z]'`
echo $inp

for pair in $mapping ; do
    letter=$(echo $pair | cut -d \# -f 1)
    code=$(echo $pair | cut -d \# -f 2)
    out=`echo $inp | sed "s/$letter/$code#/g"`
    inp="$out"
done

out=`echo $inp | sed 's/\^/./g' | sed 's/|/-/g' | sed 's| | / |g' | sed 's/\#/ /g'`
echo $out
