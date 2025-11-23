# Basic Docker builder for OpenWRT firmwares

> [!WARNING]
> This builder uses a docker volume to expose this repo's contents to the
> container. OpenWRT does not build as root, so make sure UID 1000 has write
> access to the repo directory (E.g. git clone with or chown to UID 1000 user;
> with WSL2 in Windows). In MacOS hosts this proves to be insufficient, but you
> can still build on a named volume instead, by replacing it in the
> [docker-compose.yml](docker-compose.yml) definition and adding
> `COPY --chmod=777 --chown=openwrt:openwrt . .`
> at the end of the [Dockerfile](openwrt-builder.Dockerfile)

This folder contains a Dockerfile, entrypoint.sh script, and docker-compose.yml
definition to run a docker container provisioned with a build environment and
the contents of this repository.

The entrypoint script will try to retrieve and set the specified build
configuration, download feeds and dependency packages, and build the project.

These actions are parameterised via environment variables passed to the
container, allowing partial builds, download skipping, and config-only runs.

## Usage examples

_Run in [this folder](../docker)_

Asus RT-AX52 default build config:

```bash
# BUILD_CONFIG_FILE_PATH, relative to docker/build-configs folder
# Use -e MENUCONFIG=true to tune the config before build
# (Do not pass -e BUILD_CONFIG_FILE_PATH to create one from scratch)
# Use -e BUILD_TARGETS="" if you just want to generate the config
docker compose run -e BUILD_CONFIG_FILE_PATH=mediatek/filogic/asus_rt-ax52/base.config openwrt-builder
```

Asus RT-AX52 custom config from the default 24.10.4 config for mediatek filogic chipset series:

```bash
# Make sure you are on the docker folder and the 24.10.4 branch/tag is checked out
docker compose run -e MENUCONFIG=true -e BUILD_CONFIG_FILE_URL=https://downloads.openwrt.org/releases/24.10.4/targets/mediatek/filogic/config.buildinfo openwrt-builder
# 1. Select RT-AX52 as build profile
# 2. Unselect dadhi telephony VoIP stuff (Or manually apply https://github.com/asterisk/dahdi-linux/commit/b821026c73588e927ae882f904642c2103781395
# to the sources downloaded to build_dir/target-aarch64_cortex-a53_musl/linux-mediatek_filogic/dahdi-linux-2024.04.12~83d89b64/drivers/dahdi during build)
# 3. Apply any other desired customisation, save, and exit
```

Go grab some popcorn you can probably make with the heat from the CPU running
the stuff, and watch it build for around 90 minutes, unless you have an absolute
beast of a machine. After that, check `bin/targets/<manufacturer>/<series>/` for
the build binaries, including `*-squashfs-sysupgrade.bin`, `*-initramfs.trx`,
`*-initramfs-kernel.bin`; and all the individual packages in
`bin/targets/<manufacturer>/<series>/packages/*.ipk`

## Build targets selection

For an incremental build you can skip `defconfig clean download` targets,
and/or [build a single package](https://openwrt.org/docs/guide-developer/toolchain/single.package)
by overriding the default `defconfig clean download world` make command build
targets. E.g.:

```bash
# builds only the ncurses package
docker compose run -e "BUILD_TARGETS=package/ncurses/compile" openwrt-builder
```

## Troubleshooting

`docker compose logs openwrt-builder 2>&1 > build.log` will dump the build logs
to the specified `build.log` file.

Pass `-e "VERBOSE=true"` to a build to figure out why the build is breaking.
This runs on a single process (i.e. single CPU core), so once the issue is
addressed it is a good idea to resume the rest of the build running without the
flag:

```bash
# Resumes a broken world building with the same config, feeds, and downloads
# to reproduce a previous error with more information
docker compose run -e VERBOSE=true -e BUILD_TARGETS=world openwrt-builder
```

## Cleanup & feeds refresh

To force feeds refresh you can pass `-e FORCE_FEEDS_REFRESH=true`, otherwise
they will only update & install if not present.

To force openwrt-builder container docker image regeneration, run:

```bash
docker compose down -v --rmi all
```

## References

### Setting up a build environment from scratch  _(Non docker specific)_

Follow https://openwrt.org/docs/guide-developer/toolchain/install-buildsystem

Debian doesn't work in ARM because it lacks the gcc/g++-multilib required
packages; Alpine does not work from some obscure cmake error; OpenSuse and
Fedora work fine for build hosts/containers in both arm64 and amd64 platforms, 
but you may have to add a few non-listed dependencies.

### Configuring and troubleshooting builds

- https://openwrt.org/docs/guide-developer/toolchain/use-buildsystem
- https://openwrt.org/docs/guide-developer/toolchain/single.package
- https://downloads.openwrt.org/releases/24.10.4/targets