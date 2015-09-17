#!/bin/bash

#for file in * ; do
#  echo $file
#done

echo -n "Enter path, followed by [ENTER]:"
read isofilepath
echo

echo -n "Enter your desired Virtual Machine name, followed by [Enter]:"
read vmname
echo

echo -n "Enter '32' for 32-bit or '64' for 64-bit, followed by [Enter]:"
read bitversion
echo

if [ -a "$isofilepath/CentOS-6.6-i386-minimal.iso" ] || [ -a "$isofilepath/CentOS-6.6-x86_64-minimal.iso" ]
  then
    echo "they exist"
  else
    echo "fail"
fi


#find $isofilepath -name "CentOS-6.6-i386-minimal.iso"

#########################################################################

if [ $bitversion == 32]
  then
    if [ -a "$isofilepath/CentOS-6.6-i386-minimal.iso" ]
	  then
	    isofile=defaultisoname #change this
	elif [ ! -a "$isofilepath/CentOS-6.6-i386-minimal.iso" ]
	  then
	    filelist=$(find $isofilepath -maxdepth 1 -name "*.iso" -exec basename '{}' \;)
		select filename in $filelist
		  do
		    