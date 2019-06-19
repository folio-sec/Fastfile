#!/bin/bash
set -ex

cp -rf "${PODS_CONFIGURATION_BUILD_DIR}/FirebaseInAppMessagingDisplay/InAppMessagingDisplayResources.bundle" \
  "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/"
