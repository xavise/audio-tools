#!/bin/sh

PATH=/usr/bin:/bin

FLACDIR='/cygdrive/c/Apps/FLAC/win64'
FLAC="$FLACDIR/flac.exe"
METAFLAC="$FLACDIR/metaflac.exe"
METAFLAC_OPTS='--no-utf8-convert --export-tags-to=-'

LAMEDIR='/cygdrive/c/Apps/LAME64'
LAME="$LAMEDIR/lame.exe"
LAME_OPTS='--quiet -V 0 --vbr-new --add-id3v2 --pad-id3v2'



reset_tags () {
	TAG_TITLE=
	TAG_TOTALDISCS=
	TAG_TOTALTRACKS=
	TAG_ALBUM=
	TAG_ARTIST=
	TAG_COMMENT=
	TAG_GENRE=
	TAG_DISCNUMBER=
	TAG_DATE=
	TAG_TRACKNUMBER=
}



convert_flac () {
	SRC=$1
	if [ -z "$SRC" ]; then
		echo "$0: Invalid source FLAC file" 1>&2
		return 1
	fi

	SRCDIR=`dirname "$SRC"`
	SRCBASE=`basename "$SRC" '.flac'`

	DSTDIR="$SRCDIR/mp3"
	DST="$DSTDIR/${SRCBASE}.mp3"

	if [ -e "$DST" ]; then
		echo "$0: Destination file already exists: $DST" 1>&2
		return 1
	fi

	mkdir -p "$DSTDIR"
	if [ $? -ne 0 ]; then
		echo "$0: Unable to create destination directory: $DSTDIR" 1>&2
		return 1
	fi

	# Escrivim els tags a un fitxer temporal.
	SRCTAGS="$DSTDIR/${SRCBASE}.tags"
	"$METAFLAC" $METAFLAC_OPTS "$SRC" | perl -wne '
		s/\r\n$//;
		if ( /^(\S+?)=(.*)$/ ) {
			my $var = "TAG_" . uc($1);
			my $value = quotemeta($2);
			print "$var=$value\n";
		}
	' > "$SRCTAGS"

	# WAV temporal.
	SRCWAV="$DSTDIR/${SRCBASE}.wav"
	"$FLAC" --silent -d -o "$SRCWAV" "$SRC"

	# Incorporem els tags com variables.
	reset_tags
	. "$SRCTAGS"

	[ -n "$TAG_TRACKNUMBER" ] && [ -n "$TAG_TOTALTRACKS" ] && TAG_TRACKNUMBER="$TAG_TRACKNUMBER/$TAG_TOTALTRACKS"

	[ -n "$TAG_DISCNUMBER" ] && [ -n "$TAG_TOTALDISCS" ] && TAG_DISCNUMBER="$TAG_DISCNUMBER/$TAG_TOTALDISCS"

	# Convertim a mp3.
	# FIXME: Encara que fem aixo el Discnumber no s'afegeix:
	#        --tv "DISCNUMBER=$TAG_DISCNUMBER"
	#        Potser LAME no ho fa be?
	"$LAME" $LAME_OPTS --tt "$TAG_TITLE" --ta "$TAG_ARTIST" --tl "$TAG_ALBUM" --ty "$TAG_DATE" --tc "$TAG_COMMENT" --tg "$TAG_GENRE" --tn "$TAG_TRACKNUMBER" "$SRCWAV" "$DST"
	STATUS=$?

	# Esborrem fitxers temporals.
	rm -f "$SRCTAGS" "$SRCWAV"

	[ $STATUS -eq 0 ] && echo "$DST"
	return $STATUS
}



for F in "$@"
do
	convert_flac "$F"
done

