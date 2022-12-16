source defaults.sh

echo "Maintainer:           ${MAINTAINER}"
echo "Docker hub username:  ${DOCKER_HUB_USERNAME}"
echo "Time zone:            ${TZ}"
echo ".NET version:         ${DOTNET_VERSION}"
echo "Java version:         ${JAVA_VERSION}"
echo "Android API:          ${ANDROID_API}"
echo "Build tools version:  ${BUILD_TOOLS_VERSION}"
echo "Extra tags:           ${EXTRA_TAGS[@]}"

COMMON_BUILD_ARGS=(
  "--build-arg" "MAINTAINER=${MAINTAINER}"
  "--build-arg" "TZ=${TZ}"
  "--build-arg" "DOTNET_VERSION=${DOTNET_VERSION}"
  "--build-arg" "JAVA_VERSION=${JAVA_VERSION}"
  "--build-arg" "ANDROID_API=${ANDROID_API}"
  "--build-arg" "BUILD_TOOLS_VERSION=${BUILD_TOOLS_VERSION}"
)

docker build -t "${DOCKER_HUB_USERNAME}/dotnet-maui-android:latest" "${COMMON_BUILD_ARGS[@]}" .
docker tag "${DOCKER_HUB_USERNAME}/dotnet-maui-android:latest" "${DOCKER_HUB_USERNAME}/dotnet-maui-android:${DOTNET_VERSION}"


for tag in ${EXTRA_TAGS[@]}
do
  echo "Tagging ${DOCKER_HUB_USERNAME}/dotnet-maui-android:latest as ${DOCKER_HUB_USERNAME}/dotnet-maui-android:${tag}"
  docker tag "${DOCKER_HUB_USERNAME}/dotnet-maui-android:latest" "${DOCKER_HUB_USERNAME}/dotnet-maui-android:${tag}"
done
