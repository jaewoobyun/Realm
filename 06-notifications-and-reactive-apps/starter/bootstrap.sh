#! /bin/bash

## Written by Shai Mishali (c) RayWenderlich.com Jan 3rd, 2018
##
## This script installs all needed dependencies and prebuilds the project
## so the playground loads as quickly as possible when the project is opened.

## Realm release
REALM_VERSION="3.15.0"

## Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

## Some helper methods
fatalError() {
    echo -e "${RED}(!!) $1${NC}"
    exit 1
}

info() {
    echo -e "${GREEN}▶ $1${NC}"
}

loader() {
    printf "${BLUE}"
    while kill -0 $1 2>/dev/null; do
        printf  "▓"
        sleep 1
    done
    printf "${NC}\n"
}

## Make sure we have everything needed
if ! git --version > /dev/null 2>&1; then
    fatalError "git is not installed"
fi

if ! xcodebuild -usage > /dev/null 2>&1; then
    fatalError "Xcode is not installed"
fi

## Clear screen before starting up
clear


# Print out RW logo
echo -e $GREEN
cat << "EOF"
▓▓▓▓▓▓▓▓▓▓▄▄                           
▓▓▓▓▓▓▓▓▓▓▓▓▓██▄▄                       
▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▌                      
▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▌                     ▓
▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓                    ▄▓▓
▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▀                    ▄▓▓▓
▓▓▓▓▓▓▓▓▓▓▓▓▓▀                     ▄▓▓▓▓
▓▓▓▓▓▓▓▓▓█▀                       ▓▓▓▓▓▓
▓▓▓▓▓▓▓▓▓▌                      ▄▓▓▓▓▓▓▓
▓▓▓▓▓▓▓▓▓▓▌         ▓          ▄▓▓▓▓▓▓▓▓
▓▓▓▓▓▓▓▓▓▓▓▌      ▄▓▓▓▄       ▄▓▓▓▓▓▓▓▓▓
▓▓▓▓▓▓▓▓▓▓▓▓▄    ▓▓▓▓▓▓▓     ▓▓▓▓▓▓▓▓▓▓▓
▓▓▓▓▓▓▓▓▓▓▓▓▓▄  ▓▓▓▓▓▓▓▓▓  ▄▓▓▓▓▓▓▓▓▓▓▓▓
▓▓▓▓▓▓▓▓▓▓▓▓▓▓▄▓▓▓▓▓▓▓▓▓▓▓▄▓▓▓▓▓▓▓▓▓▓▓▓▓
▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
EOF
echo -e $NC

## Clear caches
info "🗑️  Cleaning artficats"
rm -rf build.log
rm -rf ~/Library/Developer/Xcode/DerivedData/RealmPlayground-* 2> /dev/null
rm -rf RealmPlayground.xcworkspace/xcuserdata
rm -rf Realm

if [ "$1" == "clean" ]; then
    info "💥  Clearing Realm Cache"
    rm -rf /tmp/RW
fi

## Get Realm
REALM_CACHE="/tmp/RW/Realm/${REALM_VERSION}"

if [ -d $REALM_CACHE ]; then
    info "👻  Using cached copy of Realm v${REALM_VERSION} ..."
else
    info "🌍  Fetching Realm v${REALM_VERSION} ..."

    ## Get Realm
    git clone --recurse-submodules -j8 -b v${REALM_VERSION} https://github.com/realm/realm-cocoa ${REALM_CACHE} &> build.log & CLONEPID=$!

    loader $CLONEPID
fi

cp -R $REALM_CACHE ./Realm

info "🚧  Building RealmSwift ..."
xcodebuild build -scheme RealmSwift -workspace RealmPlayground.xcworkspace -sdk iphonesimulator -destination "name=iPhone 8" &> build.log & BUILDPID=$!

loader $BUILDPID

info "🎁  Wrapping up ..."

XCUSERDATA="Realm/Realm.xcodeproj/xcuserdata/${USER}.xcuserdatad/xcschemes"
mkdir -p $XCUSERDATA

cat > "$XCUSERDATA/xcschememanagement.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>SchemeUserState</key>
	<dict>
		<key>Realm.xcscheme_^#shared#^_</key>
		<dict>
			<key>orderHint</key>
			<integer>1</integer>
		</dict>
		<key>Check For Supported Swift Version.xcscheme</key>
		<dict>
			<key>isShown</key>
			<false/>
		</dict>
		<key>Object Server Tests.xcscheme_^#shared#^_</key>
		<dict>
			<key>isShown</key>
			<false/>
		</dict>
		<key>Realm iOS static.xcscheme_^#shared#^_</key>
		<dict>
			<key>isShown</key>
			<false/>
		</dict>
		<key>RealmSwift.xcscheme_^#shared#^_</key>
		<dict>
			<key>isShown</key>
			<false/>
		</dict>
		<key>TestHost.xcscheme_^#shared#^_</key>
		<dict>
			<key>isShown</key>
			<false/>
		</dict>
	</dict>
</dict>
</plist>
EOF

info "🎉  Let's get started!"
open RealmPlayground.xcworkspace
