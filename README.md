# Docker image .NET MAUI Android

Builds a [docker image](https://hub.docker.com/r/conneqthub/dotnet-maui-android) that allows containerised builds of .NET 10.0 MAUI Android 36 apps.

The goal of the resulting image is that you can run `dotnet build` on a MAUI Android workspace without first needing to install additional software.

## Basic approach

- Start the docker image
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
