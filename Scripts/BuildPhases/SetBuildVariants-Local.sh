#!/bin/bash
set -ex

function get_local_ip() {
  networksetup -listallnetworkservices | sed '1d' | while read s
  do
    if networksetup -getinfo "$s" | grep -q '^IP address: '; then
      i=`networksetup -getinfo "$s" | awk -F': ' '/^IP address: /{print $2}'`
      ifconfig | awk '/inet /{print $2}' | grep "$i"
    fi
  done | head -1
}

API_HOST=$(get_local_ip)

BUNDLE_IDENTIFIER=com.folio-sec.folio-app-develop
BUILD_VARIANTS_PROJECT=_BuildVariants-Project.xcconfig
BUILD_VARIANTS_APP=_BuildVariants-Folio.xcconfig

cat << EOT > "${SRCROOT}/Configurations/${BUILD_VARIANTS_PROJECT}"
CONTAINING_APP_BUNDLE_IDENTIFIER = ${BUNDLE_IDENTIFIER}
GOOGLESERVICE_INFO_PLIST_DIR = ${PROJECT_DIR}/${TARGET_NAME}/FirebaseOptions/Debug

API_HOST = ${API_HOST}
EOT

cat << 'EOT' >> "${SRCROOT}/Configurations/${BUILD_VARIANTS_PROJECT}"
API_BASE_PATH = http:$()/$()/${API_HOST}:3000
WEB_HOST = ${WEB_HOST}
WEB_BASE_PATH = http:$()/$()/$(WEB_HOST)
EOT

cat << EOT > "${SRCROOT}/Configurations/${BUILD_VARIANTS_APP}"
PRODUCT_BUNDLE_IDENTIFIER = ${BUNDLE_IDENTIFIER}
ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon-develop
EOT
