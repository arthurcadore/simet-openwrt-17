#!/bin/sh
set -e

ROOT_DIR=/host/staging_dir/target-aarch64-openwrt-linux-musl_musl/root-mediatek
FLOCK_DIR=$ROOT_DIR/usr/bin

echo "###############################################"
echo "## Configuring Git                           ##"
echo "###############################################"

git config --global --add safe.directory /host
git config --global credential.helper store
echo "https://${GIT_USER}:${GIT_PASSWORD}@git.intelbras.com.br" > ~/.git-credentials

echo "###############################################"
echo "## Adding Custom Files                      ##"
echo "###############################################"

cp -r /host/custom/* /host/

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

echo "###############################################"
echo "## Build finished                            ##"
echo "###############################################"

echo "###############################################"
echo "## Adding Include Files                      ##"
echo "###############################################"

cp -r /host/includes/* $ROOT_DIR/

if [ -f $FLOCK_DIR/util-linux-flock ]; then
    echo "###############################################"
    echo "## duplicating "util-linux-flock" file       ##"
    echo "###############################################"
    cp $FLOCK_DIR/util-linux-flock $FLOCK_DIR/flock
fi

if [ -f $FLOCK_DIR/flock ]; then
    echo "###############################################"
    echo "## duplicating "flock" file                  ##"
    echo "###############################################"
    cp $FLOCK_DIR/flock $FLOCK_DIR/util-linux-flock 
fi

echo "###############################################"
echo "## Compressing Output File...                ##"
echo "###############################################"

OUTPUT_DIR=/host/output

mkdir -p $OUTPUT_DIR
tar -czvf $OUTPUT_DIR/root-mediatek.tar.gz -C $ROOT_DIR .