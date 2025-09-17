ARG DOTNET_VERSION=9.0
ARG MAINTAINER="conneqt B.V."
ARG TZ="UTC"
FROM mcr.microsoft.com/dotnet/sdk:${DOTNET_VERSION} AS dotnet-maui-android
ARG MAINTAINER
ARG TZ

LABEL maintainer=${MAINTAINER}
ENV TZ=${TZ}
ENV DOTNET_CLI_TELEMETRY_OPTOUT=1

RUN <<EOF
  # SSH client
  set -e
  apt-get update 
  apt-get install -y openssh-client 
  rm -rf /var/lib/apt/lists/*
EOF

RUN <<EOF
  # Mono
  set -e
  apt-get update
  apt-get install -y apt-transport-https gnupg ca-certificates curl 
  # Download tool to correctly add repository because mono's installation instructions are outdated.
  curl -o ./add-repository https://gist.githubusercontent.com/Ghostbird/83eb5bcd2ffd4a6b6966137a2e1c4caf 
  sh ./add-repository "https://keyserver.ubuntu.com/pks/lookup?search=0x3fa7e0328081bff6a14da29aa6a19b38d3d831ef&op=get" "deb https://download.mono-project.com/repo/debian stable-buster main" mono-official-stable.list 
  rm ./add-repository 
  apt-get update 
  apt-get install -y mono-complete nuget 
  rm -rf /var/lib/apt/lists/*
EOF

ARG JAVA_VERSION=17
RUN <<EOF
  # Java
  set -e
  apt-get update
  apt-get install -y openjdk-${JAVA_VERSION}-jdk-headless
  rm -rf /var/lib/apt/lists/*
EOF

ENV JAVA_HOME=/usr/lib/jvm/java-${JAVA_VERSION}-openjdk-amd64/

RUN <<EOF
  # Android SDK Manager
  set -e
  apt-get update
  apt-get install -y sdkmanager
  rm -rf /var/lib/apt/lists/*
EOF

ENV ANDROID_SDK_ROOT=/usr/lib/android-sdk

ARG ANDROID_API=35
ARG BUILD_TOOLS_VERSION=35.0.0
RUN <<EOF
  # Android toolchain
  set -e
  sdkmanager "platform-tools" "build-tools;${BUILD_TOOLS_VERSION}" "platforms;android-${ANDROID_API}"
EOF

# We can only install the latest version, the ARG is to cache bust if that version changed
ARG MAUI_VERSION
RUN <<EOF
  # MAUI
  set -e
  dotnet workload install maui-android
EOF
  