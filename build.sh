set -x
read -p "make mrproper?(y/n)" -n 1 -r mrproper
if [[ $mrproper =~ ^[Yy]$ ]]
then
    make mrproper
fi

cp .config /home/lucas/defconfig
kernelappend="-linux48"
name="$(make kernelversion)"
localversion="-STALINIUM"
cp /home/lucas/defconfig .config
sed -i "s|CONFIG_LOCALVERSION_AUTO=.*|# CONFIG_LOCALVERSION_AUTO is not set|" .config
make -j$(nproc) LOCALVERSION=$localversion
f="arch/x86_64/boot/bzImage"
if [ -e $f ]
then
 kernelname="$name$localversion"
 echo "Compile Success!"
 sudo make modules_install
 sudo cp -v arch/x86_64/boot/bzImage /boot/vmlinuz$kernelappend
 sudo dracut -H --force --lz4 /boot/initramfs$kernelappend.img --kver $kernelname
 sudo cp System.map /boot/System.map$kernelappend
 sudo ln -sf /boot/System.map$kernelappend /boot/System.map
 #update systemd-boot
 sudo bootctl update
else
 echo "Compile Failed, fix your shit"
fi


