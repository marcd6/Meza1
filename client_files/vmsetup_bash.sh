#!/bin/bash
#
# Setup virtual machine on VirtualBox

# Obtain iso file path, virtual machine name and OS bit-version from user.
while [ -z "$isofilepath" ]
do
echo -n -e "Enter path, followed by [ENTER]:"
read -e isofilepath
done
echo

while [ -z "$vmname" ]
do
echo -n "Enter your desired Virtual Machine name, followed by [Enter]:"
read vmname
done
echo

while [ -z "$bitversion" ]
do
echo -n "Enter '32' for 32-bit or '64' for 64-bit, followed by [Enter]:"
read bitversion
done
echo


#If the user enters an iso file path with '/' at the end, this removes it.
if [[ "$isofilepath" == */ ]]; then

	isofilepath=${isofilepath%/}

fi


#This counts how many iso files are in $isofilepath
iso_count=0
for generic_iso in $(find $isofilepath -name "*.iso"); do
	
	((iso_count+=1))
	
done

# iso file selection
# LOGIC SUMMARY
# if 32-bit; then
# 	if default iso file name found; then
#		isofile=default iso file name
#	elif default iso file not found and iso files are present; then
#		echo menu of iso files and user selects iso file of choice
#	else
#		error

#if 64-bit; then
#	if default iso file name found; then
#		isofile=default iso file name
#	elif default iso file not found and iso files are present; then
#		echo menu of iso files and user selects iso file of choice
#	else
#		error
file_option=*.iso
if [ $bitversion == 32 ]; then

    if [ -e "$isofilepath/CentOS-6.6-i386-minimal.iso" ]; then
	
	    isofile="$isofilepath/CentOS-6.6-i386-minimal.iso"
		whichos="RedHat"
		
	elif [ $iso_count -gt 0 ]; then
		
		echo "Select .iso file:"
	    filelist=$(find $isofilepath -name "*.iso" -exec basename '{}' \;)
		select filename in $filelist exit
		  do
		    case $filename in
				exit)
					echo "You chose to exit."
					exit
					;;
			esac
			isofile="$isofilepath/$filename"
			break
		done
		whichos="RedHat"
		
	else
	
	    echo "Error. Iso files could not be found"
		exit
	  
	fi

elif [ $bitversion == 64 ]; then

	if [ -e "$isofilepath/CentOS-6.6-x86_64-minimal.iso" ]; then
	
		isofile="$isofilepath/CentOS-6.6-x86_64-minimal.iso"
		whichos="RedHat_64"
		
	elif [ $iso_count -gt 0 ]; then
	
		echo "Select .iso file:"
	    filelist=$(find $isofilepath -name "*.iso" -exec basename '{}' \;)
		select filename in $filelist exit
		  do
		    case $filename in
				exit)
					echo "You chose to exit."
					exit
					;;
			esac
			isofile="$isofilepath/$filename"
			break
			whichos="RedHat_64"
		done
		
	else
	
	    echo "Error. Iso files could not be found."
	    exit
	  
	fi
	
else

	echo "Invalid entry for bit-version. '32' or '64' are the only allowed values."
	exit
	
fi
echo "Using $isofile"
echo

hostonlyname='VirtualBox Host-Only Ethernet Adapter'
storage=10240
memory=1024
vram=128

#createhd creates a new virtual hard disk image
#dynamic disk is 10GB
vboxmanage createhd --filename "/c/users/$USERNAME/VirtualBox VMs/$vmname/$vmname.vdi" --size $storage

#createvm creates a new XML virtual machine definition file
vboxmanage createvm --name $vmname --ostype $whichos --register

#storagectl attaches/modifies/removes a storage controller
vboxmanage storagectl $vmname --name "SATA Controller" --add sata --controller IntelAHCI

#storageattach attaches/modifies/removes a storage medium connected 
#to a storage controller that was previously added with the storagectl command
vboxmanage storageattach $vmname --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "/c/users/$USERNAME/VirtualBox VMs/$vmname/$vmname.vdi"

vboxmanage storagectl $vmname --name "IDE Controller" --add ide
vboxmanage storageattach $vmname --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium $isofile
vboxmanage storageattach $vmname --storagectl "IDE Controller" --port 1 --device 0 --type dvddrive --medium "/c/Program Files/Oracle/VirtualBox/VBoxGuestAdditions.iso"
#modifyvm changes the properties of a registered virtual machine which is not running
#audio needs to be fixed
vboxmanage modifyvm $vmname --ioapic on
vboxmanage modifyvm $vmname --boot1 dvd --boot2 disk --boot3 none --boot4 none
vboxmanage modifyvm $vmname --memory $memory --vram $vram
vboxmanage modifyvm $vmname --nic1 nat
vboxmanage modifyvm $vmname --nic2 hostonly --hostonlyadapter2 "$hostonlyname"
vboxmanage modifyvm $vmname --natpf1 [ssh],tcp,,3022,,22
vboxmanage modifyvm $vmname --audio null
vboxmanage sharedfolder add "$vmname" --name "your_shared_folder" --hostpath "/c/users/$USERNAME/desktop"