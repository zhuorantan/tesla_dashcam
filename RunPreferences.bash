#!/bin/bash

# Small script that will run tesla_dashcam leveraging all the different preferences provided in the Preference_Files folder.

# Folder(s) to scan for clips
InputFolders='/Volumes/TeslaCam/TeslaCam/SentryClips /Volumes/TeslaCam/TeslaCam/SavedClips'

# Folder to store resulting movie files.
OutputFolder='/Volumes/TeslaCam'

# Start Timestamp
StartTimestamp="2021-07"
# StartTimestamp="2020-09-19T13:29:10"

# End Timestamp
EndTimestamp="2021-08-06T17:03"
# EndTimestamp="2020-09-19T13:29:30"

# Path to folder containing the preference files. Should be full path
# If not given then assuming it is in same location as tesla_dashcam
PreferenceFolder="./Preference_Files"


# LogLevel
LogLevel=""
# LogLevel="DEBUG"

if [ -f ${PWD}/tesla_dashcam ]; then
	# Executable (binary) tesla_dashcam is in current path, use it.
	Command="${PWD}/tesla_dashcam"
else
	binary_tesladashcam=`which tela_dashcam`
	if [ $? -eq 0 ]; then
		# Executable (binary) tesla_dashcam is within out path, use that one.
		Command="${binary_tesladashcam}"
	else
		python=`which python3`
		if [ $? -ne 0 ]; then
			echo "Unable to find tesla_dashcam binary and unable to find python3 either. Expecting it to be within ${PATH} or in current folder (${PWD})."
			exit 1
		fi

		if [ -f ${PWD}/tesla_dashcam.py ]; then
			# Got the python tesla_dashcam within the current folder, use it.
			Command="python3 ${PWD}/tesla_dashcam.py"
		elif [ -f ${PWD}/tesla_dashcam/tesla_dashcam.py ]; then
			# Got the python tesla_dashcam within the tesla_dashcam folder, use it.
			Command="python3 ${PWD}/tesla_dashcam/tesla_dashcam.py"
		else
			echo "Unable to find tesla_dashcam binary or tesla_dashcam python file. Expecting it to be within ${PATH} or in current folder (${PWD})."
			exit 1
		fi
	fi
fi

cd "${PreferenceFolder}"
PreferenceFolder="${PWD}"
cd "${OLDPWD}"

if [ "${OutputFolder}" != "" ]; then
	if [ ! -d "${OutputFolder}" ]; then
		mkdir -p "${OutputFolder}"
	fi
fi

if [ "${StartTimestamp}" != "" ]; then
	StartTimestamp="--start_timestamp ${StartTimestamp}"
fi
if [ "${EndTimestamp}" != "" ]; then
	EndTimestamp="--end_timestamp ${EndTimestamp}"
fi

if [ "${LogLevel}" != "" ]; then
	LogLevel="--loglevel ${LogLevel}"
fi

cd "${OutputFolder}"

for preferencefile in ${PreferenceFolder}/*; do
	filename="${preferencefile##*/}"
	folder=${filename%%.*}
	echo "Using Preference File ${filename}"
	echo "${Command} ${InputFolders} ${LogLevel} @${preferencefile}  ${StartTimestamp} ${EndTimestamp}"
	${Command} ${InputFolders} ${LogLevel} @${preferencefile} ${StartTimestamp} ${EndTimestamp}
done

cd $OLDPWD

