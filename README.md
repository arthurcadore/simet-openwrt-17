# OpenWRT appliance for SIMET Application

This is a OpenWRT builder appliance for SIMET Application on embedded devices.


## Getting Started

### Prerequisites

- Docker version 27.5.1, build 9f9e405
- git version 2.43.0
- GNU Make 4.3

### Installing

Clone the repository:

```bash
git clone https://github.com/arthurcadore/simet-openwrt
```

Clone the OpenWRT toolchain inside the simet-openwrt folder:

```bash
cd ./simet-openwrt/
git clone <toolchain's URL>
```

## Building: 

### Environment Variables

In the `./env` directory, create the `.git_credentials` file, with the following content. This configuration need to be applied for feeds update and install: 

```yaml
FORCE_UNSAFE_CONFIGURE=1
GIT_USER=your_user
GIT_PASSWORD=your_pasword
```


### Updating openWRT feeds: 

If is the first time you are building the OpenWRT, you need to update the feeds. Do it by adding the following lines before `building the archives` section of entrypioint.sh file. 

```bash
./scripts/feeds update -a
./scripts/feeds install -a
```

Entrypoint file is located at `docker/entrypoint.sh`, and an example is below: 

```bash
[...]

# add it here
./scripts/feeds update -a
./scripts/feeds install -a

echo "###############################################"
echo "## Building the Archives                     ##"
echo "###############################################"
make tools/clean
make package/utils/jsonfilter/clean
make package/feeds/simetbox/simetbox-openwrt-simet-lmapd/clean
make package/feeds/simetbox/simetbox-openwrt-simet-ma/clean
make package/system/procd/clean
make package/system/rpcd/clean
make package/utils/util-linux clean
make package/feeds/packages/qrencode/clean 
make tools/compile V=s
make tools/install V=s
make package/utils/jsonfilter/compile V=s
make package/feeds/simetbox/simetbox-openwrt-simet-lmapd/compile V=s
make package/feeds/simetbox/simetbox-openwrt-simet-ma/compile V=s
make package/system/procd/compile V=s
make package/system/rpcd/compile V=s
make package/feeds/packages/qrencode/compile V=s
make package/utils/util-linux/compile V=s

[...]
```

### Starting the builder

To start the builder, run the following command:

```bash
docker compose up --build
```

### Custom configs: 

On the .config file, the following configuration was set, to build the SIMET Application, they are already set on the .config file, but are listed here for reference:
```
	CONFIG_USE_STRIP=y
	CONFIG_STRIP_ARGS="--strip-all"
	CONFIG_TOOLCHAIN_ROOT="/host/feed-toolchain-3006"
	CONFIG_LIBC_ROOT_DIR="/host/feed-toolchain-3006"
	CONFIG_LIBGCC_ROOT_DIR="/host/feed-toolchain-3006"
	CONFIG_LIBPTHREAD_ROOT_DIR="/host/feed-toolchain-3006"
	CONFIG_PACKAGE_librt=y
	CONFIG_LIBRT_ROOT_DIR="/host/feed-toolchain-3006"
	CONFIG_LIBRT_FILE_SPEC="./lib/librt{-*.so,.so.*}"
	CONFIG_PACKAGE_rpcd=y
	CONFIG_PACKAGE_rpcd-mod-rpcsys=y
	CONFIG_PACKAGE_libmbedtls=y
	CONFIG_PACKAGE_libcurl=y

	CONFIG_LIBCURL_MBEDTLS=y
	CONFIG_LIBCURL_FILE=y
	CONFIG_LIBCURL_FTP=y
	CONFIG_LIBCURL_HTTP=y
	CONFIG_LIBCURL_COOKIES=y
	CONFIG_LIBCURL_NO_SMB="!"
	CONFIG_LIBCURL_PROXY=y

	CONFIG_PACKAGE_libevent2=y
	CONFIG_PACKAGE_liblua=y
	CONFIG_PACKAGE_libqrencode=y
	CONFIG_PACKAGE_libuci-lua=y
	CONFIG_PACKAGE_luci-lib-json=y
	CONFIG_PACKAGE_luci-lib-jsonc=y
	CONFIG_PACKAGE_curl=y
	CONFIG_PACKAGE_simetbox-openwrt-base=y
	CONFIG_PACKAGE_simetbox-openwrt-simet-lmapd=y
	CONFIG_PACKAGE_simetbox-openwrt-simet-ma=y
	CONFIG_PACKAGE_flock=y
	CONFIG_PACKAGE_qrencode=y
```

## Output: 

The output files will be generated on the following directory:

```bash
./staging_dir/target-aarch64-openwrt-linux-musl_musl/root-mediatek/
```

Or you can get the compressed version of it at: 

```bash
./output/root-mediatek.tar.gz 
```

## Download: 

As convenience, the files can be download from the following link (by a second container hosted when `docker compose up` is executed):

```bash
http://localhost:8080/root-mediatek.tar.gz
```

The files are already structured to be flashed on the device. 