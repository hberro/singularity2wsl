#!/bin/bash
# ---------------------------------------------------------------------
#
# I M P O R T   A S   A   F I X E D - S I Z E  D I S K
#
# Author : Hassan Berro
#
# ---------------------------------------------------------------------
# By default, and as of August 2023, Microsoft WSL2 imports automatically
# to dynamic expanding size VHDX disks. The benefits of this is that 
# the user does not have to worry about the allocated space initially, but
# the downsides are : speed of access, ever-expanding effect where the
# methods to shrink the disk do not seem to be reliable.
# ---------------------------------------------------------------------
# This script aims to import a .tar.gz WSL distribution as a fixed-size
# disk (in vhdx format)
# ---------------------------------------------------------------------

# Final installation directory of the fixed-size WSL, disk size, and name
Set-Variable -Name INSTALL_DIR -Value "C:\smeca"
Set-Variable -Name DISK_SIZE -Value "30gb"
Set-Variable -Name DIST_NAME -Value "smeca"

# Location of the source tgz file to be imported
Set-Variable -Name SRC_TGZ -Value "F:\containers\wsl\smeca2022-scibian9.tar.gz"

# Temporary working directory (must have enough space) and temporary name
Set-Variable -Name TEMP_DIR -Value "F:\temp"
Set-Variable -Name TEMP_DIST_NAME -Value "_temp_"


# ---------------------------------------------------------------------
# /!\     I M P O R T A N T    /!\
# ---------------------------------------------------------------------
# This script needs to be run in an elevated Powershell (Administrator)
# It requires having an existing WSL linux distribution to do the 
# disk copying. A lightweight ubuntu works just fine for that matter.
# We assume that this lightweight linux is set as the default wsl
# distro to start with.
#
# wsl --set-default NAME_OF_DISTRIB 
# ---------------------------------------------------------------------

# -------------------------------------------
# /!\ Administrator Powershell (Windows) /!\
# -------------------------------------------

# STEP 1 // Import tar gz with the default WSL settings to TEMP_DIR
#        // Dynamic VHDX, 1 Tera max size
mkdir $TEMP_DIR
wsl --import $TEMP_DIST_NAME $TEMP_DIR $SRC_TGZ
wsl --shutdown

# STEP 2 // Create an empty VHDX file (Fixed size) in INSTALL_DIR
#        // Note that the brut importing gives a filesystem size of 28.3GB
mkdir $INSTALL_DIR
new-vhd -Fixed -SizeBytes $DISK_SIZE -BlockSizeBytes 1mb -path $INSTALL_DIR\ext4.vhdx

# Note that steps 1&2 can be undertaken in parallel in two (Administrator) Powershells

# STEP 3 // Mount both disks, the fixed one as bare (/dev/sd*) and 
#           the dynamic (temporary) one as regular (goes to /mnt/wsl/srcdrive)
wsl --mount --vhd --bare $INSTALL_DIR\ext4.vhdx
wsl --mount --vhd --name srcdrive $TEMP_DIR\ext4.vhdx

# STEP 4 // Enter any available linux distribution (ubuntu is ok), check
#           which dev was attributed to the fixed drive (should be /dev/sdc)
wsl -u root

# -------------------------
# /!\ WSL linux as root /!\
# -------------------------
lsblk

# STEP 5 // Create an empty ext4 filesystem and mount it to /mnt/wsl/newdrive
#           then copy the filesystem (all files) from srcdrive to newdrive
sudo mkfs.ext4 /dev/sdc
sudo mount -t ext4 /dev/sdc /mnt/wsl/newdrive -o X-mount.mkdir
cp -axT /mnt/wsl/srcdrive/ /mnt/wsl/newdrive/
exit

# -------------------------------------------
# /!\ Administrator Powershell (Windows) /!\
# -------------------------------------------

wsl --shutdown
wsl --unmount

# STEP 6 // Import the new (fixed-disk) WSL distribution and clean-up the 
#           temporary (dynamic-disk) distribution
wsl --import-in-place $DIST_NAME $INSTALL_DIR\ext4.vhdx
wsl --unregister $TEMP_DIST_NAME