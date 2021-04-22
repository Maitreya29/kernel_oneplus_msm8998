#!/usr/bin/env bash

echo "Cloning dependencies"

git clone --depth=1 https://github.com/Maitreya29/TanjiroKernelOP5-T.git -b custom2 kernel
cd kernel
git clone --depth=1 https://github.com/kdrag0n/proton-clang clang

echo "Done"

IMAGE=$(pwd)/out/arch/arm64/boot/Image.gz-dtb
TANGGAL=$(date +"%F_%H-%M")
START=$(date +"%s")
CLANG_VERSION=$(clang/bin/clang --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//')
BRANCH=$(git rev-parse --abbrev-ref HEAD)
export PATH=$PWD/clang/bin:$PATH

export ARCH=arm64
export KBUILD_BUILD_HOST="Tanjiro"
export KBUILD_BUILD_USER="Maitreya29"

# Header
function header() {
    curl -s -X POST "https://api.telegram.org/bot$token/sendPhoto" \
        -d photo=$url \
        -d chat_id=$chat_id \
        -d "parse_mode=html" \
	-d caption="<b>• Tanjiro Kernel •</b>%0ABuild started on <code>CI</code>%0A <b>For device</b> <i>OnePlus 5/5T</i>%0A<b>branch:-</b> <code>$BRANCH</code>(master)%0A<b>Under commit</b> <code>$(git log --pretty=format:'"%h : %s"' -1)</code>%0A<b>Using compiler:- </b> <code>$CLANG_VERSION</code>%0A<b>Started on:- </b> <code>$(date)</code>"
}

# Push kernel to channel
function push() {
    cd AnyKernel
    ZIP=$(echo *.zip)
    curl -F document=@$ZIP "https://api.telegram.org/bot$token/sendDocument" \
        -F chat_id="$chat_id" \
        -F "disable_web_page_preview=true" \
        -F "parse_mode=html" \
        -F caption="Build took $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) second(s). | For <b>OnePlus 5/5T</b> | <b>$CLANG_VERSION</b>"
}

# Fin Error
function finerr() {
    LOG=$(echo *.log)
    curl -F document=@$LOG "https://api.telegram.org/bot$token/sendDocument" \
        -F chat_id="$chat_id" \
        -F "disable_web_page_preview=true" \
        -F "parse_mode=html" \
        -F caption="Build threw an error(s)"
    exit 1
}

# Compiling build
function compile() {
   make O=out ARCH=arm64 tanjiro_defconfig
       make -j$(nproc --all) O=out \
                      CC=clang \
                      CROSS_COMPILE=aarch64-linux-gnu- \
                      CROSS_COMPILE_ARM32=arm-linux-gnueabi- \
                      NM=llvm-nm \
                      OBJCOPY=llvm-objcopy \
                      OBJDUMP=llvm-objdump \
                      STRIP=llvm-strip 2>&1 | tee build.log

if [ `ls "$IMAGE" 2>/dev/null | wc -l` != "0" ]
then
   cp out/arch/arm64/boot/Image.gz-dtb AnyKernel
else
   finerr
fi
}

# Zipping
function zipping() {
    cd AnyKernel || exit 1
    zip -r9 Tanjiro-OnePlus5-T-${BRANCH}-${TANGGAL}.zip *
    cd ..
}
header
compile
zipping
END=$(date +"%s")
DIFF=$(($END - $START))
push