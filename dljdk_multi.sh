#!/bin/sh

set -o errexit
set -o nounset

#set -o pipefail
set -x

REVISION_11=11.0.11_p9-r0
REVISION_17=17.0.1_p12-r0
REVISION_21=21.0.0_p1-r0
URL=http://dl-cdn.alpinelinux.org/alpine/v3.14/community
ARCH="aarch64 ppc64le s390x x86_64"
PACKAGES_11="openjdk11 openjdk11-jdk openjdk11-jre openjdk11-jre-headless"
PACKAGES_17="openjdk17 openjdk17-jdk openjdk17-jre openjdk17-jre-headless"
PACKAGES_21="openjdk21 openjdk21-jdk openjdk21-jre openjdk21-jre-headless"

old_pwd=$(pwd)
tmp_dir=$(mktemp -d -t openjdk-XXXXXXXXXX)
trap "rm -rf $tmp_dir" EXIT

cd "${tmp_dir}"

# Download OpenJDK 11 packages
for arch in $ARCH; do
    for package in $PACKAGES_11; do
        curl -o "${package}-${REVISION_11}_${arch}.apk" "${URL}/${arch}/${package}-${REVISION_11}.apk"
    done
done 

# Download OpenJDK 17 packages
for arch in $ARCH; do
    for package in $PACKAGES_17; do
        curl -o "${package}-${REVISION_17}_${arch}.apk" "${URL}/${arch}/${package}-${REVISION_17}.apk"
    done
done 

# Download OpenJDK 21 packages
for arch in $ARCH; do
    for package in $PACKAGES_21; do
        curl -o "${package}-${REVISION_21}_${arch}.apk" "${URL}/${arch}/${package}-${REVISION_21}.apk"
    done
done 

# Create directories for OpenJDK versions
for arch in $ARCH; do
    mkdir "openjdk11-${arch}"
    mkdir "openjdk17-${arch}"
    mkdir "openjdk21-${arch}"
done

# Extract APKs to corresponding arch dir
for arch in $ARCH; do
    for package in $PACKAGES_11; do
        tar xzf "${package}-${REVISION_11}_${arch}.apk" -C "openjdk11-${arch}"
    done
    for package in $PACKAGES_17; do
        tar xzf "${package}-${REVISION_17}_${arch}.apk" -C "openjdk17-${arch}"
    done
    for package in $PACKAGES_21; do
        tar xzf "${package}-${REVISION_21}_${arch}.apk" -C "openjdk21-${arch}"
    done
done

# Set executable permissions
for arch in $ARCH; do
    chmod +x "openjdk11-${arch}/usr/lib/jvm/java-11-openjdk/bin/"
    chmod +x "openjdk17-${arch}/usr/lib/jvm/java-17-openjdk/bin/"
    chmod +x "openjdk21-${arch}/usr/lib/jvm/java-21-openjdk/bin/"
done

# Tar them up again
for arch in $ARCH; do
    tar czf "openjdk-11_${arch}.tar.gz" -C "openjdk11-${arch}/usr/lib/jvm/java-11-openjdk/" .
    tar czf "openjdk-17_${arch}.tar.gz" -C "openjdk17-${arch}/usr/lib/jvm/java-17-openjdk/" .
    tar czf "openjdk-21_${arch}.tar.gz" -C "openjdk21-${arch}/usr/lib/jvm/java-21-openjdk/" .
done

cd "${old_pwd}"

# Copy the generated packages
for arch in $ARCH; do
    cp "$tmp_dir/openjdk-11_${arch}.tar.gz" "./"
    cp "$tmp_dir/openjdk-17_${arch}.tar.gz" "./"
    cp "$tmp_dir/openjdk-21_${arch}.tar.gz" "./"
done
