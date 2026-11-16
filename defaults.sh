#!/bin/bash

# Use a .env file to easily override values in your fork
if [[ -f .env ]]; then
  source .env
fi

if [[ -z $EXTRA_TAGS ]]; then
  EXTRA_TAGS=()
fi

if [[ $TAG_WITH_DATE = 1 || $TAG_WITH_DATE = 'yes' || $1 = '--tag-with-date' ]]; then
  EXTRA_TAGS+=($(date +%Y%m%d))
fi

MAINTAINER=${MAINTAINER:-"Conneqt BV"}
DOCKER_HUB_USERNAME=${DOCKER_HUB_USERNAME:-"conneqthub"}
TZ=${TZ:-"UTC"}

# Copy the local SDK and Android toolchain when available; otherwise use .NET 11 defaults.
SDK_VERSION=${SDK_VERSION:-"$(dotnet --version 2>/dev/null || true)"}
SDK_VERSION=${SDK_VERSION:-"11.0.100"}
DOTNET_VERSION=${DOTNET_VERSION:-"$(<<<$SDK_VERSION cut -d. -f1).$(<<<$SDK_VERSION cut -d. -f2)"}
JAVA_VERSION=${JAVA_VERSION:-"25"}
ANDROID_API=${ANDROID_API:-"$(dotnet workload list 2>/dev/null | sed -En 's|^android\s+([0-9]+).+$|\1|p' || true)"}
ANDROID_API=${ANDROID_API:-"37.0"}
# API 37 and newer use an explicit minor version in SDK package names.
if [[ $ANDROID_API =~ ^[0-9]+$ && $ANDROID_API -ge 37 ]]; then
  ANDROID_API+=.0
fi
# sdkmanager is optional on the host. Prefer the highest matching stable build-tools version.
BUILD_TOOLS_VERSION=${BUILD_TOOLS_VERSION:-$(sdkmanager --list 2>/dev/null | sed -En "s|^[[:space:]]*build-tools;(${ANDROID_API%%.*}\.[0-9]+\.[0-9]+)[[:space:]]+.*$|\1|p" | sort -Vu | tail -1 || true)}
BUILD_TOOLS_VERSION=${BUILD_TOOLS_VERSION:-"37.0.0"}
