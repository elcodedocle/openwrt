# Basic Docker builder for OpenWRT firmwares

> [!WARNING]
> This builder uses a docker volume to expose this repo's contents to the
> container. OpenWRT does not build as root, so make sure UID 1000 has write
> access to the repo directory (E.g. git clone with or chown to UID 1000 user;
> with WSL2 in Windows)

## Usage examples

_Run in [this folder](../docker)_

Asus RT-AX52 default profile:

```bash
docker compose up BUILD_CONFIG_FILE_URL=https://downloads.openwrt.org/releases/24.10.4/targets/mediatek/filogic/config.buildinfo
```

Asus RT-AX52 custom profile:

```bash
docker compose up -e BUILD_CONFIG_FILE_PATH=mediatek/filogic/asus_rt-ax52/base.buildinfo
```

Create/tune the config before build:

```bash
# use -e SKIP_BUILD=true if you just want to generate the config
docker compose up -e MENUCONFIG=true
```

Go grab some popcorn you can probably make with the heat from the CPU running
the stuff, and watch it build for around 90 minutes, unless you have an absolute
beast of a machine. For an incremental build you can skip clean and/or [build a
single package](https://openwrt.org/docs/guide-developer/toolchain/single.package)
by overriding the make command build targets:

```bash
# builds only the ncurses package
docker compose up -e "BUILD_TARGETS=package/ncurses/compile"
```

You can also pass `-e SKIP_FEEDS_UPDATE_AND_INSTALL=true` to skip the feeds
update & install if already present.

## Cleanup

To force openwrt-builder container docker image regeneration, run:

```bash
docker compose down --rmi all
rm -rf bin build_dir dl feeds staging_dir tmp .config .config.old .toolchain_build_ver
```

## More info

https://openwrt.org/docs/guide-developer/toolchain/install-buildsystem
https://openwrt.org/docs/guide-developer/toolchain/use-buildsystem
https://openwrt.org/docs/guide-developer/toolchain/single.package
https://downloads.openwrt.org/releases/24.10.4/targets