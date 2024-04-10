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

# You must have the most recent android & maui-android workload installed for this to work.
# The .NET‌ CLI doesn't show version numbers of workloads that are not already installed.
MAUI_VERSION=${MAUI_VERSION:-"$(dotnet workload list | sed -En 's|^maui-android\s+([^/]+)/.+$|\1|p')"}
DOTNET_VERSION=${DOTNET_VERSION:-"8.0"}
JAVA_VERSION=${JAVA_VERSION:-"17"}
ANDROID_API=${ANDROID_API:-"$(dotnet workload list | sed -En 's|^android\s+([0-9]+).+$|\1|p')"}
BUILD_TOOLS_VERSION=${BUILD_TOOLS_VERSION:-$(sdkmanager --list 2>/dev/null | grep -E "build-tools;(${ANDROID_API}\.[0-9]+\.[0-9]+)\s+.+$" | tail -1 | sed -En 's|^.+build-tools;(\S+).+$|\1|p')}
