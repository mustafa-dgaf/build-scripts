#!/bin/bash

echo "========== RisingOS Build Started =========="

# Cleanup old local manifests
rm -rf .repo/local_manifests

# Initialize RisingOS repo
repo init -u https://github.com/RisingOS-Revived/android -b qpr2 --git-lfs
echo "========== Repo Init Completed =========="

# Clone local manifests
git clone https://github.com/samsungexynos850/local_manifests -b slsi .repo/local_manifests

# Remove broken or stale clang versions before sync
rm -rf prebuilts/clang/host/linux-x86

# Start repo sync
/opt/crave/resync.sh
repo sync -c -j4 --force-sync --no-clone-bundle --no-tags
echo "========== Repo Sync Done =========="

#errors fixs
rm -rf vendor/rising
git clone https://github.com/mustafa-dgaf/android_vendor_rising vendor/rising

# Clone device/vendor/kernel trees
git clone https://github.com/TheMuppets/proprietary_vendor_samsung_a21s-common vendor/samsung/a21s-common -b lineage-22.2
git clone https://github.com/TheMuppets/proprietary_vendor_samsung_a21s vendor/samsung/a21s -b lineage-22.2
git clone https://github.com/mustafa-dgaf/android_device_samsung_a21s-common device/samsung/a21s-common -b lineage-23.0
git clone https://github.com/mustafa-dgaf/android_device_samsung_a21s device/samsung/a21s -b lineage-23.0
git clone https://github.com/mustafa-dgaf/upstream_exynos850 kernel/samsung/exynos850 -b lineage-23.0

#reset commits to just before 5.15 commit
cd kernel/samsung/exynos850 && \
git reset --hard 39b0138abf46e230ed9d0fd6b9d01c606aa0379a && \
cd ../../.. || {
    echo "Kernel reset failed!" >&2
    exit 1
}

echo "========== All Sources Cloned Successfully =========="

# Setup and build
source build/envsetup.sh
riseup a21s && rise sb

