#!/usr/bin/env bash
set -e
set -x

echo $@

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -podfile) DEP_TYPE="Cocoapods"; DEP_FILE="$2"; shift ;;
        -carthage) DEP_TYPE="Carthage" ;;
        -spm) DEP_TYPE="SPM"; DEP_BRANCH="$2"; shift ;;
        -app) APP=$2; shift ;;
        -ios) PROJECT=$2; DEST_IOS=$3; SCHEME_IOS=$4; shift; shift; shift ;;
        -watch) DEST_WATCH=$2; SCHEME_WATCH=$3; shift; shift ;;
		-log) LOGPATH=$2; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

echo DEP_TYPE $DEP_TYPE
echo DEP_FILE $DEP_FILE
echo DEP_BRANCH $DEP_BRANCH
echo APP $APP
echo PROJECT $PROJECT
echo DEST_IOS $DEST_IOS
echo SCHEME_IOS $SCHEME_IOS
echo DEST_WATCH $DEST_WATCH
echo SCHEME_WATCH $SCHEME_WATCH
echo LOGPATH $LOGPATH

#APP=$1
#DEP_FILE=$2
#PROJECT=$3
#DEST_IOS=$4
#SCHEME_IOS=$5
#DEST_WATCH=$6
#SCHEME_WATCH=$7

if [ $DEP_TYPE == "Carthage" ]; then
	. .scripts/carthage-workaround.sh # to remove when fixed https://github.com/Carthage/Carthage/issues/3019#issuecomment-665136323
	printf "\n\n Carthage update \n"
	cd $APP
	./generateCartfile.sh
	carthage update --log-path $LOGPATH
elif [ $DEP_TYPE == "SPM" ]; then
	printf "\n\n Swift Package Manager update \n"
	cd $APP	
	pushd Dependencies
	sed -i .backup "s|master|$DEP_BRANCH|g" Package.swift
	popd
elif [ $DEP_FILE == "Podfile" ]; then
	printf "\n\n Pod update \n"
	cd $APP
	pod update
elif [[ $DEP_FILE == Podfile* ]]; then
	printf "\n\n Pod update with Podfile: " + $DEP_FILE + " \n"
	cp -rf .scripts/$DEP_FILE $APP/Podfile
	cd $APP
	pod update
else
	printf "ERROR: Podfile or Cartfile is not correctly indicated" 1>&2
	exit 1
fi

printf "\n\n Build iOS ${APP} \n"
set -o pipefail && xcodebuild -destination "${DEST_IOS}" ${PROJECT} ${SCHEME_IOS} clean build | xcpretty

if [ ! -z "$SCHEME_WATCH" ]; then
	printf "\n\n Build watchOS ${APP} \n"
	set -o pipefail && xcodebuild -destination "${DEST_WATCH}" ${PROJECT} ${SCHEME_WATCH} clean build | xcpretty
fi



