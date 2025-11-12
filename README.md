# Docker image .NET MAUI Android

Builds a [docker image](https://hub.docker.com/r/conneqthub/dotnet-maui-android) that allows containerised builds of .NET 10.0 MAUI Android 36 apps.

The goal of the resulting image is that you can run `dotnet build` on a MAUI Android workspace without first needing to install additional software.

## Basic approach

- Start the docker image. It's recommended to do so from a .NET major.minor version tag, (e.g. `:10.0`) and not `latest`.
- Get the source code you want to build
- `dotnet build`

## Minimal example of steps in Github Actions

```yaml
steps:
  - name: Checkout
    uses: actions/checkout@v4
  - name: Build
    shell: bash
    run: dotnet build
  - name: Upload AAB
    uses: actions/upload-artifact@v4
    with:
      name: aab
      path: bin/Release/net10.0-android/com.example.app-Signed.aab
      if-no-files-found: error
      retention-days: 1
```

## Building

There are two possible approaches:

- Sort of copy your current development machine configuration into a docker image
- Create a docker image based on a specifically configured set of versions that is not present on your local system

### Copy local versions

If your current machine is set-up to build .NET‌ MAUI Android apps, and you want a docker image with similar capabilities:

1. Clone this repo
2. Create a .env file where you set:

    ```.env
      MAINTAINER=Your (company) name
      DOCKER_HUB_USERNAME=Your dockerhub username
    ```

3. Run `./build.sh`
4. Test the image
5. Run `./build.sh -p` to push the image to your docker hub. It will be tagged with `latest`, the exact .NET SDK Version and the overarching .NET SDK major.minor version.

### Manually choose versions

1. Clone this repo
2. Create a .env file where you set the versions you want:

    ```.env
      MAINTAINER=Your (company) name
      DOCKER_HUB_USERNAME=Your dockerhub username
      # Change the versions below to whatever you want.
      MAUI_VERSION=10.0.0-rc.2.25504.7
      SDK_VERSION=10.0.100-rc.2
      ANDROID_API=36
      BUILD_TOOLS_VERSION=36.1.0
      # Optional: This is the default. Lower than 17 probably won't work.
      # JAVA_VERSION=17
    ```

3. Run `./build.sh`
4. Test the image
5. Run `./build.sh -p` to push the image to your docker hub. It will be tagged with `latest`, the exact .NET SDK Version and the overarching .NET SDK major.minor version.
