#!/usr/bin/env bash
if [ -z "$TERM" ]; then
  echo "This openwrt builder requires an interactive console to run. Try:"
  echo "docker run -it openwrt-builder"
  echo "or"
  echo "docker compose run --rm openwrt-builder"
fi
pushd /home/openwrt/openwrt || exit
if [ "$FORCE_FEEDS_REFRESH" = "true" ] || [ ! -d feeds ]; then
  echo "Updating feeds..."
  ./scripts/feeds update -a
  echo "Installing feeds..."
  ./scripts/feeds install -a
  echo "Feeds updated and installed."
fi

### How to create a config diff: https://openwrt.org/docs/guide-developer/toolchain/use-buildsystem#diff_file
# make menuconfig
# ./scripts/diffconfig.sh > diffconfig
# cp diffconfig docker/build-configs/<manufacturer>/<series>/<model>/<profile>.buildinfo

if [ -n "$BUILD_CONFIG_FILE_PATH" ]; then
  echo "Copying config from docker/build-configs/$BUILD_CONFIG_FILE_PATH ..."
  cp "docker/build-configs/$BUILD_CONFIG_FILE_PATH" .config
elif [ -n "$BUILD_CONFIG_FILE_URL" ]; then
  echo "No BUILD_CONFIG_FILE_PATH provided. Downloading config from $BUILD_CONFIG_FILE_URL ..."
  wget "$BUILD_CONFIG_FILE_URL" -O .config
else
  echo "No BUILD_CONFIG_FILE_PATH or BUILD_CONFIG_FILE_URL provided; Base .config file will not be overridden with either of them."
fi

if [ "$MENUCONFIG" = "true" ]; then
  echo "Generating config file..."
  make menuconfig
  echo "Generated config file:"
  cat .config
fi

if [ -n "$BUILD_TARGETS" ]; then
  VERBOSE_BUILD_ARGS="-j1 V=s"
  NON_VERBOSE_BUILD_ARGS="-j$(($(nproc)+1))"
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
else
  echo "No BUILD_TARGETS provided. Exiting..."
fi

popd || exit