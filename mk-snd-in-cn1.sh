#!/bin/bash
#
# run from outside the container... as NORMAL user
#
#-------------------------------------------------------------------------------------------------------------
# Source reference:  https://github.com/lxc/lxd/blob/master/doc/configuration.md
#
# command usage:
# Device entries are added through: lxc config device add [key=value]... 
# or
# lxc profile device add [key=value]...
#
# Type: unix-char
#
# Unix character device entries simply make the requested character device appear in the container's /dev and 
# allow read/write operations to it.
#
# The following properties exist:
#
# Key 		Type 	Default 	Required 	Description
# path 		string 	- 		yes 		Path inside the container
# major 	int 	device on host 	no 		Device major number
# minor 	int 	device on host 	no 		Device minor number
# uid 		int 	0 		no 		UID of the device owner in the container
# gid 		int 	0 		no 		GID of the device owner in the container
# mode 		int 	0660 		no 		Mode of the device in the container
#------------------------------------------------------------------------------------------------------------


lxc config device add cn1 /dev/dri/card0 unix-char path=/dev/dri/card0
lxc config device add cn1 /dev/snd unix-char path=/dev
#
lxc config device add cn1 /dev/snd/controlC0 unix-char path=/dev/snd/
lxc config device add cn1 /dev/snd/controlC1 unix-char path=/dev/snd/
lxc config device add cn1 /dev/snd/controlC2 unix-char path=/dev/snd/
lxc config device add cn1 /dev/snd/hwC0D0 unix-char path=/dev/snd/
lxc config device add cn1 /dev/snd/hwC1D0 unix-char path=/dev/snd/
lxc config device add cn1 /dev/snd/pcmC0D0c unix-char path=/dev/snd/
lxc config device add cn1 /dev/snd/pcmC0D0p unix-char path=/dev/snd/
lxc config device add cn1 /dev/snd/pcmC0D1p unix-char path=/dev/snd/
lxc config device add cn1 /dev/snd/pcmC0D2c unix-char path=/dev/snd/
lxc config device add cn1 /dev/snd/pcmC1D3p unix-char path=/dev/snd/
lxc config device add cn1 /dev/snd/pcmC1D7p unix-char path=/dev/snd/
lxc config device add cn1 /dev/snd/pcmC1D8p unix-char path=/dev/snd/
lxc config device add cn1 /dev/snd/pcmC2D0c unix-char path=/dev/snd/
lxc config device add cn1 /dev/snd/seq unix-char path=/dev/snd/
lxc config device add cn1 /dev/snd/timer unix-char path=/dev/snd/


