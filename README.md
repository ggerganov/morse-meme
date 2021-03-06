
# morse-meme

Procedural generation of Morse Code memes in Bash

Demo: https://meme.ggerganov.com

## dependencies

```bash
sudo apt-get install ffmpeg sox
```

## using

```bash
./gen.sh
Usage: ./gen.sh [options] "meme text"

Options:
-i fname      image filename prefix
-s n          Tx speed in WPM
-ts n         start pause in ms
-te n         end pause in ms
-fs n         font size in px
-fc color     font color (e.g 0xffffff)
-fba n        font background alpha in %
-tx n         text x pos in %
-ty n         text y pos in %
-nc           hide morse code text
-np           hide plain text
-n type       add background noise
-nv n         noise volume [percent 0-100]
-f            color flashes
-st type      sound type

Examples:
      ./gen.sh "test"
      ./gen.sh -i doge0-512 "much wow"
      ./gen.sh -s 50 "2 fast"
      ./gen.sh -ts 3000 -s 50 "pause"
      ./gen.sh -fs 48 "big"
```

## examples

```bash
./gen.sh "CHEEZBURGER"
```

https://user-images.githubusercontent.com/1991296/128639234-fde42de5-aae4-478b-966b-f5ccd898fd5e.mp4

```bash
./gen.sh -i doge0-512 "many wow" -s 20 -fs 24 -tx 45 -ty 12 -fc 0xff00ff -nc -fba 0
```

https://user-images.githubusercontent.com/1991296/128639139-2b246c43-464f-4493-9222-da89b94353c8.mp4
