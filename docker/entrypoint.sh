#!/usr/bin/env bash
pushd /home/openwrt/openwrt || exit
if ! [ "$SKIP_FEEDS_UPDATE_AND_INSTALL" = "true" ]; then
  ./scripts/feeds update -a
  ./scripts/feeds install -a
fi

### How to create a config diff: https://openwrt.org/docs/guide-developer/toolchain/use-buildsystem#diff_file
# make menuconfig
# ./scripts/diffconfig.sh > diffconfig
# cp diffconfig docker/build-configs/<manufacturer>/<series>/<model>/<profile>.buildinfo

if ! [ -z "$BUILD_CONFIG_FILE_URL" ]; then
  wget "$BUILD_CONFIG_FILE_URL" -O .config
elif ! [ -z "$BUILD_CONFIG_FILE_PATH" ]; then
  cp "docker/build-configs/$BUILD_CONFIG_FILE_PATH" .config
fi

if [ "$MENUCONFIG" = "true" ]; then
  make menuconfig
  echo "Generated config file: "
  cat .config
  if [ "$SKIP_BUILD" = "true" ]; then
    popd || exit
  fi
fi

VERBOSE_BUILD_ARGS="-j $(($(nproc)+1)) V=s"
NON_VERBOSE_BUILD_ARGS="-j $(($(nproc)+1))"
if [ "$VERBOSE" = "true" ]; then
  BUILD_ARGS="$VERBOSE_BUILD_ARGS"
else
  BUILD_ARGS="$NON_VERBOSE_BUILD_ARGS"
fi
BUILD_START_SECONDS=$SECONDS
echo "Starting build at $(date)..."
# Expand to full config and build
make $BUILD_ARGS $BUILD_TARGETS
echo "Build ended at $(date) (Took $((( SECONDS - BUILD_START_SECONDS)/60)) minutes)"

popd || exit