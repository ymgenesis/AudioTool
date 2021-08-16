#! /bin/bash


#######
#
#	audiotool.sh [/path/to/input.mkv] [/path/to/output.mkv]
#
#	input.mkv will be the source path & file, while output.mkv will be the output path & file
#
#######


# Colour text variables

R=$(tput setaf 1)
G=$(tput setaf 2)
Y=$(tput setaf 3)
B=$(tput setaf 4)
P=$(tput setaf 5)
C=$(tput setaf 6)
D=$(tput sgr0)
echo

# Folder checks, environment, FFmpeg libs, & in/out variables

# Set home working directory
HWD=$(echo "$PWD")

# Codecs folder checks
if [ -d "$HWD"/Codecs/ ]; then
	cd Codecs/
	CODWD=$(echo "$PWD")
	if [ -z "$(ls ${CODWD})" ]; then
		echo "Directory AudioTool/Codecs/ is ${R}empty${D}!"
		echo "It requires an FFmpeg dependencies folder with .dylib files" 
		echo
		echo "See README.md for the necessary folder & file structure."
		echo 
		exit 1
	else
		:
	fi
	
	# FFmpeg libs checks
	if [ -d $(echo "$CODWD"/*darwin*) ]; then
		FFLIBS=$(echo "$CODWD"/*darwin*)
		if [ -z "$(ls ${FFLIBS})" ]; then
			echo "Directory AudioTool/Codecs/$(basename "$FFLIBS") is ${R}empty${D}!"
			echo "It requires .dylib files" 
			echo
			echo "See README.md for the necessary folder & file structure."
			echo 
			exit 1
		else
			:
		fi
	else
		echo "FFmpeg dependencies folder ${R}not present${D} in AudioTool/Codecs/"
		echo
		echo "See README.md for the necessary folder & file structure."
		echo 
		exit 1
	fi
else
	echo "Directory AudioTool/Codecs/ ${R}does not exist${D}!"
	echo
	echo "See README.md for the necessary folder & file structure."
	echo
	exit 1 
fi

# Encoder folder checks
if [ -d "$HWD"/Encoder/ ]; then
	cd "$HWD"/Encoder/
	ENCWD=$(echo "$PWD")
	if [ -z "$(ls ${ENCWD})" ]; then
		echo "Directory AudioTool/Encoder/ is ${R}empty${D}!"
		echo "It requires eae-license.txt, EasyAudioEncoder, a Frameworks folder with .dylib files, and a MacOS folder with Plex Transcoder." 
		echo
		echo "See README.md for the necessary folder & file structure."
		echo 
		exit 1
	else
		:
	fi

	# Frameworks folder checks
	if [ ! -d "$ENCWD"/Frameworks/ ]; then
		echo "Directory Frameworks/ ${R}not present${D} in AudioTool/Encoder/"
		echo
		echo "See README.md for the necessary folder & file structure."
		echo 
		exit 1
	else
		if [ -z "$(ls ${ENCWD}/Frameworks/)" ]; then
			echo "Directory AudioTool/Encoder/Frameworks/ is ${R}empty${D}!"
			echo "It requires .dylib files" 
			echo
			echo "See README.md for the necessary folder & file structure."
			echo 
			exit 1
		else
			:
		fi
	fi
	
	# MacOS folder checks
	if [ ! -d "$ENCWD"/MacOS/ ]; then
		echo "Directory MacOS/ ${R}not present${D} in AudioTool/Encoder/"
		echo
		echo "See README.md for the necessary folder & file structure."
		echo 
		exit 1
	else
		if [ -z "$(ls ${ENCWD}/MacOS/)" ]; then
			echo "Directory AudioTool/Encoder/MacOS/ is ${R}empty${D}!"
			echo "It requires Plex Transcoder binary file" 
			echo
			echo "See README.md for the necessary folder & file structure."
			echo 
			exit 1
		else
			:
		fi
	fi
	
	# eae-license.txt file check
	if [ ! -s "$ENCWD"/eae-license.txt ]; then
		echo "eae-license.txt file ${R}not present${D} in AudioTool/Encoder/"
		echo
		echo "See README.md for the necessary folder & file structure."
		echo 
		exit 1
	else
		:
	fi
	
	# EasyAudioEncoder file check
	if [ ! -s "$ENCWD"/EasyAudioEncoder ]; then
		echo "EasyAudioEncoder binary file ${R}not present${D} in AudioTool/Encoder/"
		echo
		echo "See README.md for the necessary folder & file structure."
		echo 
		exit 1
	else
		:
	fi
	
	# Plex Transcoder check
	if [ ! -s "$ENCWD"/MacOS/Plex\ Transcoder ]; then
		echo "Plex Transcoder binary file ${R}not present${D} in AudioTool/Encoder/MacOS/"
		echo
		echo "See README.md for the necessary folder & file structure."
		echo 
		exit 1
	else
		:
	fi
else
	echo "Directory AudioTool/Encoder/ ${R}does not exist${D}!"
	echo
	echo "See README.md for the necessary folder & file structure."
	echo
	exit 1
fi
echo "Folder structure/file dependencies check ${G}satisfied${D}!"
echo "Checking for correct input/output values..."
echo
# input and output variables set
INMKV="$1"
OUTMKV="$2"

## Style & tool Functions

# Border around text functions

border () {
    local str="$*"      # Put all arguments into single string
    local len=${#str}
    local i
    for (( i = 0; i < len + 4; ++i )); do
        printf '='
    done
    printf "\n| %s |\n" "$C""$str""$D"
    for (( i = 0; i < len + 4; ++i )); do
        printf '='
    done
    echo
}

border2 () {
    local str="$*"      # Put all arguments into single string
    printf "========================="
    printf "\n> %s\n" "$C""$str""$D"
	printf "========================="
    echo
}

# Output audio info function

outputinfo () {
	AOUTFORMAT0=$(ffprobe -loglevel error -select_streams a:0 -show_entries stream=codec_name -of default=nw=1:nk=1 "$1")
	AOUTLAYOUT0=$(ffprobe -loglevel error -select_streams a:0 -show_entries stream=channel_layout -of default=nw=1:nk=1 "$1")
	AOUTTITLE0=$(ffprobe -loglevel error -select_streams a:0 -show_entries stream_tags=title -of default=nw=1:nk=1 "$1")
	AOUTFORMAT1=$(ffprobe -loglevel error -select_streams a:1 -show_entries stream=codec_name -of default=nw=1:nk=1 "$1")
	AOUTLAYOUT1=$(ffprobe -loglevel error -select_streams a:1 -show_entries stream=channel_layout -of default=nw=1:nk=1 "$1")
	AOUTTITLE1=$(ffprobe -loglevel error -select_streams a:1 -show_entries stream_tags=title -of default=nw=1:nk=1 "$1")
	AOUTFORMAT2=$(ffprobe -loglevel error -select_streams a:2 -show_entries stream=codec_name -of default=nw=1:nk=1 "$1")
	AOUTLAYOUT2=$(ffprobe -loglevel error -select_streams a:2 -show_entries stream=channel_layout -of default=nw=1:nk=1 "$1")
	AOUTTITLE2=$(ffprobe -loglevel error -select_streams a:2 -show_entries stream_tags=title -of default=nw=1:nk=1 "$1")
	AOUTFORMAT3=$(ffprobe -loglevel error -select_streams a:3 -show_entries stream=codec_name -of default=nw=1:nk=1 "$1")
	AOUTLAYOUT3=$(ffprobe -loglevel error -select_streams a:3 -show_entries stream=channel_layout -of default=nw=1:nk=1 "$1")
	AOUTTITLE3=$(ffprobe -loglevel error -select_streams a:3 -show_entries stream_tags=title -of default=nw=1:nk=1 "$1")
	AOUTFORMAT4=$(ffprobe -loglevel error -select_streams a:4 -show_entries stream=codec_name -of default=nw=1:nk=1 "$1")
	AOUTLAYOUT4=$(ffprobe -loglevel error -select_streams a:4 -show_entries stream=channel_layout -of default=nw=1:nk=1 "$1")
	AOUTTITLE4=$(ffprobe -loglevel error -select_streams a:4 -show_entries stream_tags=title -of default=nw=1:nk=1 "$1")
	AOUTFORMAT5=$(ffprobe -loglevel error -select_streams a:5 -show_entries stream=codec_name -of default=nw=1:nk=1 "$1")
	AOUTLAYOUT5=$(ffprobe -loglevel error -select_streams a:5 -show_entries stream=channel_layout -of default=nw=1:nk=1 "$1")
	AOUTTITLE5=$(ffprobe -loglevel error -select_streams a:5 -show_entries stream_tags=title -of default=nw=1:nk=1 "$1")
	AOUTFORMAT6=$(ffprobe -loglevel error -select_streams a:6 -show_entries stream=codec_name -of default=nw=1:nk=1 "$1")
	AOUTLAYOUT6=$(ffprobe -loglevel error -select_streams a:6 -show_entries stream=channel_layout -of default=nw=1:nk=1 "$1")
	AOUTTITLE6=$(ffprobe -loglevel error -select_streams a:6 -show_entries stream_tags=title -of default=nw=1:nk=1 "$1")

	echo "Audio information for output file ${P}${1}${D}:"
	echo
	echo "a:0 (first audio track): ${B}${AOUTFORMAT0} ${AOUTLAYOUT0}${D} – ${AOUTTITLE0}" 
	echo "a:1 (second audio track): ${B}${AOUTFORMAT1} ${AOUTLAYOUT1}${D} – ${AOUTTITLE1}"
	echo "a:2 (third audio track): ${B}${AOUTFORMAT2} ${AOUTLAYOUT2}${D} – ${AOUTTITLE2}"
	echo "a:3 (fourth audio track): ${B}${AOUTFORMAT3} ${AOUTLAYOUT3}${D} – ${AOUTTITLE3}"
	echo "a:4 (fifth audio track): ${B}${AOUTFORMAT4} ${AOUTLAYOUT4}${D} – ${AOUTTITLE4}"
	echo "a:5 (sixth audio track): ${B}${AOUTFORMAT5} ${AOUTLAYOUT5}${D} – ${AOUTTITLE5}"
	echo "a:6 (seventh audio track): ${B}${AOUTFORMAT6} ${AOUTLAYOUT6}${D} – ${AOUTTITLE6}"
}

# time left progress stats function

sec2min()
{
 local S=${1}
 ((h=S/3600))
 ((m=S%3600/60))
 ((s=S%60))
 printf "%dh:%dm:%ds\n" "$h" "$m" "$s"
}

sec2hms () {
    num=$1
    min=0
    hour=0
    day=0
    if((num>59));then
        ((sec=num%60))
        ((num=num/60))
        if((num>59));then
            ((min=num%60))
            ((num=num/60))
            if((num>23));then
                ((hour=num%24))
                ((day=num/24))
            else
                ((hour=num))
            fi
        else
            ((min=num))
        fi
    else
        ((sec=num))
    fi
    echo "$day"d "$hour"h "$min"m "$sec"s
}

timeleft () {
	currenttime=$(date '+%H:%M:%S')
	currenttimeseconds=$(echo "$currenttime" | awk -F: '{ print ($1 * 3600) + ($2 * 60) + $3 }')
	starttimeseconds=$(head -n 1 "$ENCWD"/out.txt)
	speed=$(tail -n 1 "$ENCWD"/out.txt | sed 's/.*speed=//; s/x.*//')
	elapsed=$(tail -n 1 "$ENCWD"/out.txt | sed 's/.*time=//; s/\..*//')
	sizekb=$(tail -n 1 "$ENCWD"/out.txt | sed 's/.*size=//; s/k.*//')
	duration=$(ffprobe -loglevel error -select_streams a:0 -show_entries stream_tags=duration -of default=nw=1:nk=1 "$INMKV" | sed 's/\..*//')
	durationseconds=$(echo "$duration" | awk -F: '{ print ($1 * 3600) + ($2 * 60) + $3 }')
	timeleftseconds=$(echo "$durationseconds / $speed" | bc)
	timeleftminutes=$(sec2min "$timeleftseconds")
	elapsedseconds=$(echo "$elapsed" | awk -F: '{ print ($1 * 3600) + ($2 * 60) + $3 }')
	durationleftseconds=$(($durationseconds - $elapsedseconds))
	durationleftminutes=$(sec2min "$durationleftseconds")
	endtimeseconds=$(($starttimeseconds + $timeleftseconds))
	timeremainingseconds=$(($endtimeseconds - $currenttimeseconds))
	timeremaininghms=$(sec2min "$timeremainingseconds")

#	echo "Stats for Nerds:"
#	echo
#	echo "time at start (seconds): $starttimeseconds"
#	echo "end time (seconds): $endtimeseconds"
#	echo "speed multiplier: $speed"
#	echo "total duration (h:m:s): $duration"
#	echo "total duration (seconds): $durationseconds"
#	echo "current time: $currenttime"
#	echo "current time (seconds): $currenttimeseconds"
#	echo "How long it'll take to encode (seconds): $timeleftseconds"
#	echo "How long it'll take to encode (h:m:s): $timeleftminutes"
#	echo "Duration left to encode (seconds): $durationleftseconds"
#	echo "time left (seconds): $timeremainingseconds"
#	echo "encoded duration so far (seconds): $elapsedseconds"

	clear
	border "$1"
	echo
	echo "Audio duration: $duration"
	echo "Duration left to encode: $durationleftminutes"
	echo "Encoded so far: $elapsed"
	echo "Current size: "$(numfmt --from=iec --to=si "$sizekb"K)
	echo "Approximate encode time: $timeleftminutes"
	echo "Time until finished encoding: ${P}$timeremaininghms${D}"
}

## Main Functions

# TrueHD 7.1 to eac3 7.1

thd () {
	./EasyAudioEncoder &
	echo "$(echo $(date '+%H:%M:%S') | awk -F: '{ print ($1 * 3600) + ($2 * 60) + $3 }')" > "$ENCWD"/out.txt
	(EAE_ROOT="$ENCWD" FFMPEG_EXTERNAL_LIBS="$FFLIBS"/ X_PLEX_TOKEN='xxxxxxxxxxxxxxxxxxxx' ''${ENCWD}'/MacOS/Plex Transcoder' \
	'-c:v:0' 'hevc' \
	'-c:a:0' 'truehd_eae' \
	'-noaccurate_seek' \
	'-analyzeduration' '20000000' \
	'-probesize' '20000000' \
	'-i' "$1" \
	'-map' '0:v:0' \
	'-map' '0:a:0' \
	'-c:v:0' 'copy' \
	'-c:a:0' 'copy' \
	'-filter_complex' '[0:a:0] aresample=async=1:ocl='\''7.1'\'':rematrix_maxval=60.000000dB:osr=48000[0]' \
	'-map' '[0]' \
	'-metadata:s:a:1' 'title=EAC3 7.1 from TrueHD' \
	'-metadata:s:a:1' 'language=eng' \
	'-c:a:1' 'eac3_eae' \
	'-b:a:1' '1280k' \
	'-map' '0:a:1?' \
	'-c:a:2' 'copy' \
	'-map' '0:a:2?' \
	'-c:a:3' 'copy' \
	'-map' '0:a:3?' \
	'-c:a:4' 'copy' \
	'-map' '0:a:4?' \
	'-c:a:5' 'copy' \
	'-map' '0:a:5?' \
	'-c:a:6' 'copy' \
	'-map' '0:s?' \
	'-c:s' 'copy' \
	'-start_at_zero' \
	'-copyts' \
	'-vsync' 'cfr' \
	'-avoid_negative_ts' 'disabled' \
	'-v' 'fatal' '-stats' \
	"$2" 2>&1 | tee -a "$ENCWD"/out.txt &)
	sleep 1
	thdpid=$(ps -ef | grep 'Plex Transcoder -c:v:0 hevc -c:a:0 truehd_eae' | grep -v grep | tr -s ' ' | cut -d ' ' -f3)
	eaepid=$(ps -ef | grep 'EasyAudioEncoder' | grep -v grep | tr -s ' ' | cut -d ' ' -f3)
	trap "kill $thdpid 2> /dev/null" EXIT
	trap "kill $eaepid 2> /dev/null" EXIT	
	while kill -0 $thdpid 2> /dev/null; do
		echo
		timeleft "$3"
		echo
		sleep 2
	done
	trap - EXIT
	echo
	echo "Terminating EasyAudioEncoder..."
	kill $(ps aux | grep -v grep | grep -v findandkill.sh | grep -i 'EasyAudioEncoder' | awk '{print $2}') > /dev/null 2>&1 || { echo "Failed. Either no running process(es) matching 'EasyAudioEncoder', or process(es) $1 belong(s) to root." ; exit 1; }
}

# DTS 7.1 to eac3 7.1

dts () {
	./EasyAudioEncoder &
	echo "$(echo $(date '+%H:%M:%S') | awk -F: '{ print ($1 * 3600) + ($2 * 60) + $3 }')" > "$ENCWD"/out.txt
	(EAE_ROOT="$ENCWD" FFMPEG_EXTERNAL_LIBS="$FFLIBS"/ X_PLEX_TOKEN='xxxxxxxxxxxxxxxxxxxx' ''${ENCWD}'/MacOS/Plex Transcoder' \
	'-c:v:0' 'hevc' \
	'-c:a:0' 'dca' \
	'-noaccurate_seek' \
	'-analyzeduration' '20000000' \
	'-probesize' '20000000' \
	'-i' "$1" \
	'-map' '0:v:0' \
	'-map' '0:a:0' \
	'-c:v:0' 'copy' \
	'-c:a:0' 'copy' \
	'-filter_complex' '[0:a:0] aresample=async=1:ocl='\''7.1'\'':rematrix_maxval=60.000000dB:osr=48000[0]' \
	'-map' '[0]' \
	'-metadata:s:a:1' 'title=EAC3 7.1 from DTS' \
	'-metadata:s:a:1' 'language=eng' \
	'-c:a:1' 'eac3_eae' \
	'-b:a:1' '1280k' \
	'-map' '0:a:1?' \
	'-c:a:2' 'copy' \
	'-map' '0:a:2?' \
	'-c:a:3' 'copy' \
	'-map' '0:a:3?' \
	'-c:a:4' 'copy' \
	'-map' '0:a:4?' \
	'-c:a:5' 'copy' \
	'-map' '0:a:5?' \
	'-c:a:6' 'copy' \
	'-map' '0:s?' \
	'-c:s' 'copy' \
	'-start_at_zero' \
	'-copyts' \
	'-vsync' 'cfr' \
	'-avoid_negative_ts' 'disabled' \
	'-v' 'fatal' '-stats' \
	"$2" 2>&1 | tee -a "$ENCWD"/out.txt &)
	sleep 1
	dtspid=$(ps -ef | grep 'Plex Transcoder -c:v:0 hevc -c:a:0 dca' | grep -v grep | tr -s ' ' | cut -d ' ' -f3)
	eaepid=$(ps -ef | grep 'EasyAudioEncoder' | grep -v grep | tr -s ' ' | cut -d ' ' -f3)
	trap "kill $dtspid 2> /dev/null" EXIT
	trap "kill $eaepid 2> /dev/null" EXIT	
	while kill -0 $dtspid 2> /dev/null; do
		echo
		timeleft "$3"
		echo
		sleep 2
	done
	trap - EXIT
	echo
	echo "Terminating EasyAudioEncoder..."
	kill $(ps aux | grep -v grep | grep -v findandkill.sh | grep -i 'EasyAudioEncoder' | awk '{print $2}') > /dev/null 2>&1 || { echo "Failed. Either no running process(es) matching 'EasyAudioEncoder', or process(es) $1 belong(s) to root." ; exit 1; }
}

# Any to eac3

eac3 () {
	echo "$(echo $(date '+%H:%M:%S') | awk -F: '{ print ($1 * 3600) + ($2 * 60) + $3 }')" > "$ENCWD"/out.txt
	(ffmpeg \
	'-i' "$1" \
	'-map' '0:v' \
	'-map' '0:a:0' \
	'-map' '0:a' \
	'-map' '0:s?' \
	'-c:v' 'copy' \
	'-c:a' 'copy' \
	'-c:s' 'copy' \
	'-metadata:s:a:1' title='EAC3 640kbps' \
	'-metadata:s:a:1' 'language=eng' \
	'-c:a:1' 'eac3' \
	'-b:a:1' '640k' \
	'-v' 'fatal' '-stats' \
	"$2" 2>&1 | tee -a "$ENCWD"/out.txt &)
	sleep 1
	eac3pid=$(ps -ef | grep 'EAC3 640kbps -metadata:s:a:1 language' | grep -v grep | tr -s ' ' | cut -d ' ' -f3)
	trap "kill $eac3pid 2> /dev/null" EXIT
	while kill -0 $eac3pid 2> /dev/null; do
		echo
		timeleft "$3"
		echo
		sleep 2
	done
	trap - EXIT
}

# Any to ac3

ac3 () {
	echo "$(echo $(date '+%H:%M:%S') | awk -F: '{ print ($1 * 3600) + ($2 * 60) + $3 }')" > "$ENCWD"/out.txt
	(ffmpeg \
	'-i' "$1" \
	'-map' '0:v' \
	'-map' '0:a:0' \
	'-map' '0:a' \
	'-map' '0:s?' \
	'-c:v' 'copy' \
	'-c:a' 'copy' \
	'-c:s' 'copy' \
	'-metadata:s:a:1' title='AC3 640kbps' \
	'-metadata:s:a:1' 'language=eng' \
	'-c:a:1' 'ac3' \
	'-b:a:1' '640k' \
	'-v' 'fatal' '-stats' \
	"$2" 2>&1 | tee -a "$ENCWD"/out.txt &)
	sleep 1
	ac3pid=$(ps -ef | grep 'AC3 640kbps -metadata:s:a:1 language' | grep -v grep | tr -s ' ' | cut -d ' ' -f3)
	trap "kill $ac3pid 2> /dev/null" EXIT
	while kill -0 $ac3pid 2> /dev/null; do
		echo
		timeleft "$3"
		echo
		sleep 2
	done
	trap - EXIT
}

# Strip audio stream

stripstream () {
	echo "$(echo $(date '+%H:%M:%S') | awk -F: '{ print ($1 * 3600) + ($2 * 60) + $3 }')" > "$ENCWD"/out.txt
	(ffmpeg \
	'-i' "$1" \
	'-map' '0' \
	'-map' -0:a:"$2" \
	'-c' 'copy' \
	'-v' 'fatal' '-stats' \
	"$3" 2>&1 | tee -a "$ENCWD"/out.txt &)
	sleep 1
	sspid=$(ps -ef | grep 'map 0 -map -0:a:' | grep -v grep | tr -s ' ' | cut -d ' ' -f3)
	trap "kill $sspid 2> /dev/null" EXIT
	while kill -0 $sspid 2> /dev/null; do
		echo
		timeleft "$4"
		echo
		sleep 2
	done
	trap - EXIT
	
}

# Change Input and Output Paths & Files

changeinmkv () {
	CHANGEINANS=n
	while [ "$CHANGEINANS" != "y" -o "$CHANGEINANS" != "Y" ];
	do
		read -p "Change input path & file? [y/n]: " CHANGEINANS
		if [ "$CHANGEINANS" = "n" -o "$CHANGEINANS" = "N" ];
		then
			echo
			echo "Input path & file will remain as: ${P}${INMKV}${D}"
			sleep 0.7
			break
		elif [ "$CHANGEINANS" = "y" -o "$CHANGEINANS" = "Y" ];
		then
			FLAG=1
			while [ "$FLAG" != "0" ];
			do
				echo
				read -ep "Enter new ${R}absolute${D} path & file for ${P}input${D} (tab completion enabled): " USERINMKV
				if [ ! -s "$USERINMKV" ]
				then
					echo
					echo "${P}${USERINMKV}${D} ${R}does not exist${D}! Try again."
					sleep 0.7
					continue
				elif [ "$USERINMKV" = "$OUTMKV" ]
				then
					echo
					echo "${P}${USERINMKV}${D} is identical to your output file!"
					echo "Input and output files cannot be identical, or FFmpeg's encode execution will fail. Try again."
					sleep 0.7
					continue
				elif [ -s "$USERINMKV" ]
				then
					INMKV="$USERINMKV"
					echo
					echo "Changed input path & file to: ${P}${INMKV}${D}"
					sleep 0.7
					FLAG=0
				fi
			done
			break
		else
			echo "Accepted answers are y or n"
			sleep 0.7
		fi
	done
}

changeoutmkv () {
	CHANGEOUTANS=n
	while [ "$CHANGEOUTANS" != "y" -o "$CHANGEOUTANS" != "Y" ];
	do
		read -p "Change output path & file? [y/n]: " CHANGEOUTANS
		if [ "$CHANGEOUTANS" = "n" -o "$CHANGEOUTANS" = "N" ];
		then
			echo
			echo "Output path & file will remain as: ${P}${OUTMKV}${D}"
			sleep 0.7
			break
		elif [ "$CHANGEOUTANS" = "y" -o "$CHANGEOUTANS" = "Y" ];
		then
			FLAG=1
			while [ "$FLAG" != "0" ];
			do
				echo
				read -ep "Enter new ${R}absolute${D} path & file for ${P}output${D} (tab completion enabled): " USEROUTMKV
				if [ "$USEROUTMKV" = "$INMKV" ]
				then
					echo
					echo "${P}${USEROUTMKV}${D} is identical to your input file!"
					echo "Input and output files cannot be identical, or FFmpeg's encode execution will fail. Try again."
					sleep 0.7
					continue
				elif [ -s "$USEROUTMKV" ]
				then
					echo
					echo "${P}${USEROUTMKV}${D} ${R}already exists${D}, or is a directory! FFmpeg will prompt you to overwite the existing file."
					echo
					CHOUTANS=y
					while [ "$CHOUTANS" != "n" ] && [ "$CHOUTANS" != "N" ];
					do
						read -rp "Proceed? [y/n]: " CHOUTANS
						if [ "$CHOUTANS" = "y" ] || [ "$CHOUTANS" = "Y" ];
						then
							OUTMKV="$USEROUTMKV"
							echo
							echo "Changed output path & file to: ${P}${OUTMKV}${D}"
							sleep 0.7
							FLAG=0
							break
						elif [ "$CHOUTANS" = "n" ] || [ "$CHOUTANS" = "N" ];
						then
							echo
							echo "Output not chaged to ${USEROUTMKV}. Try again."
							sleep 0.7
						else
							echo "Accepted answers are y or n check"
							sleep 0.7
						fi
					done
				elif [ ! -s "$USEROUTMKV" ]
				then
					OUTMKV="$USEROUTMKV"
					echo
					echo "Changed output path & file to: ${P}${OUTMKV}${D}"
					sleep 0.7
					FLAG=0
				fi
			done
			break
		else
			echo "Accepted answers are y or n"
			sleep 0.7
		fi
	done
}

##########
## MAIN ##
##########

if [[ $# -eq 2 ]] && [[ -s "$INMKV" ]] && [ ! -s "$OUTMKV" ]; then
	echo "input/output checks ${G}satisfied${D}!"
	echo

	while [ "$ANS" != "7" ];
	do
		# input audio info
		AFORMAT0=$(ffprobe -loglevel error -select_streams a:0 -show_entries stream=codec_name -of default=nw=1:nk=1 "$INMKV")
		ALAYOUT0=$(ffprobe -loglevel error -select_streams a:0 -show_entries stream=channel_layout -of default=nw=1:nk=1 "$INMKV")
		ATITLE0=$(ffprobe -loglevel error -select_streams a:0 -show_entries stream_tags=title -of default=nw=1:nk=1 "$INMKV")
		AFORMAT1=$(ffprobe -loglevel error -select_streams a:1 -show_entries stream=codec_name -of default=nw=1:nk=1 "$INMKV")
		ALAYOUT1=$(ffprobe -loglevel error -select_streams a:1 -show_entries stream=channel_layout -of default=nw=1:nk=1 "$INMKV")
		ATITLE1=$(ffprobe -loglevel error -select_streams a:1 -show_entries stream_tags=title -of default=nw=1:nk=1 "$INMKV")
		AFORMAT2=$(ffprobe -loglevel error -select_streams a:2 -show_entries stream=codec_name -of default=nw=1:nk=1 "$INMKV")
		ALAYOUT2=$(ffprobe -loglevel error -select_streams a:2 -show_entries stream=channel_layout -of default=nw=1:nk=1 "$INMKV")
		ATITLE2=$(ffprobe -loglevel error -select_streams a:2 -show_entries stream_tags=title -of default=nw=1:nk=1 "$INMKV")
		AFORMAT3=$(ffprobe -loglevel error -select_streams a:3 -show_entries stream=codec_name -of default=nw=1:nk=1 "$INMKV")
		ALAYOUT3=$(ffprobe -loglevel error -select_streams a:3 -show_entries stream=channel_layout -of default=nw=1:nk=1 "$INMKV")
		ATITLE3=$(ffprobe -loglevel error -select_streams a:3 -show_entries stream_tags=title -of default=nw=1:nk=1 "$INMKV")
		AFORMAT4=$(ffprobe -loglevel error -select_streams a:4 -show_entries stream=codec_name -of default=nw=1:nk=1 "$INMKV")
		ALAYOUT4=$(ffprobe -loglevel error -select_streams a:4 -show_entries stream=channel_layout -of default=nw=1:nk=1 "$INMKV")
		ATITLE4=$(ffprobe -loglevel error -select_streams a:4 -show_entries stream_tags=title -of default=nw=1:nk=1 "$INMKV")
		AFORMAT5=$(ffprobe -loglevel error -select_streams a:5 -show_entries stream=codec_name -of default=nw=1:nk=1 "$INMKV")
		ALAYOUT5=$(ffprobe -loglevel error -select_streams a:5 -show_entries stream=channel_layout -of default=nw=1:nk=1 "$INMKV")
		ATITLE5=$(ffprobe -loglevel error -select_streams a:5 -show_entries stream_tags=title -of default=nw=1:nk=1 "$INMKV")
		AFORMAT6=$(ffprobe -loglevel error -select_streams a:6 -show_entries stream=codec_name -of default=nw=1:nk=1 "$INMKV")
		ALAYOUT6=$(ffprobe -loglevel error -select_streams a:6 -show_entries stream=channel_layout -of default=nw=1:nk=1 "$INMKV")
		ATITLE6=$(ffprobe -loglevel error -select_streams a:6 -show_entries stream_tags=title -of default=nw=1:nk=1 "$INMKV")
	
		# Main Menu
		border "Audio Tool"
		echo
		echo "Audio information for input file ${P}${INMKV}${D}:"
		echo
		echo "a:0 (first audio track): ${B}${AFORMAT0} ${ALAYOUT0}${D} – ${ATITLE0}" 
		echo "a:1 (second audio track): ${B}${AFORMAT1} ${ALAYOUT1}${D} – ${ATITLE1}"
		echo "a:2 (third audio track): ${B}${AFORMAT2} ${ALAYOUT2}${D} – ${ATITLE2}"
		echo "a:3 (fourth audio track): ${B}${AFORMAT3} ${ALAYOUT3}${D} – ${ATITLE3}"
		echo "a:4 (fifth audio track): ${B}${AFORMAT4} ${ALAYOUT4}${D} – ${ATITLE4}"
		echo "a:5 (sixth audio track): ${B}${AFORMAT5} ${ALAYOUT5}${D} – ${ATITLE5}"
		echo "a:6 (seventh audio track): ${B}${AFORMAT6} ${ALAYOUT6}${D} – ${ATITLE6}"
		echo
		echo "Output path & file: ${P}${OUTMKV}${D}"
		echo
		if [ -s "$OUTMKV" ]
		then
			echo "${R}WARNING${D}: Output file ${P}${OUTMKV}${D} exists! Options 1–5 will prompt you to overwrite it (unless input & output are identical, then they will fail) until you change your output path & file (option 6)."
			echo
		fi
		echo "${G}1${D} - a:0 TrueHD 7.1 to a:1 EAC3 7.1"
		echo "${G}2${D} - a:0 DTS 7.1 to a:1 EAC3 7.1"
		echo "${G}3${D} - a:0 Any to a:1 EAC3 5.1 and below"
		echo "${G}4${D} - a:0 Any to a:1 AC3 5.1 and below"
		echo "${G}5${D} - Strip Audio Stream"
		echo "${G}6${D} - Change Input and Output Paths & Files"
		echo "${G}7${D} - Quit"
		if [ "$INMKV" = "$OUTMKV" ]
		then
			echo
			echo "${R}WARNING${D}: Your input and output files are the same! Options 1–5 will fail until you change either your input or output paths & files (option 6)."
		fi
		echo
		read -rp "Selection: " ANS
	
		case $ANS in
	
	## 1. TrueHD 7.1 to EAC3 7.1

			1)
			
			clear
			thdheading='a:0 TrueHD 7.1 to a:1 EAC3 7.1'
			border "${thdheading}"
			echo
			if [ "$AFORMAT0" = "truehd" ]; then
				if [ "$ALAYOUT0" = "7.1" ]; then
					echo "${ALAYOUT0} TrueHD stream found at audio position 1 (a:0)."
					echo
					echo "${G}Creating${D} EAC3 7.1 at audio position 2 (a:1) in file ${P}${OUTMKV}${D}..."
					echo
					THDANS=y
					while [ "$THDANS" != "n" ] && [ "$THDANS" != "N" ];
					do
						read -rp "Proceed? [y/n]: " THDANS
						if [ "$THDANS" = "y" ] || [ "$THDANS" = "Y" ];
						then
							echo
							thd "$INMKV" "$OUTMKV" "$thdheading"
							echo
							echo "Complete!"
							echo
							outputinfo "$OUTMKV"
							echo
							rm "$ENCWD"/out.txt
							break
						elif [ "$THDANS" = "n" ] || [ "$THDANS" = "N" ];
						then
							echo
							echo "Nothing written to output."
							echo "Aborting..."
							echo
							sleep 0.7
						else
							echo "Accepted answers are y or n"
							sleep 0.7
						fi
					done
				else
					echo "TrueHD channel layout at audio position 1 (a:0) isn't 7.1!"
					echo "It is: ${ALAYOUT0}."
					echo "Aborting..."
					echo
				fi
			else
				echo "No TrueHD audio stream found at audio position 1 (a:0)."
				echo "Audio at position 1 (a:0) for this file is: ${AFORMAT0}."
				echo "Aborting..."
				echo
			fi	
			
			;;

	## 2. DTS 7.1 to EAC3 7.1
		
			2)
	
			clear
			dtsheading='a:0 DTS 7.1 to a:1 EAC3 7.1'
			border "${dtsheading}"
			echo
			if [ "$AFORMAT0" = "dts" ]; then
				if [ "$ALAYOUT0" = "7.1" ]; then
					echo "${ALAYOUT0} DTS stream found at audio position 1 (a:0)."
					echo
					echo "${G}Creating${D} EAC3 7.1 at audio position 2 (a:1) in file ${P}${OUTMKV}${D}..."
					echo
					DTSANS=y
					while [ "$DTSANS" != "n" ] && [ "$DTSANS" != "N" ];
					do
						read -rp "Proceed? [y/n]: " DTSANS
						if [ "$DTSANS" = "y" ] || [ "$DTSANS" = "Y" ];
						then
							echo
							dts "$INMKV" "$OUTMKV" "$dtsheading"
							echo
							echo "Complete!"
							echo
							outputinfo "$OUTMKV"
							echo
							rm "$ENCWD"/out.txt
							break
						elif [ "$DTSANS" = "n" ] || [ "$DTSANS" = "N" ];
						then
							echo
							echo "Nothing written to output."
							echo "Aborting..."
							echo
							sleep 0.7
						else
							echo "Accepted answers are y or n"
							sleep 0.7
						fi
					done
				else
					echo "DTS channel layout at audio position 1 (a:0) isn't 7.1!"
					echo "It is: ${ALAYOUT0}."
					echo "Aborting..."
					echo
				fi
			else
				echo "No DTS audio stream found at audio position 1 (a:0)."
				echo "Audio at position 1 (a:0) for this file is: ${AFORMAT0}."
				echo "Aborting..."
				echo
			fi	
			
			;;
		
	## 3. Any to EAC3 (5.1 and below)

			3)
		
			clear
			eac3heading='a:0 Any to a:1 EAC3 5.1 and below'
			border "${eac3heading}"
			echo
			if [ "$ALAYOUT0" = "7.1" ]; then
				echo "${R}WARNING${D}: a:0 is a 7.1 ${AFORMAT0} stream. Please use option 1 or 2 to encode an EAC3 7.1 track from TrueHD or DTS."
				echo "Options 3 and 4 will mixdown 7.1 channels to 5.1."
				echo
			fi
			echo "${ALAYOUT0} ${AFORMAT0} stream found at audio position 1 (a:0)."
			echo
			echo "${G}Creating${D} a 5.1 and below EAC3 stream at audio position 2 (a:1) in file ${P}${OUTMKV}${D}..."
			echo
			EAC3ANS=y
			while [ "$EAC3ANS" != "n" ] && [ "$EAC3ANS" != "N" ];
			do
				read -rp "Proceed? [y/n]: " EAC3ANS
				if [ "$EAC3ANS" = "y" ] || [ "$EAC3ANS" = "Y" ];
				then
					echo
					eac3 "$INMKV" "$OUTMKV" "$eac3heading"
					echo
					echo "Complete!"
					echo
					outputinfo "$OUTMKV"
					echo
					rm "$ENCWD"/out.txt
					break
				elif [ "$EAC3ANS" = "n" ] || [ "$EAC3ANS" = "N" ];
				then
					echo
					echo "Nothing written to output."
					echo "Aborting..."
					echo
					sleep 0.7
				else
					echo "Accepted answers are y or n"
					sleep 0.7
				fi
			done
			
			;;

	## 4. Any to AC3 (5.1 and below)

			4)
		
			clear
			ac3heading='a:0 Any to a:1 AC3 5.1 and below'
			border "${ac3heading}"
			echo
			if [ "$ALAYOUT0" = "7.1" ]; then
				echo "${R}WARNING${D}: a:0 is a 7.1 ${AFORMAT0} stream. AC3 doesn't support more than 5.1 channels."
				echo "Options 3 and 4 will mixdown 7.1 channels to 5.1."
				echo
			fi
			echo "${ALAYOUT0} ${AFORMAT0} stream found at audio position 1 (a:0)."
			echo
			echo "${G}Creating${D} a 5.1 and below AC3 stream at audio position 2 (a:1) in file ${P}${OUTMKV}${D}..."
			echo
			AC3ANS=y
			while [ "$AC3ANS" != "n" ] && [ "$AC3ANS" != "N" ];
			do
				read -rp "Proceed? [y/n]: " AC3ANS
				if [ "$AC3ANS" = "y" ] || [ "$AC3ANS" = "Y" ];
				then
					echo
					ac3 "$INMKV" "$OUTMKV" "$ac3heading"
					echo
					echo "Complete!"
					echo
					outputinfo "$OUTMKV"
					echo
					rm "$ENCWD"/out.txt
					break
				elif [ "$AC3ANS" = "n" ] || [ "$AC3ANS" = "N" ];
				then
					echo
					echo "Nothing written to output."
					echo "Aborting..."
					echo
					sleep 0.7
				else
					echo "Accepted answers are y or n"
					sleep 0.7
				fi
			done
			
			;;

	## 5. Strip Audio Stream
		
			5)
	
			clear
			ssheading='Strip Audio Stream'
			border "${ssheading}"
			echo
			echo "Enter 0 to strip audio track 1: ${B}${AFORMAT0} ${ALAYOUT0}${D} – ${ATITLE0}"
			echo "Enter 1 to strip audio track 2: ${B}${AFORMAT1} ${ALAYOUT1}${D} – ${ATITLE1}"
			echo "Enter 2 to strip audio track 3: ${B}${AFORMAT2} ${ALAYOUT2}${D} – ${ATITLE2}"
			echo "Enter 3 to strip audio track 4: ${B}${AFORMAT3} ${ALAYOUT3}${D} – ${ATITLE3}"
			echo "Enter 4 to strip audio track 5: ${B}${AFORMAT4} ${ALAYOUT4}${D} – ${ATITLE4}"
			echo "Enter 5 to strip audio track 6: ${B}${AFORMAT5} ${ALAYOUT5}${D} – ${ATITLE5}"
			echo "Enter 6 to strip audio track 7: ${B}${AFORMAT6} ${ALAYOUT6}${D} – ${ATITLE6}"
			echo "If stream is higher than track seven, minus 1 and enter that number (ex: track 9, enter 8)."
			echo
			read -rp "Enter number: " STRIPNUMBER
			echo
			echo "${R}Removing${D} a:${STRIPNUMBER} in output file ${P}${OUTMKV}${D}..."
			echo
			STRIPANS=y
			while [ "$STRIPANS" != "n" ] && [ "$STRIPANS" != "N" ];
			do
				read -rp "Proceed? [y/n]: " STRIPANS
				if [ "$STRIPANS" = "y" ] || [ "$STRIPANS" = "Y" ];
				then
					echo
					stripstream "$INMKV" "$STRIPNUMBER" "$OUTMKV" "$ssheading"
					echo
					echo "Complete!"
					echo
					outputinfo "$OUTMKV"
					echo
					rm "$ENCWD"/out.txt
					break
				elif [ "$STRIPANS" = "n" ] || [ "$STRIPANS" = "N" ];
				then
					echo
					echo "Nothing written to output."
					echo "Aborting..."
					echo
					sleep 0.7
				else
					echo "Accepted answers are y or n"
					sleep 0.7
				fi
			done
			
			;;

	## 6. Change Input & Output Paths & Files
		
			6)
	
			clear
			border "Change Input and Output Paths & Files"
			echo
			echo "Current input path & file: ${P}${INMKV}${D}"
			echo "Current output path & file: ${P}${OUTMKV}${D}"
			echo
			changeinmkv
			echo
			changeoutmkv
			echo
			echo "Complete!"
			echo
			echo "Active input path & file: ${P}${INMKV}${D}"
			echo "Active output path & file: ${P}${OUTMKV}${D}"
			echo
			
			;;


	## 7. Quitting
		
			7)
	
			echo
			echo "Quitting..."
			echo
			sleep 0.7
			
			;;

	## Invalid selection
		
			*)
	
			echo
			echo "${R}Invalid selection${D}."
			sleep 0.7
			
			;;
	
		esac
	done
elif [ ! -s "$INMKV" ]; then
	echo "Input ${INMKV} ${R}does not exist${D}!"
	echo
	echo "Input file must exist for proper execution."
	echo
	echo "Usage: audiotool.sh [/path/to/input.mkv] [/path/to/output.mkv]"
	echo
	echo "Requires 2 arguments. input.mkv must exist, and will be the source path & file, while output.mkv cannot exist, and will be the output path & file."
	echo
	exit 1
elif [ -s "$OUTMKV" ]; then
	echo "Output ${OUTMKV} ${R}exists${D}, or is a directory!"
	echo
	echo "Though FFmpeg prompts to overwrite output, your initial output value must not exist. To be prompted to overwrite a file, enter an initial output value that doesn't exist, then use option 6 to change your output to one that exists, but isn't identical to your input file."
	echo
	echo "Note: Input and output files cannot be identical, or FFmpeg's encode execution will fail."
	echo
	echo "Usage: audiotool.sh [/path/to/input.mkv] [/path/to/output.mkv]"
	echo
	echo "Requires 2 arguments. input.mkv must exist, and will be the source path & file, while output.mkv cannot exist, and will be the output path & file."
	echo
	exit 1
elif [[ ! $# -eq 2 ]]; then
	echo "Requires 2 arguments."
	echo
	echo "Usage: audiotool.sh [/path/to/input.mkv] [/path/to/output.mkv]"
	echo
	echo "input.mkv must exist, and will be the source path & file, while output.mkv cannot exist, and will be the output path & file."
	echo
	exit 1

fi