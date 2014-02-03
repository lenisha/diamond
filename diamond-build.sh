#!/bin/sh

# First remove the old build form current directory, 
# then clone buildroot from the source conde 
# change dir and re-compile 
#
/bin/rm -rf ./buildroot
/usr/bin/git clone http://git.buildroot.net/git/buildroot.git && cd buildroot
/usr/bin/make menuconfig
/usr/bin/make

# output/images/rootfs.tar is containing the image to be imported in Docker
# but we need to fix something before ...
#
cd output/images
/bin/mkdir -p extra/etc extra/sbin 

# Docker sets the DNS configuration by bind-mounting over /etc/resolv.conf 
# which means that /etc/resolv.conf has to be a standard file. 
# By default, buildroot makes it a symlink.  
# We have to replace that symlink with a file. 
#
/usr/bin/touch extra/etc/resolv.conf

# Likewise, Docker “injects” itself within containers by bind-mounting over /sbin/init. 
# This means that /sbin/init should be a regular mount point file as well. 
# By default, buildroot makes it a symlink, change that too.
#
/usr/bin/touch extra/sbin/init

# Then update the tar file with "extra" fixing on the fly
/bin/tar rvf rootfs.tar -C extra .

# Now move it to the project root directory
cp ./rootfs.tar ../../ 

echo "Docker import command will bring this image into Docker. We will name it “diamond”"
echo "/usr/bin/docker import - diamond < rootfs.tar"
