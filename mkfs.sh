#!/bin/bash
export BUSYBOX_VERSION=1.32.0
if ! [ -f busybox-$BUSYBOX_VERSION.tar.bz2 ]; then
    echo "[+] Downloading busybox..."
    wget -q -c https://busybox.net/downloads/busybox-$BUSYBOX_VERSION.tar.bz2
    [ -e busybox-$BUSYBOX_VERSION ] || tar xjf busybox-$BUSYBOX_VERSION.tar.bz2
fi

echo "[+] Building busybox..."
make -C busybox-$BUSYBOX_VERSION defconfig
sed -i 's/# CONFIG_STATIC is not set/CONFIG_STATIC=y/g' busybox-$BUSYBOX_VERSION/.config
make -C busybox-$BUSYBOX_VERSION -j16
make -C busybox-$BUSYBOX_VERSION install

echo "[+] Building filesystem..."
mkdir fs
pushd fs
echo "#!/bin/sh" > init
echo "mount -t proc none /proc" >> init
echo "mount -t sysfs none /sys" >> init
echo "sysctl -w kernel.perf_event_paranoid=1" >> init
echo "echo \"7\" > /proc/sys/kernel/printk" >> init
echo "mknod /dev/null c 1 3" >> init
echo "chmod 666 /dev/null" >> init
echo "/bin/sh" >> init
chmod +x init
mkdir -p bin sbin etc proc sys usr/bin usr/sbin root
popd
cp -a busybox-$BUSYBOX_VERSION/_install/* fs
