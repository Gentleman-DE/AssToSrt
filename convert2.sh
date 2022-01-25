#!/bin/bash
for x in *.mkv
do numTracks=$(mkvinfo "$x"|grep -c "S_TEXT/ASS")
if [ $numTracks -ne 1 ]
then
	echo "No tracks to convert or more than one! Aborting."
	exit 1
fi
for subTrack in $(mkvinfo "$x"|grep -B4 "S_TEXT/ASS"|grep "Track UID"|cut -d ":" -f 2)
do	trackLang=$(mkvinfo "$x"|grep -B4 "S_TEXT/ASS"|grep -C3 "Track UID: $subTrack"|grep "Language:"|cut -d ":" -f 2|tr -d '\040\011\012\015')
	if [ -z "$trackLang" ]
	then
		trackLang="eng"
	fi
	let subTrack--
	ffmpeg -i "$x" -map 0:$subTrack? out.srt
	if [ $? -ne 0 ]
	then
		echo "Failed to convert subtitle to SRT!"
		exit 1
	fi
	mkvmerge -o output.mkv "$x" --language 0:$trackLang --default-track "0:yes" out.srt
	if [ $? -ne 0 ]
	then
		echo "Failed to merge subtitle to $x!"
		exit 1
	fi
	rm out.srt
	mkdir -p Converted
	echo "Successfully converted $x to output.mkv with added SRT-subs!"
	#rm $x
	mv output.mkv "$x"
	
	
	break
done
done
