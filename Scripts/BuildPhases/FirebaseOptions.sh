#!/bin/bash
set -ex

GOOGLESERVICE_INFO_PLIST=GoogleService-Info.plist
GOOGLESERVICE_INFO_PLIST_DIR=${GOOGLESERVICE_INFO_PLIST_DIR}

# Make sure the dev version of GoogleService-Info.plist exists
echo "Looking for ${GOOGLESERVICE_INFO_PLIST} in ${GOOGLESERVICE_INFO_PLIST_DIR}"
if [ ! -f "${GOOGLESERVICE_INFO_PLIST_DIR}/${GOOGLESERVICE_INFO_PLIST}" ]
then
    echo "No GoogleService-Info.plist found. Please ensure it's in the proper directory."
    exit 1
fi

# Get a reference to the destination location for the GoogleService-Info.plist
PLIST_DESTINATION=${BUILT_PRODUCTS_DIR}/${FULL_PRODUCT_NAME}
echo "Will copy ${GOOGLESERVICE_INFO_PLIST} to final destination: ${PLIST_DESTINATION}"
cp "${GOOGLESERVICE_INFO_PLIST_DIR}/${GOOGLESERVICE_INFO_PLIST}" "${PLIST_DESTINATION}"
