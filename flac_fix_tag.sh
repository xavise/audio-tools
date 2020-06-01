#!/bin/sh

PATH=/usr/bin:/bin

FLACDIR='/cygdrive/c/Apps/FLAC/win64'
METAFLAC="$FLACDIR/metaflac.exe"
METAFLAC_OPTS='--no-utf8-convert'



usage () {
	echo "Usage: $0 {tag_name} {tag_value} {file} [...]" 1>&2
	exit 1
}



TAG_NAME="$1"
TAG_VALUE="$2"
[ -z "$TAG_NAME" ] && usage
[ -z "$TAG_VALUE" ] && usage
shift 2

for F in "$@"
do
	echo "$F"
	"$METAFLAC" $METAFLAC_OPTS --remove-tag="$TAG_NAME" "$F"
	"$METAFLAC" $METAFLAC_OPTS --set-tag="$TAG_NAME"="$TAG_VALUE" "$F"
done

