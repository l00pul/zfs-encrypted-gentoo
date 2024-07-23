#!/usr/bin/env bash

die() {
    echo $*
    exit 1
}
#
#
#
echo " ---------- snippet 1 choose the  default system wide variables ------------------"
echo
#
#
#
#
echo -n "Target install drive setup:"
echo -n ""
TARGETINSTALLHARDDRIVE=sda
read -p "your answer [TARGETINSTALLHARDDRIVE=$TARGETINSTALLHARDDRIVE] " answer
: ${answer:=$TARGETINSTALLHARDDRIVE}
echo
echo "you answered: "$answer
TARGETINSTALLHARDDRIVE=${answer}
echo -n ""
echo -n "The target install drive is now set to :"$TARGETINSTALLHARDDRIVE
#
#
#
#
echo -n "Normal gentoo new user name:"
echo -n ""
gent00USERNAME=l00p
read -p "your answer [gent00USERNAME=$gent00USERNAME] " answer
: ${answer:=$gent00USERNAME}
echo
echo "you answered: "$answer
gent00USERNAME=${answer}
echo -n ""
echo -n "Gentoo username is now set to"$gent00USERNAME
#
#
echo -n "zfs encrypted POOL name:"
echo -n ""
POOL=z00data
read -p "your answer [POOL=$POOL] " answer
: ${answer:=$POOL}
echo
echo "you answered: "$answer
POOL=${answer}
echo -n ""
echo -n "The new zfs encrypted destination POOL name is now set to"$POOL
#
#
echo -n "New host name post installation:"
echo -n ""
HOST=g00
read -p "your answer [HOST=$HOST] " answer
: ${answer:=$HOST}
echo
echo "you answered: "$answer
HOST=${answer}
echo -n ""
echo -n "The new host name post installation is now set to"$HOST
#
#
#
#
echo -n "Chroot mount location:"
echo -n ""
MOUNT=/mnt/gentoo
read -p "your answer [MOUNT=$MOUNT] " answer
: ${answer:=$MOUNT}
echo
echo "you answered: "$answer
MOUNT=${answer}
echo -n ""
echo -n "The new chroot mount location is now set to"$MOUNT
#
#
#
#
echo "erasing now the previous install failed attempts and creating the chosen gentoo chroot  directory:"
echo "checking existing chroot chosen  directory :"
echo "purging any previous bogus installation attempts!"
echo "double check if you need to save any files like /etc config ones exit script and DO IT NOW !!!!!"
echo `ls -alhtu --group-directories-first --dereference-command-line-symlink-to-dir  \
--dereference-command-line --inode  --kibibytes --dereference -q --hide-control-chars\
 --hyperlink=always -Q --quote-name --quoting-style=literal  --recursive --size -S \
 --sort=time --time=atime --width=2 --context -1 ${MOUNT}`
echo "sanitazing for a brand new installation by wiping all existing files and settings"
echo "everything will be erased from the installation hard drive, including partition"
echo "table and existing zfs zpools !!!!!!!"
echo
echo "listing all zfs mounted directories:" zfs mount
echo
echo "unmounting existing zfs directories if any:"
echo `zfs unmount -f -a`
echo
echo "now checking the target zpool:"
echo  `zpool list ${POOL}`
echo
echo "erasing the previous target installation zpool:"
echo `zpool destroy -f ${POOL}`
echo
echo "deleting old target install chroot directory and  creating a new empty one:"
echo echo "deleting old target install chroot directory and  creating a new empty one:"
echo `rmdir ${MOUNT}`
echo
echo
echo "existing chroot directory removed. Creating the new empty one:"${MOUNT}
echo `mkdir ${MOUNT}`
echo
echo "verify it:"
echo `ls -alth ${MOUNT}`
echo ok
echo -n "wipe any existing partitions on sda"
wipefs -a /dev/$TARGETINSTALLHARDDRIVE}
#

#
#
#
echo -n "Setting up a very simple temporary install zfs passphrase: change it when  going live in production environments !!!!"
echo -n ""
POOL_PW=ba3FkuVcK8%4gpgutvV*vwvn]D%fq@^g1X+vDzfAUYUhAg8m^R*.uCHnYpv=e.VRF.z00
read -p "your answer [POOL_PW=$POOL_PW] " answer
: ${answer:=$POOL_PW}
echo
echo "you answered: "$answer
POOL_PW=${answer}
echo -n ""
echo -n "The new zpool encryption passphrase is now set to"$POOL_PW
#
#
#
#
echo -n "REPEAT IT !! Confirm your install zfs passphrase:"
echo
POOL_PW2=ba3FkuVcK8%4gpgutvV*vwvn]D%fq@^g1X+vDzfAUYUhAg8m^R*.uCHnYpv=e.VRF.z00
read -p "your answer [POOL_PW2=$POOL_PW2] " answer
: ${answer:=$POOL_PW2}
echo
echo "you answered: "$answer
POOL_PW2=${answer}
echo -n ""
echo -n "The new zpool encryption passphrase is now set to"$POOL_PW2
#
#
#
#
echo -n "simple temporary install root password: change it after install!!!!"
echo
ROOT_PW=R00t.Cutu09876543211234567890*^@?333*
read -p "your answer [ROOT_PW=$ROOT_PW] " answer
: ${answer:=$ROOT_PW}
echo
echo "you answered: "$answer
ROOT_PW=${answer}
echo -n ""
echo -n "The new root password is now set to"$ROOT_PW
#
#
#
#
echo -n "REPEAT IT !!  Confirm your root password:"
echo
ROOT_PW2=R00t.Cutu09876543211234567890*^@?333*
read -p "your answer [ROOT_PW2=$ROOT_PW2] " answer
: ${answer:=$ROOT_PW2}
echo
echo "you answered: "$answer
ROOT_PW2=${answer}
echo -n ""
echo -n "The new root password is now set to"$ROOT_PW2
#
#
if [ $POOL_PW != $POOL_PW2 ]; then
    die "zfs password missmatch!!! redo this procedure"
fi
#
if [ $ROOT_PW != $ROOT_PW2 ]; then
    die "root password missmatch!!! redo this procedure"
fi
## ----------          snippet 1 end                      ------------------
#
#
#
#
# :---------- snippet 2 create vfat boot and zfs root partitions on the target hard drive  ------------------
echo "wipe previous partitions from target hard drive:"
echo
wipefs -a /dev/${TARGETINSTALLHARDDRIVE}
echo
echo "creating  partition table with two distinct partitions:"
echo "first one a natively zfs encrypted root one and second"
echo "a vfat boot  partitions on the target hard drive chosen by the user:" ${TARGETINSTALLHARDDRIVE}
echo
#
sed -e 's/\s*\([-+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk /dev/${TARGETINSTALLHARDDRIVE}
  g       # create gpt table
  n       # new partition
  1       # partition nr 1
          # start at first sector
  -1024M  # leave 1G space for /boot/efi
  n       # new partition
  2       # partition nr 2
          # start at first free sector
          # take all empty space (1024MiB)
  t       # set partition type
  2       # parition nr 2
  1       # set to EFI type
  p       # print partition table
  w       # write partition table to disk
  q       # quit
EOF
#
echo
echo "partition boot partition with vfat file system on target hard drive:"
echo
mkfs.vfat -v -F32  /dev/${TARGETINSTALLHARDDRIVE}2
echo
echo
echo "create root zfs unencrypted pool on target hard drive:"
echo
echo "very important to add -o cachefile=/etc/zfs/${POOL}.cache"
echo "without the "${POOL}".cache it will be almost impossible"
echo "to properly boot into the new zfs POOL"${POOL}
echo
#
# --------- test the plain unecrypted zfs pool  installation first -----------
#
echo
#echo "creating the POOL"${POOL}"  on the target drive "${TARGETINSTALLHARDDRIVE}
#echo
#zpool    create -f -o ashift=12 -o autotrim=on -o cachefile=/etc/zfs/${POOL}.cache \
#-o cachefile=/etc/zfs/${POOL}.cache -O acltype=posixacl -O canmount=off  \
#-O compression=lz4  -O dnodesize=auto  -O normalization=formD -O relatime=on \
#-O xattr=sa  -O mountpoint=/ -R /mnt/gentoo ${POOL} /dev/${TARGETINSTALLHARDDRIVE}1
#echo
#
#
gent00USERNAME=l00p
POOL=z00data
POOL_PW=ba3FkuVcK8%4gpgutvV*vwvn]D%fq@^g1X+vDzfAUYUhAg8m^R*.uCHnYpv=e.VRF.z00
POOL_PW2=ba3FkuVcK8%4gpgutvV*vwvn]D%fq@^g1X+vDzfAUYUhAg8m^R*.uCHnYpv=e.VRF.z00
ROOT_PW=R00t.Cutu09876543211234567890*^@?333*
ROOT_PW2=R00t.Cutu09876543211234567890*^@?333*
USER_PW=L00pul.Cutu09876543211234567890^^@?KDEz
USER_PW2=L00pul.Cutu09876543211234567890^^@?KDEz
#
POOL=z00data
# --------------- the encrypted pool version sill be tested at a later stage ----------
zpool create -f -o ashift=12 -o autotrim=on -o cachefile=/etc/zfs/${POOL}.cache \
-O acltype=posixacl -O canmount=off  -O compression=lz4 -O dnodesize=auto \
-O normalization=formD  -O relatime=on  -O xattr=sa  -O mountpoint=/  \
-R /mnt/gentoo  -O encryption=aes-256-gcm -O keylocation=prompt  \
-O keyformat=passphrase  ${POOL} /dev/${TARGETINSTALLHARDDRIVE}1 << EOF
${POOL_PW}
${POOL_PW}
EOF
echo
echo "encrypted pool "${POOL} "created succesfully!!!"
echo "Now we export and immediatly reimport" ${POOL}
echo "to test the encryption and passphrase:"
#
zpool export  ${POOL}
#
echo " import the new encrypted pool:" ${POOL}
zpool import -l -d /dev/${TARGETINSTALLHARDDRIVE}1  -o altroot=/mnt/gentoo $POOL
echo "encrypted pool imported succesfully !"

echo "listing the newly created zfs encrypted pool on target hard drive:"
zpool list
echo
## ----------          snippet 2 end                      ------------------
#
#
# ---------- snippet 3 create all the zfs partitions as subsets of the main one   ------------------
# this setup i use  is useful in production  to keep things ordonated : separate zfs for var , packages, cache , etc
echo "creating new zfs directories:"
echo
# echo "set zpool encryption key location:"
# echo
# zfs set keylocation=file:///etc/zfs/${POOL}.key ${POOL}
echo
echo "create ${POOL}/ROOT:"
echo
zfs create -v -o canmount=off -o mountpoint=none   ${POOL}/ROOT
echo
echo "create ${POOL}/ROOT/r00t"${POOL}/ROOT/r00t
echo
zfs create -v -o canmount=noauto -o mountpoint=/   ${POOL}/ROOT/r00t
echo
echo "mount ${POOL}/ROOT/r00t"${POOL}/ROOT/r00t
zfs mount -v                                       ${POOL}/ROOT/r00t
echo
echo "create ${POOL}/home:"${POOL}/home
echo
zfs create -v                                     ${POOL}/home
echo
echo "create ${POOL}/home/root:"${POOL}/home/root
echo
zfs create -v -o mountpoint=/root                  ${POOL}/home/root
echo
echo "create ${POOL}/var:"${POOL}/var
echo
zfs create -v -o canmount=off                      ${POOL}/var
echo
echo "create ${POOL}/var/lib:"${POOL}/var/lib
echo
zfs create -v -o canmount=off                      ${POOL}/var/lib
echo
echo "create ${POOL}/var/cache:"${POOL}/var/cache
echo
zfs create -v -o com.sun:auto-snapshot=false       ${POOL}/var/cache
echo
echo "create ${POOL}/var/cache/ccache:"${POOL}/var/cache/ccache
echo
zfs create -v -o com.sun:auto-snapshot=false       ${POOL}/var/cache/ccache
echo
echo "create ${POOL}/var/cache/binpkgs:"${POOL}/var/cache/binpkgs
echo
zfs create -v -o com.sun:auto-snapshot=false       ${POOL}/var/cache/binpkgs
echo
echo
echo "create ${POOL}/var/log:"${POOL}/var/log
echo
zfs create    -v                               ${POOL}/var/log
echo
echo "create ${POOL}/var/db:"${POOL}/var/db
echo
zfs create   -v                                   ${POOL}/var/db
echo
echo "create ${POOL}/var/spool:"${POOL}/var/spool
echo
zfs create    -v                                  ${POOL}/var/spool
echo
echo "create ${POOL}/var/tmp:"${POOL}/var/tmp
echo
zfs create -v -o com.sun:auto-snapshot=false       ${POOL}/var/tmp
echo
echo "create ${POOL}/usr:"${POOL}/usr
echo
zfs create -v -o canmount=off                      ${POOL}/usr
echo
echo "create ${POOL}/usr/local:"${POOL}/usr/local
echo
zfs create    -v                                  ${POOL}/usr/local
#
#
echo "create ${POOL}/opt:"${POOL}/opt
echo
zfs create    -v                                  ${POOL}/opt
#
#
echo -n "creating a dedicated zfs user  and  adding a new regular user of the target gentoo distribution for the user"${gent00USERNAME}":"
echo -n 
zfs create ${POOL}/home/${gent00USERNAME}
useradd -G wheel,users,portage  -s /bin/bash ${gent00USERNAME}
cp -a /etc/skel/. /home/${gent00USERNAME}
echo -n 
echo -n
echo -n  "setting up the user password :"
echo -n 
passwd ${gent00USERNAME} << EOF
${USER_PW}
${USER_PW2}
EOF
echo -n 
echo -n
#
#
echo -n
echo "setting up secure system permissions for the home folder"
echo "of the new happy gentoo user"${gent00USERNAME}"and its HOME location"$MOUNT/home/${gent00USERNAME}":"
echo
chown -v -R ${gent00USERNAME}:${gent00USERNAME} $MOUNT/home/${gent00USERNAME}
echo
echo
#
#
echo -n "setting up the root password :"
echo -n 
passwd << EOF
${ROOT_PW}
${ROOT_PW}
EOF
echo -n 
echo -n
#
#

#
#
## ----------          snippet 4 end                      ------------------
#
#
#
#
# ---------- snippet 5 peparing the chroot cage : downloading and expanding the stage3 arm64 distribution    ------------------
#
MOUNT=/mnt/gentoo
echo "entering /mnt/gentoo chroot location on /dev/sda1 formatted partition :"
cd ${MOUNT}
echo
zDATE=`date --iso-8601=date  --date='TZ="Europe/Bucharest"now'`
echo "the present date is :"${zDATE}
echo
echo "downloading gentoo distribution stage3 tarball for silicon mac arm64 CPU"
echo
curl -vv -o ${MOUNT}/gentoo.arm64.stage3.${zDATE}.tar.xz \
http://ftp.romnet.org/gentoo/releases/arm64/autobuilds/\
20240714T234904Z/stage3-arm64-openrc-20240714T234904Z.tar.xz
echo
echo "Download finished succesfully!"
echo
echo "we will work from NOW on in the new working directory"`pwd`" :"
cd ${MOUNT}
echo
echo
echo
echo "Extracting NOW the Gentoo stage3 arm64 openrc snapshot on the target ROOT pool:"
echo
time tar -xv --xattrs-include='*.*' --numeric-owner --file=${MOUNT}/gentoo.arm64.stage3.${zDATE}.tar.xz
echo
echo "list the MOUNT snapshot directories structure:"
echo `ls -alh ${MOUNT}`
echo
echo "gentoo snapshot tarball gentoo.arm64.stage3."${zDATE}".tar.xz succesfully decompressed!"
echo
echo "removing stage3 snapshot gentoo.arm64.stage3."${zDATE}" as is no longer needed"
echo
rm --force  -v gentoo.arm64.stage3."${zDATE}".tar.xz
echo "snapshot tarball removed"
#
#
## ----------          snippet 5 end                      ------------------
#
#
#
#   ---------This is the end of the all purpose generic install script ---------------
#
#
#
#
#
echo "This is the end of the first part of my  all purpose generic install script"
echo "allowing the fully automatized and blazing fast installation"
echo "of a running new system using Gentoo with a nativelly encrypted ROOT on zfs configuration "
echo
echo
echo "The  following script sequences are my own personal customizations"
echo "i use a full KDE plasma OpenRC desktop"
echo
echo
echo "As is a very personal choice , you are free to modify the following script snippets"
echo "and install your own world. There are no limits. All is opensourced !!!"
echo
echo
echo "you prefer SystemD instead of the original yet tested Gentoo OpenRC ?? "
echo "no problem! just change the system  profile. Eselect  with do this fo you"
echo "just list then choose another profile   "
echo
echo
echo "Here is the Gentoo's various profile list for ARM64 :"
echo
echo
echo "current-install-arm64-minimal/  current-stage3-aarch64_be-openrc/ "
echo " current-stage3-aarch64_be-systemd/ current-stage3-arm64-desktop-openrc/  "
echo "current-stage3-arm64-desktop-systemd/  current-stage3-arm64-llvm-openrc/  "
echo "current-stage3-arm64-llvm-openrc/  current-stage3-arm64-llvm-systemd/  "
echo "current-stage3-arm64-musl/  current-stage3-arm64-musl-hardened/   "
echo " current-stage3-arm64-musl-llvm/  current-stage3-arm64-openrc/      "
echo "current-stage3-arm64-openrc-splitusr/ current-stage3-arm64-systemd/  "
echo
echo
echo "Enjoy the fantastic techical and human Linux journey using Gentoo!"
echo "Our responsive and technically sound community is here to help you."
echo
echo
echo "You should always take care to read the excellent Gentoo documentations"
echo "before asking for techical advice. Use the wiki and the Gentoo technical forums"
echo
echo
echo -n "Luxembourg, June 2-nd 2024" 
echo -n "Eduard L00pul alfa cel mai rău TRIC"
echo -n "l00p@axetel.net https://axetel.net"
#
#
#
#
------end of generic part-------------
#
#
#

#
#
#
#
# ----- Finalizing the new Gentoo installation script  to  to reboot natively without chroot into the new system ----------
#
#
#
#
#
echo "now  we can finally enter  into the brand new fully functional chrooted environment !!!! "
echo "but we still have many things to isntall and configure within the cage before booting"
echo "so even if it's  very very tempting, time has not come yet to reboot"
echo "before booting the new Gentoo, we still need to install  and configure the encrypted zfs boot manager and other crucial  software "
echo "most of the people will just  use the dominant 2 tons godzilla grub"
echo "however ,as we are on Gentoo here,by far the most carefully engineered Linux distribution "
echo "we will pick and put to use zfsbootmenu, a far lighTer and simple to use  bootmanager for ROOT on zfs systems "
echo "we will pass over all our preciouss  custom system wide variables"
echo "from the livecd system  to the v0id chroot cage: "
echo "for testing purposes, i duplicated them just to test"
echo "this small  chrooting sequencefrom the whole script"
echo  "one can safly delete the following 8 hardcoded systemwide variables in production! :"
echo  "those variable are already defined by the user in the very beginning of the script!!!!"
#
POOL=z00data
MOUNT=/mnt/gentoo
echo "import encrypted pool  #"
zpool import -f -l  \
      -d /dev/disk/by-label/  \
      -o altroot=$MOUNT ${POOL}
echo
echo
TARGETINSTALLHARDDRIVE=sda
gent00USERNAME=l00p
POOL=z00data
TERM=xterm
HOST=g00
MOUNT=/mnt/gentoo
POOL_PW=ba3FkuVcK8%4gpgutvV*vwvn]D%fq@^g1X+vDzfAUYUhAg8m^R*.uCHnYpv=e.VRF.z00
POOL_PW2=ba3FkuVcK8%4gpgutvV*vwvn]D%fq@^g1X+vDzfAUYUhAg8m^R*.uCHnYpv=e.VRF.z00
ROOT_PW=R00t.Cutu09876543211234567890*^@?333*
ROOT_PW2=R00t.Cutu09876543211234567890*^@?333*
USER_PW=L00pul.Cutu09876543211234567890^^@?KDEz
USER_PW2=L00pul.Cutu09876543211234567890^^@?KDEz
#
#
echo -n "mounting correctly all zfs partitions from the encrypted pool"
zfs umount -a
zfs mount $POOL/ROOT/r00t
zfs mount -a
#
echo "the TARGETINSTALLHARDDRIVE variable ="${TARGETINSTALLHARDDRIVE}
echo  "the gent00USERNAME variable ="${gent00USERNAME}
echo  "the HOST variable ="${HOST}
echo "the POOL variable ="${POOL}
echo  "the POOL_PW variable ="${POOL_PW}
echo  "the POOL_PW2 variable ="${POOL_PW2}
echo  "the ROOT_PW variable ="${ROOT_PW}
echo  "the TERM variable ="${TERM}
echo "the ROOT_PW2 variable ="${ROOT_PW2}" ok"
echo 
#
#
#
MOUNT=/ub00ntu
echo "last settings to have a fully working system within the chroot cage"
echo
echo "mounting the small vfat boot partition on "/dev/${TARGETINSTALLHARDDRIVE}2
echo
mkdir -p ${MOUNT}/boot
echo
mount -v /dev/${TARGETINSTALLHARDDRIVE}2 ${MOUNT}/boot
echo
echo
MOUNT=/ub00ntu
echo "clone proc sys dev run shm to function also within the cqge "
mount --types proc /proc ${MOUNT}/proc
mount --rbind /sys ${MOUNT}/sys
mount --rbind /dev ${MOUNT}/dev
mount --bind /run ${MOUNT}/run
test -L /dev/shm
rm /dev/shm
mkdir /dev/shm
mkdir -p /run/shm
mount --types tmpfs --options nosuid,nodev,noexec shm /dev/shm
chmod 1777 /dev/shm /run/shm
echo
echo "changing various permissions chmod 700  ${MOUNT}/root and"
echo "chmod 1777 ${MOUNT}/var/tmp:"${MOUNT}/root"and"${MOUNT}/var/tmp
echo
chmod -v 700  ${MOUNT}/root
chmod -v 1777 ${MOUNT}/var/tmp
#
echo
echo "copying the resolv.conf file to chroot "
echo "finally we will just create resolv.conf from scratch using 8.8.8.8"
cp --force -v  --dereference /etc/resolv.conf ${MOUNT}/etc/
echo -n
echo -n "creating gentoo repository directory"
mkdir -p /var/db/repos/gentoo
echo -n "we are now ready to entrer the chroot cage"
echo -n
#
chroot ${MOUNT} /usr/bin/env -i           \
       HOST=${HOST}                       \
       POOL=${POOL}                       \
       POOL_PW=${POOL_PW}                 \
       ROOT_PW=${ROOT_PW}                 \
       POOL_PW2=${POOL_PW2}               \
       ROOT_PW2=${ROOT_PW2}               \
       gent00USERNAME=${gent00USERNAME}   \
       TERM=${TERM}                       \
       PS1='*v0id* \u:\w\$' \
       /bin/bash --login
echo
echo
#
#
env-update
source /etc/profile
export HOME=root
export TERM=xterm
export PS1='*chr00t!* @\w/ |'
echo "rsync portage db using emerge-webrsync :"
echo
time emerge-webrsync
echo
#
#
echo "populating  portage database with latest  packages versions using 'emerge sync':"
echo
time emerge --sync
echo
echo
#PS1='*v0id Gentoo chroot* \u:\w\$'
#
#
echo
echo -n "populating the DNS resolver with google 8.8.8.8  and cloudfare 1.1.1.1 free servers:"
echo -n
echo `cat << EOF >> /etc/resolv.conf
nameserver 1.1.1.1
nameserver 8.8.8.8
nameserver 4.4.4.4
nameserver 8.8.4.4
EOF`
echo -n
#
----------   End of resetting up the system variables for v0id zfs chroot ----------
#
#
echo
echo "End of resetting up the system variables for v0id zfs chroot"
echo
echo
echo "Now finally entering into the v0id chroot"
echo "Everything should work like in a real non chrooted system:"
echo "the beloved emerge, llvm, clang and a few other necessary packages"
echo "already are preinstalled in our  stage 3  snapshot !!!"
echo "my plasma setup has around 1000 packages! "
echo "I managed to save all of them in standardized binary gpkg format"
echo "from an existing running system using ARM64 CPU !!!!"
echo " I also saved ALL the very precious configs from /etc "
echo "including  make.conf and all the builds and run USE flags of all the  packages!!!! "
echo "This is all that we need to (re) build fast and easy"
echo "a brand new shiny and fully optimized and customized"
echo "custom ARM64 plasma-desktop running  system in minutes !!!!"
echo "Otherwise such a customization level would have required"
echo "days and days of hard-working to engineer and customize from scratch a new system"
echo "You might most probably gain more than a whole week of hard work using my script!!!!"
echo "Moreover, now Gentoo has available on public servers around 75 % of the packages"
echo "already precompiled and ready to run and have fun  using them  for ARM64 and AMD64"
echo "architectures in binary formats"
echo "Just add and select some binhostpkg servers located near you and you're done!"
echo "no more long compiling hours and otherwise precious time is now needed "
echo "to run your favorite Gentoo distribution  at full potential !!!"
echo "Enjoy and have a lot of fun with Gentoo. I am more than happy with my setup"
echo "showing the current directory, it must be "${MOUNT}
echo `pwd`
echo
#
#
yourcompanyname=axetel
gent00USERNAME=l00p
POOL=z00data
POOL_PW=ba3FkuVcK8%4gpgutvV*vwvn]D%fq@^g1X+vDzfAUYUhAg8m^R*.uCHnYpv=e.VRF.z00
POOL_PW2=ba3FkuVcK8%4gpgutvV*vwvn]D%fq@^g1X+vDzfAUYUhAg8m^R*.uCHnYpv=e.VRF.z00
ROOT_PW=R00t.Cutu09876543211234567890*^@?333*
ROOT_PW2=R00t.Cutu09876543211234567890*^@?333*
USER_PW=L00pul.Cutu09876543211234567890^^@?KDEz
USER_PW2=L00pul.Cutu09876543211234567890^^@?KDEz
POOL1=preci0uss
POOL1_PW=M00ned36-Create72-Landmine81-Provoke17-Agility95-Speed44-Okay59-Pacifier68-Groggily02-Rockstar99*
POOL1_PW2=M00ned36-Create72-Landmine81-Provoke17-Agility95-Speed44-Okay59-Pacifier68-Groggily02-Rockstar99*
#
#
#

#
#
POOL=${POOL}
echo
echo
echo "create ${POOL}/SWAP:"${POOL}/SWAP
echo
zfs  create  -v  -V  8G  -o  logbias=throughput \
-o sync=always  -o primarycache=metadata  ${POOL}/SWAP
echo
echo "setting up and activating a 8 G dedicated SWAP partition  ON our encryppted zfs pool"${POOL}
echo
mkswap /dev/zvol/${POOL}/SWAP
swapon /dev/zvol/${POOL}/SWAP
echo
echo
echo "copy zpool.cache to new system"
echo
### 1.9 zpool.cache
mkdir -p ${POOL}/etc/zfs
cp /etc/zfs/${POOL}.cache ${POOL}/etc/zfs/${POOL}.cache
cp /etc/zfs/${POOL1}.cache ${POOL}/etc/zfs/${POOL1}.cache
echo
## ----------          snippet 3 end                      ------------------
#
#
# ---------- snippet 4 peparing the chroot cage   ------------------
#
echo "setting up the bootfs on the new system:"
### 1.7 zpool bootfs
echo
zpool set bootfs=${POOL}/ROOT/r00t ${POOL}
echo
echo
echo
echo "listing the newly created zfs subsets on target hard drive:"
zfs list
echo
echo "listing the newly created zfs mounts on target pool:"
zfs mount
echo
echo
echo "setting the new host name:"${HOST}
echo ${HOST}  > /etc/hostname
echo
echo
#
#
echo "populating rc.conf with local TIMEZONE and keymap :"
echo
echo `cat << EOF >> /etc/rc.conf
KEYMAP="ro"
TIMEZONE="Europe/Bucharest"
HARDWARECLOCK="UTC"
EOF`
echo
#
#
echo "populating system locale config file /etc/locale.gen:"
echo
echo
echo `cat << EOF >> /etc/locale.gen
en_US.UTF-8 UTF-8
ro_RO.UTF-8 UTF-8
EOF`
echo
#
#
echo "installing the new locales. it will take a while depending on how many are they:"
echo
locale-gen
echo
#
#
echo "creating dracut conf for easy kernel initramfs setup:"
echo
mkdir -p /etc/dracut.conf.d
cat << EOF > /etc/dracut.conf.d/zol.conf
nofsck="yes"
add_dracutmodules+=" zfs "
omit_dracutmodules+=" btrfs "
#install_items+=" /etc/zfs/${POOL}.key "
EOF
echo
#
#
echo "generating a new zgenhostid:"
echo
zgenhostid
echo
#
#
echo "configuring zfsbootmenu commandline boot options on zfs ROOT:"
echo "zfs set org.zfsbootmenu:commandline="
spl_hostid=$(hostid)
echo "268435456" > /sys/module/zfs/parameters/zfs_arc_min
echo "536870912" > /sys/module/zfs/parameters/zfs_arc_max
echo
#
#
TARGETINSTALLHARDDRIVE=sda
echo "adding /boot/efi to fstab:"
echo
cat << EOF >> /etc/fstab
UUID=$(blkid | grep ${TARGETINSTALLHARDDRIVE}2 | sed -En 's/.*? UUID="([0-9a-zA-Z\-]+)".*/\1/p') /boot/efi vfat defaults,noauto 0 0
EOF
echo
echo
#
#
echo "creating  /boot/efi :"
echo
mkdir -p /boot/efi
echo
#
#
echo "mounting  /boot/efi to the small vfat partition containing the all the boot files"
echo "and configs on the target new gentoo installation hard drive:"
echo "mount /boot/efi with mount options from the fresh fstab populated with by blkid:"
BOOTEFIPARTITION=`blkid | grep ${TARGETINSTALLHARDDRIVE}2 | sed -En 's/.*? UUID="([0-9a-zA-Z\-]+)".*/\1/p'`
echo
mount -t vfat -o defaults,noauto /dev/disk/by-uuid/${BOOTEFIPARTITION} /boot/efi
echo
echo
#
#
echo -n "emerging sudo before adding regular user to sudoers"
emerge -q sudo
echo -n
echo -n
#
#echo "installing grub"
#emerge -q grub
echo
echo
echo "setting up refind boot config"
cat << EOF >> /boot/refind_linux.conf
"Boot default"  "zfsbootmenu:ROOT=${POOL} spl_hostid=$(hostid) zfs.zfs_arc_min=268435456 zfs.zfs_arc_max=536870912 timeout=0 ro quiet loglevel=5 nowatchdog"
"Boot to menu"  "zfsbootmenu:ROOT=${POOL} spl_hostid=$(hostid) zfs.zfs_arc_min=268435456 zfs.zfs_arc_max=536870912 timeout=-1 ro quiet loglevel=5 nowatchdog"
EOF
echo
echo "installing efibootmgr to /boot"
efibootmgr  -l /boot/efi/refind_aa64.efi  -v -d /dev/sda -g -p 2
echo
#
#  -----------   My custom ARM64 Gentoo virtualized by Parallels on MacOs settings  --------------



echo "configuring  /etc/doas.conf:"
echo
cat << EOF > /etc/doas.conf
permit persist keepenv :wheel
EOF
echo
echo

echo "configuring  /etc/rc.local no needed at all if installing like me in virtual mode"
echo "using the capable MacOs Parallels virtualization software bought online from https://www.parallels.com/ :"
echo
cat << EOF >> /etc/rc.local
#ip link set dev enp34s0 up
#ip addr add 10.0.1.126/24 brd + dev enp34s0
#ip route add default via 10.0.1.253
EOF
echo
echo

echo "emerging dracut, a initramfs build facilitator"
echo
emerge -q dracut
echo "install some dracut initramfs magic to boot"

echo "installing grub"
emerge -q grub
grub-install --efi-directory=/boot/grub/arm64-efi \
--target=arm64-efi --skip-fs-probe   --force
#
#echo "adding new boot kernel to  grub boot menu :"
grub-mkconfig  -o /boot/grub/grub.cfg
echo
echo "you should see something similar to these messages :"
echo "Generating grub configuration file ...\
      Found linux image: /boot/vmlinux-6.9.3/\
      Adding boot menu entry for UEFI Firmware Settings ...done"
echo
#

echo -n  "reemerging all packages with the new USE flags and system settings "
echo -n
time emerge -uDNg @world --usepkg-exclude "sys-kernel/gentoo-sources virtual/* sys-kernel/gentoo-kernel"
echo -n


echo "entering into the still unbooted chrooted gentoo as the new happy user"${gent00USERNAME}":"
echo
su --login ${gent00USERNAME}
id
echo -n
echo -n
#
#
echo -n " create assembled hybrid multicloud encrypted POOL "
POOL1=preci0uss
POOL1_PW=M00ned36-Create72-Landmine81-Provoke17-Agility95-Speed44-Okay59-Pacifier68-Groggily02-Rockstar99*
POOL1_PW2=M00ned36-Create72-Landmine81-Provoke17-Agility95-Speed44-Okay59-Pacifier68-Groggily02-Rockstar99*
# --------------- the encrypted pool version sill be tested at a later stage ----------
zpool create -f -o ashift=12 -o autotrim=on  \
-O acltype=posixacl -O canmount=off  -O compression=lz4 -O dnodesize=auto \
-O normalization=formD  -O relatime=on  -O xattr=sa  -O mountpoint=/media  \
-O encryption=aes-256-gcm -O keylocation=prompt  \
-O keyformat=passphrase  ${POOL1} /home/${POOL1}  << EOF
${POOL1_PW}
${POOL1_PW2}
EOF
echo
echo "encrypted pool "${POOL1} "created succesfully!!!"
echo "Now we export and immediatly reimport" ${POOL1}
echo "to test the encryption and passphrase:"
#
zpool export  ${POOL1}
#
echo " import the new encrypted pool:" ${POOL1}
# zpool import -l -d /home/ta0  -o altroot=/media/ta0 $POOL1
# echo "encrypted pool imported succesfully !"
#
zpool import -l  -d /home/${POOL1} -o altroot=/media/${POOL1}  ${POOL1}
#
echo "encrypted pool imported succesfully !"
echo -n
echo -n
#
#
echo "create extremly secret protected and encrypted data partitions"
zfs create -o mountpoint=/ -v    ${POOL1}
zfs create  -o mountpoint=/mixed -v ${POOL1}/mixed
zfs create  -o mountpoint=/${gent00USERNAME}  -v ${POOL1}/${gent00USERNAME}
zfs create  -o mountpoint=/${yourcompanyname} -v ${POOL1}/${yourcompanyname}
#
echo -n "extremly secret protected and encrypted data partitions successfully created  "
zfs list | grep  ${POOL1}
echo -n
echo -n "preparing ssh chroot environment"
MOUNT1=/media/${POOL1}/${gent00USERNAME}
mkdir ${MOUNT1}/proc ${MOUNT1}/sys ${MOUNT1}/dev ${MOUNT1}/run  ${MOUNT1}/dev/shm mkdir -p ${MOUNT1}/run/shm
mkdir 
mount --types proc /proc ${MOUNT1}/proc
mount --rbind /sys ${MOUNT1}/sys
mount --rbind /dev ${MOUNT1}/dev
mount --bind /run ${MOUNT1}/run
test -L ${MOUNT1}/dev/shm
rm ${MOUNT1}/dev/shm
mkdir ${MOUNT1}/dev/shm
mkdir -p ${MOUNT1}/run/shm
mount --types tmpfs --options nosuid,nodev,noexec shm ${MOUNT1}/dev/shm
chmod 1777 ${MOUNT1}/dev/shm ${MOUNT1}/run/shm
echo -n "chroot environment ready !"
#
#
POOL1=${POOL1}
echo ""
echo ""
echo "create ${POOL1}/SWAP2:"${POOL1}/SWAP2
echo
zfs  create  -v  -V  8G  -o  logbias=throughput \
-o sync=always  -o primarycache=metadata  ${POOL1}/SWAP2
echo ""
echo "setting up and activating a 8 G dedicated SWAP partition  ON our encryppted zfs pool"${POOL1}
echo
mkswap /dev/zvol/${POOL1}/SWAP2
swapon /dev/zvol/${POOL1}/SWAP2
echo ""
echo ""

echo -n "Nutrisco et extinguo"
echo -n "Hail the light !"

echo "rebooting...live long and prosper! We are B0rg collective, assimilating you now!"
echo "resistance is futile"
echo "L00pul cel rau, Luxembourg" "l00p@axetel.net"
