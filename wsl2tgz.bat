#!/bin/bash
# ---------------------------------------------------------------------
#
# E X P O R T    W S L    T O    T G Z     D I R E C T L Y 
#
# Author : Hassan Berro
#
# ---------------------------------------------------------------------
# By default, and as of August 2023, Microsoft WSL2 exports automatically
# existing distributions to uncompressed .tar files.
#
# The puropose of this script is to allow exporting to .tar.gz without
# passing by tar

@echo off 
set EXE7Z="C:\Program Files\7-Zip\7z.exe"
set DIST_NAME="smeca"
set OUT_TGZ="F:\smeca\smeca-2022.tar.gz"


# E X P O R T    D I R E C T L Y    T O    T G Z 
wsl --export %DIST_NAME% - | %EXE7Z% a -tgzip %OUT_TGZ% -si