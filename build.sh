#!/bin/bash
source defaults.sh
function usage {
  cat << EOF
Usage: $0 [-h] -p
OPTIONS:
  -h        Show this message
  -p        Push after build
ERROR CODES:
  1         Invalid option
EOF
}

optstring=":h:p"
unset push

while getopts ${optstring} arg; do
  case ${arg} in
    h)
      usage
      ;;
    p)
      push=Yes
      ;;
    ?)
      echo "Invalid option: -${OPTARG}."
      exit 1
      ;;
  esac
done
echo "Maintainer:           ${MAINTAINER}"
echo "Docker hub username:  ${DOCKER_HUB_USERNAME}"
echo "Time zone:            ${TZ}"
echo ".NET version:         ${DOTNET_VERSION}"
echo "Java version:         ${JAVA_VERSION}"
echo "Android API:          ${ANDROID_API}"
echo "Build tools version:  ${BUILD_TOOLS_VERSION}"
echo "MAUI version:         ${MAUI_VERSION}"
echo "Extra tags:           ${EXTRA_TAGS[@]}"
echo "Push after build:     ${push:-No}"

COMMON_BUILD_ARGS=(
  "--build-arg" "MAINTAINER=${MAINTAINER}"
  "--build-arg" "TZ=${TZ}"
  "--build-arg" "DOTNET_VERSION=${DOTNET_VERSION}"
  "--build-arg" "JAVA_VERSION=${JAVA_VERSION}"
  "--build-arg" "ANDROID_API=${ANDROID_API}"
  "--build-arg" "BUILD_TOOLS_VERSION=${BUILD_TOOLS_VERSION}"
  "--build-arg" "MAUI_VERSION=${MAUI_VERSION}"
)

docker build -t "${DOCKER_HUB_USERNAME}/dotnet-maui-android:latest" "${COMMON_BUILD_ARGS[@]}" .
if [ -n "${MAUI_VERSION}" ]
then
  docker tag "${DOCKER_HUB_USERNAME}/dotnet-maui-android:latest" "${DOCKER_HUB_USERNAME}/dotnet-maui-android:${MAUI_VERSION}"
fi


for tag in ${EXTRA_TAGS[@]}
do
  echo "Tagging ${DOCKER_HUB_USERNAME}/dotnet-maui-android:latest as ${DOCKER_HUB_USERNAME}/dotnet-maui-android:${tag}"
  docker tag "${DOCKER_HUB_USERNAME}/dotnet-maui-android:latest" "${DOCKER_HUB_USERNAME}/dotnet-maui-android:${tag}"
done

if [ -n "${push}" ]
then
  for tag in ${MAUI_VERSION} ${EXTRA_TAGS[@]} latest
  do
    docker push "${DOCKER_HUB_USERNAME}/dotnet-maui-android:${tag}"
  done
fi
