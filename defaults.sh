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

# You must have the most recent android & maui-android workload installed for automatic defaults to work.
# The .NET‌ CLI doesn't show version numbers of workloads that are not already installed.
MAUI_VERSION=${MAUI_VERSION:-"$(dotnet workload list | sed -En 's|^maui-android\s+([^/]+)/.+$|\1|p')"}
SDK_VERSION=${SDK_VERSION:-"$(dotnet workload list | sed -En 's|^maui-android.+SDK ([.0-9]+).+$|\1|p')"}
DOTNET_VERSION=${DOTNET_VERSION:-"$(<<<$SDK_VERSION cut -d. -f1).$(<<<$SDK_VERSION cut -d. -f2)"}
JAVA_VERSION=${JAVA_VERSION:-"17"}
ANDROID_API=${ANDROID_API:-"$(dotnet workload list | sed -En 's|^android\s+([0-9]+).+$|\1|p')"}
# You must have the Android SDK manager installed and available in the PATH for this to work.
BUILD_TOOLS_VERSION=${BUILD_TOOLS_VERSION:-$(sdkmanager --list 2>/dev/null | grep -E "build-tools;(${ANDROID_API}\.[0-9]+\.[0-9]+)\s+.+$" | tail -1 | sed -En 's|^.+build-tools;(\S+).+$|\1|p')}

if [[ -z "${SDK_VERSION}" ]]
then
  cat <<EOF
WARNING: Could not calculate SDK version to use.
  Set the SDK_VERSION variable in the environment,
  or install the latest dotnet workload android,
  with your dotnet workload config in manifest mode.

  # dotnet workload config --update-mode manifests
  # dotnet workload install maui-android
EOF
fi

if [[ -z "${ANDROID_API}" ]]
then
  cat <<EOF
WARNING: Could not calculate Android API version to use.
  Set the ANDROID_API variable in the environment,
  or install the latest dotnet workload android,
  with your dotnet workload config in manifest mode.

  # dotnet workload config --update-mode manifests
  # dotnet workload install android
EOF
fi
