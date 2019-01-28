#!/bin/bash

whichapp() {
  local appNameOrBundleId=$1 isAppName=0 bundleId
  # Determine whether an app *name* or *bundle ID* was specified.
  [[ $appNameOrBundleId =~ \.[aA][pP][pP]$ || $appNameOrBundleId =~ ^[^.]+$ ]] && isAppName=1
  if (( isAppName )); then # an application NAME was specified
    # Translate to a bundle ID first.
    bundleId=$(osascript -e "id of application \"$appNameOrBundleId\"" 2>/dev/null) ||
      { echo "$FUNCNAME: ERROR: Application with specified name not found: $appNameOrBundleId" 1>&2; return 1; }
  else # a BUNDLE ID was specified
    bundleId=$appNameOrBundleId
  fi
    # Let AppleScript determine the full bundle path.
  fullPath=$(osascript -e "tell application \"Finder\" to POSIX path of (get application file id \"$bundleId\" as alias)" 2>/dev/null ||
    { echo "$FUNCNAME: ERROR: Application with specified bundle ID not found: $bundleId" 1>&2; return 1; })
  printf '%s\n' "$fullPath"
  # Warn about /Volumes/... paths, because applications launched from mounted
  # devices aren't persistently installed.
  if [[ $fullPath == /Volumes/* ]]; then
    echo "NOTE: Application is not persistently installed, due to being located on a mounted volume." >&2 
  fi
}

whichapp XQuartz
if [ ! $! == '/Applications/Utilities/XQuartz.app/' ]; then
  echo "You need to install XQuartz"
  echo "Download from https://www.xquartz.org/"
  exit 1
fi

open -a XQuartz &
echo "XQuartz booting up..."

#Start Socat server
socat TCP-LISTEN:6000,reuseaddr,fork UNIX-CLIENT:\"$DISPLAY\" &
SOCAT_PID=$!

#Get current computer IP
COMPUTER_IP=$(ifconfig | grep "inet " | grep -Fv 127.0.0.1 | awk '{print $2}')

#Display context
echo "XQuartz running with: $XQUARTZ_PID"
echo "socat running with: $SOCAT_PID"
echo "Host ip: $COMPUTER_IP"

#Run the RIDE UI
echo "Please close RIDE before terminating this script"

docker run --rm -e DISPLAY=$COMPUTER_IP:0 -v $PWD:/robot softsam/robotframework-ride

#Wait to kill socat
read  -n 1 -p "Press [enter] to finish" mainmenuinput
kill $SOCAT_PID
pgrep -f XQuartz | cut -f1 -d " " - | xargs kill -9