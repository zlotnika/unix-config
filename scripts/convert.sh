for f in *.flac; do ffmpeg -i "$f" -aq 1 "${f%flac}mp3"; done
