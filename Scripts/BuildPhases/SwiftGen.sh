#!/bin/bash
set -ex

"${SRCROOT}/Pods/SwiftGen/bin/swiftgen" xcassets "${SRCROOT}/Folio/Assets.xcassets" \
  --output "${SRCROOT}/Folio/Swiftgen/ImageAssets.swift" \
  -t swift4 \
  --param forceProvidesNamespaces=true \
  --param allValues=true
