#!/bin/bash

# API levels available and which build tools version corresponds to it.
declare -A BUILD_TOOLS=( [31]="31.0.0" [32]="32.0.0" [33]="33.0.2" [34]="34.0.0" )

# Use a .env file to easily override values in your fork
if [[ -f .env ]]
then
  source .env
fi

if [[ -z $EXTRA_TAGS ]]
then
  EXTRA_TAGS=()
fi

if [[ $TAG_WITH_DATE = 1 || $TAG_WITH_DATE = 'yes' || $1 = '--tag-with-date' ]]
then
  EXTRA_TAGS+=($(date +%Y%m%d))
fi

MAINTAINER=${MAINTAINER:-"Conneqt BV"}
DOCKER_HUB_USERNAME=${DOCKER_HUB_USERNAME:-"conneqthub"}
TZ=${TZ:-"UTC"}

# You must have the most recent maui-android workload installed for this to work.
# The .NET‌ CLI doesn't show version numbers of workloads that are not already installed. 
MAUI_VERSION=${MAUI_VERSION:-"$(dotnet workload list | sed -En 's|^maui-android +([^/]+)/.+$|\1|p')"}
DOTNET_VERSION=${DOTNET_VERSION:-"8.0"}
JAVA_VERSION=${JAVA_VERSION:-"17"}
ANDROID_API=${ANDROID_API:-"34"}
BUILD_TOOLS_VERSION=${BUILD_TOOLS[${ANDROID_API}]}
