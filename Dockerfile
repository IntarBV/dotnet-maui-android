ARG DOTNET_VERSION=10.0
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
  # On Debian the SDK manager was a separately installable package.
  # On Ubuntu try to find and install the highest versioned google-android-cmdline-tools-…-installer.
  DEBIAN_FRONTEND=noninteractive apt-get install -y "google-android-cmdline-tools-$(apt-cache search google-android-cmdline-tools- | sed -E 's/^google-android-cmdline-tools-(.+)-installer.+$/\1/' | sort -n | tail -n1)-installer"
  rm -rf /var/lib/apt/lists/*
EOF

# This one is used by the some Android tooling
ENV ANDROID_SDK_ROOT=/usr/lib/android-sdk
# This one is used by MAUI builds
ENV AndroidSdkDirectory=/usr/lib/android-sdk

ARG ANDROID_API=36
ARG BUILD_TOOLS_VERSION=36.1.0
RUN <<EOF
  # Android toolchain
  set -e
  yes | sdkmanager --licenses
  sdkmanager "platform-tools" "build-tools;${BUILD_TOOLS_VERSION}" "platforms;android-${ANDROID_API}"
EOF

# We can only install the latest version, the ARG is to cache bust if that version changed
ARG SDK_VERSION
RUN <<EOF
  # MAUI
  set -e
  dotnet workload install maui-android
EOF
