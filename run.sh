#!/bin/sh
APPLICATION_NAME=Sound
PROJDIR=/Users/Desktop/Projects/Swift/Sound
PROJECT_NAME=Sound
TARGET_SDK="iphoneos"
PROJECT_BUILDDIR="${PROJDIR}/build/Release-iphoneos"
TARGET_TEST_NAME="Sound"
BUILD_HISTORY_DIR="/Users/Desktop/Projects/Swift/Sound"
DEVELOPPER_NAME="iPhone Distribution: iOSRider India Limited (R8UAKS2M7L)"
PROVISONNING_PROFILE="/Users/Desktop/Projects/Swift/Sound/iOS.mobileprovision"

#compile project

#echo Building Project cd "${PROJDIR}" xcodebuild -target "${PROJECT_NAME}" -sdk "${TARGET_SDK}" -configuration Release
xcodebuild -target "${PROJECT_NAME}" -sdk "${TARGET_SDK}" -configuration Release

#Check if build succeeded

if [ $? != 0 ] then exit 1 fi

/usr/bin/xcrun -sdk iphoneos PackageApplication -v "${PROJECT_BUILDDIR}/${APPLICATION_NAME}.app" -o "${BUILD_HISTORY_DIR}/${APPLICATION_NAME}.ipa" --sign "${DEVELOPPER_NAME}" #--embed "${PROVISONNING_PROFILE}"