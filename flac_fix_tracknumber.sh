#!/bin/sh

PATH="$HOME"/bin:/usr/bin:/bin

FLACDIR='/cygdrive/c/Apps/FLAC/win64'
METAFLAC="$FLACDIR/metaflac.exe"
METAFLAC_OPTS='--no-utf8-convert'



usage () {
	echo "Usage: $0 {file} [...]" 1>&2
	exit 1
}



TAG='TRACKNUMBER'

for F in "$@"
do
	T1=$( "$METAFLAC" $METAFLAC_OPTS --show-tag="$TAG" "$F" | fromdos | perl -pe 'chomp' )
	T2=$( echo "$T1" | perl -pe 's/=0+/=/; s/\r//g' )
	# Vam introduir per error "\r" finals per no fer fromdos a T1.

	if [ "$T1" != "$T2" ]
	then
		echo "$F"
		"$METAFLAC" $METAFLAC_OPTS --remove-tag="$TAG" "$F"
		"$METAFLAC" $METAFLAC_OPTS --set-tag="$T2" "$F"
	fi
done

