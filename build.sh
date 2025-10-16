#!/bin/bash
set -eo pipefail

source defaults.sh
function usage {
  cat <<EOF
Usage: $0 [-h] [-p]
OPTIONS:
  -h        Show this message
  -d        Run docker with --debug flag
  -p        Push after build
ERROR CODES:
  1         Invalid option
EOF
}

function config {
  cat <<EOF
────────────────────┬────────────────────
Maintainer          │ ${MAINTAINER}
Docker hub username │ ${DOCKER_HUB_USERNAME}
Time zone           │ ${TZ}
SDK version         │ ${SDK_VERSION}
Java version        │ ${JAVA_VERSION}
Android API         │ ${ANDROID_API}
Build tools version │ ${BUILD_TOOLS_VERSION}
MAUI version        │ ${MAUI_VERSION}
Extra tags          │ ${EXTRA_TAGS[@]}
Push after build    │ ${push:-No}
────────────────────┴────────────────────
EOF
}

optstring="hpd"
unset push
unset debug
unset help

while getopts ${optstring} arg; do
  case ${arg} in
  h)
    usage
    config
    exit 0
    ;;
  p)
    push=Yes
    ;;
  d)
    debug=--debug
    ;;
  ?)
    echo "Invalid option: -${OPTARG}."
    exit 1
    ;;
  esac
done

config

COMMON_BUILD_ARGS=(
  "--build-arg" "MAINTAINER=${MAINTAINER}"
  "--build-arg" "TZ=${TZ}"
  "--build-arg" "DOTNET_VERSION=${DOTNET_VERSION}"
  "--build-arg" "SDK_VERSION=${SDK_VERSION}"
  "--build-arg" "JAVA_VERSION=${JAVA_VERSION}"
  "--build-arg" "ANDROID_API=${ANDROID_API}"
  "--build-arg" "BUILD_TOOLS_VERSION=${BUILD_TOOLS_VERSION}"
  "--build-arg" "MAUI_VERSION=${MAUI_VERSION}"
  "--build-arg" "SDK_VERSION=${SDK_VERSION}"
)

docker build $debug -t "${DOCKER_HUB_USERNAME}/dotnet-maui-android:latest" "${COMMON_BUILD_ARGS[@]}" .
if [ -n "${SDK_VERSION}" ]; then
  # Tag exact SDK version
  docker tag "${DOCKER_HUB_USERNAME}/dotnet-maui-android:latest" "${DOCKER_HUB_USERNAME}/dotnet-maui-android:${SDK_VERSION}"
  # Tag .NET SDK version
  docker tag "${DOCKER_HUB_USERNAME}/dotnet-maui-android:latest" "${DOCKER_HUB_USERNAME}/dotnet-maui-android:${DOTNET_VERSION}"
fi

for tag in ${EXTRA_TAGS[@]}; do
  echo "Tagging ${DOCKER_HUB_USERNAME}/dotnet-maui-android:latest as ${DOCKER_HUB_USERNAME}/dotnet-maui-android:${tag}"
  docker tag "${DOCKER_HUB_USERNAME}/dotnet-maui-android:latest" "${DOCKER_HUB_USERNAME}/dotnet-maui-android:${tag}"
done

if [ -n "${push}" ]; then
  for tag in "${SDK_VERSION}" "${DOTNET_VERSION}" ${EXTRA_TAGS[@]} latest; do
    docker push "${DOCKER_HUB_USERNAME}/dotnet-maui-android:${tag}"
  done
fi
