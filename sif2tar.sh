#!/bin/bash
# ---------------------------------------------------------------------
#
# C O N V E R T    S I F   T O   T A R . GZ
#
# Author : Hassan Berro
#
# ---------------------------------------------------------------------

# ---------------------------------------------------------------------
# /!\     I M P O R T A N T    /!\
# ---------------------------------------------------------------------
# This script needs to be run on a linux system or a WSL distro with:
# 1. A singularity installation
# 2. Availability of sqfs2tar (should be a prerequisite of #1)
# ---------------------------------------------------------------------

TEMP_FOLDER="/mnt/f/temp"

# List all blocks in the origin SIF
singularity sif list /path/to/container-image.sif

# ---------------------------------------------------------------------
# /!\     I M P O R T A N T    /!\
# ---------------------------------------------------------------------
# The output of the previous command can vary depending on how the
# singularity image was built, what is important is the block number
# corresponding to the fs data part (here assumed == 3)
# ---------------------------------------------------------------------

# Dump disk envvars and data (here assuming blocks 2&3 respectively)
mkdir -p $TEMP_FOLDER
singularity sif dump 2 > $TEMP_FOLDER/env-vars.txt
singularity sif dump 3 /path/to/container-image.sif > $TEMP_FOLDER/data.squash

# Convert the squash to a tar.gz
sqfs2tar -c gzip -s $TEMP_FOLDER/data.squash > $TEMP_FOLDER/wsl-distrib.tar.gz

# # Or, it is possible to generate a .tar (uncompressed)
# sqfs2tar -s $TEMP_FOLDER/data.squash > $TEMP_FOLDER/wsl-distrib.tar.gz
# exit

# Cleanup...
rm $TEMP_FOLDER/data.squash
