#!/bin/sh

PATH=/usr/bin:/bin

FLACDIR='/cygdrive/c/Apps/FLAC/win64'
METAFLAC="$FLACDIR/metaflac.exe"
METAFLAC_OPTS='--dont-use-padding --remove --block-type=PICTURE'

for F in "$@"
do
	"$METAFLAC" $METAFLAC_OPTS "$F"
done

