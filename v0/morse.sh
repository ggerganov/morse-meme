#!/bin/bash

##
## Very Simple Morse Code Translator
##


input=$HOME/.smorse.input.$$
output=$HOME/.smorse.output.$$

mapping=$(cat <<EOF
a:.-
b:-...
c:-.-.
d:-..
e:.
f:..-..
g:--.
h:....
i:..
j:.---
k:-.-
l:.-..
m:--
n:-.
o:---
p:.--.
q:--.-
r:.-.
s:...
t:-
u:..-
v:...-
w:.--
x:-..-
y:-.--
z:--..
EOF
)

if [ -z "$*" ] ; then
  cat > $input
else
  echo "$@" > $input
fi

tr '[A-Z]' '[a-z]' < $input > $output
mv $output $input

sed 's| | / |g' < $input > $output
mv $output $input

for pair in  $mapping ; do
  letter=$(echo $pair | cut -d : -f 1)
  code=$(echo $pair | cut -d : -f 2)
  sed "s/$letter/$code /g" < $input > $output
  mv $output $input
 done

cat $input
