# morse-meme

Procedural generation of Morse Code memes in Bash

Demo: https://meme.ggerganov.com

## dependencies

```bash
sudo apt-get install ffmpeg sox
```

## using

```bash
cd v0
./gen.sh
Usage: ./gen.sh [options] "meme text"

Options:
-s n          Tx speed in WPM
-ts n         start pause in ms
-te n         end pause in ms
-fs n         font size in px
-fc color     font color (e.g 0xffffff)
-nc           hide morse code text
-np           hide plain text
-n type       add background noise
-nv n         noise volume [percent 0-100]
-f            color flashes
-st type      sound type

Examples:
      ./gen.sh "test"
      ./gen.sh -s 50 "2 fast"
      ./gen.sh -ts 3000 -s 50 "pause"
      ./gen.sh -fs 48 "big"

./gen.sh "CHEEZBURGER"

vlc final.mp4
```

https://user-images.githubusercontent.com/1991296/127513983-c6470008-6f95-4666-a745-76962ac7d2d5.mp4
