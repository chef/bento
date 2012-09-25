# download and install guest additions
echo " "
echo " Installing VirtualBox Guest Additions "
cd /tmp
echo "mail=\ninstance=overwrite\npartial=quit\nrunlevel=nocheck\nidepend=quit" > /tmp/noask.admin
echo "rdepend=quit\nspace=quit\nsetuid=nocheck\nconflict=nocheck\naction=nocheck\nbasedir=default" >> /tmp/noask.admin
wget http://download.virtualbox.org/virtualbox/4.1.12/VBoxGuestAdditions_4.1.12.iso
mkdir /mnt/vbga
VBGADEV=`lofiadm -a VBoxGuestAdditions_4.1.12.iso`
mount -o ro -F hsfs $VBGADEV /mnt/vbga
echo "all" | pkgadd -a /tmp/noask.admin -G -d /mnt/vbga/VBoxSolarisAdditions.pkg
umount /mnt/vbga
lofiadm -d $VBGADEV
rm -f VBoxGuestAdditions_4.1.12.iso
