#!/bin/bash

build=/home/piasek/android/Piasek-G2
kernel="Piasek-KK"
version="0.1"
rom="LG"
ramdisk=ramdisk
toolchain=/home/piasek/android/toolchain/bin
toolchain2="arm-eabi-"
kerneltype="zImage"
jobcount="-j4"
base=0x00000000
pagesize=2048
ramdisk_offset=0x05000000
tags_offset=0x04800000
variant="d802"
config="d802_defconfig"
ramdisk=ramdisk/d802.lz4
cmdline="console=ttyHSL0,115200,n8 androidboot.hardware=g2 user_debug=31 msm_rtb.filter=0x0 mdss_mdp.panel=1:dsi:0:qcom,mdss_dsi_g2_lgd_cmd"

if [ -f arch/arm/boot/"$kerneltype" ]; then
	mkdir -p out
	cp arch/arm/boot/"$kerneltype" out
	rm -rf ozip/system
	mkdir -p ozip/system/lib/modules
	find . -name "*.ko" -exec cp {} ozip/system/lib/modules \;
			rm -rf ozip/{system,boot.img}
			rm -rf arch/arm/boot/"$kerneltype"
			mkdir -p ozip/system/lib/modules
fi

if [ -f $ramdisk ]; then
	echo "Using prebuilt ramdisk..."
else
	echo "No ramdisk found..."
	exit 0;
fi

echo "Making DT.img..."
if [ -f arch/arm/boot/$kerneltype ]; then
	dtbTool -s 2048 -o out/dt.img arch/arm/boot/
else
	echo "No build found..."
	exit 0;
fi	

echo "Making boot.img..."
if [ -f arch/arm/boot/"$kerneltype" ]; then
	mkbootimg_dtb --kernel out/"$kerneltype" --ramdisk $ramdisk --cmdline "$cmdline" --base $base --pagesize $pagesize --ramdisk_offset $ramdisk_offset --tags_offset $tags_offset --dt out/dt.img -o ozip/boot.img
else
	echo "No build found..."
	exit 0;
fi

echo "Zipping..."
cd ozip
zip -r ../"$kernel"-$version-"$rom"_"$variant".zip .
mv ../"$kernel"-$version-"$rom"_"$variant".zip $build
cd ..
echo "Done..."

