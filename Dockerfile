ARG DOTNET_VERSION
FROM mcr.microsoft.com/dotnet/sdk:${DOTNET_VERSION} AS dotnet-maui-android
ARG MAINTAINER
ARG TZ
ARG JAVA_VERSION
ARG ANDROID_API
ARG BUILD_TOOLS_VERSION

LABEL maintainer=${MAINTAINER}
ENV TZ=${TZ}
ENV DOTNET_CLI_TELEMETRY_OPTOUT=1

# SSH client
RUN apt-get update && \
  apt-get install -y openssh-client && \
  rm -rf /var/lib/apt/lists/*

# MONO
RUN apt-get update && \
  apt-get install -y apt-transport-https gnupg ca-certificates curl && \
  # Download tool to correctly add repository because mono's installation instructions are outdated.
  curl -o ./add-repository https://gist.githubusercontent.com/Ghostbird/83eb5bcd2ffd4a6b6966137a2e1c4caf && \
  sh ./add-repository "https://keyserver.ubuntu.com/pks/lookup?search=0x3fa7e0328081bff6a14da29aa6a19b38d3d831ef&op=get" "deb https://download.mono-project.com/repo/debian stable-buster main" mono-official-stable.list && \
  rm ./add-repository && \
  apt-get update && \
  apt-get install -y mono-complete nuget && \
  rm -rf /var/lib/apt/lists/*

# JAVA
RUN apt-get update && \
  apt-get install -y openjdk-${JAVA_VERSION}-jdk-headless && \
  rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-${JAVA_VERSION}-openjdk-amd64/

# Android SDK Manager
RUN echo "deb http://deb.debian.org/debian bullseye-backports main contrib" > /etc/apt/sources.list.d/bullseye-backports.list && \
  echo "deb-src http://deb.debian.org/debian bullseye-backports main contrib" >> /etc/apt/sources.list.d/bullseye-backports.list && \
  apt-get update && \
  apt-get install -t bullseye-backports -y sdkmanager && \
  rm -rf /var/lib/apt/lists/*

ENV ANDROID_SDK_ROOT=/usr/lib/android-sdk

# Android toolchain
RUN sdkmanager "platform-tools" "build-tools;${BUILD_TOOLS_VERSION}" "platforms;android-${ANDROID_API}"

# MAUI
RUN dotnet workload install maui-android
