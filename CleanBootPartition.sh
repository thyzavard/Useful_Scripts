#!/bin/bash

if [ "$(id -u)" != "0" ]; then
	echo "Please login as root, then try again" 1>&2
	exit 1
fi		

KERNEL_VERSION=$(uname -r)
echo -e "Your actual kernel version is $KERNEL_VERSION\n"

echo "This is the list of all old kernel on your system:"
dpkg --list 'linux-image*'|awk '{ if ($1=="ii") print $2}'|grep -v $KERNEL_VERSION

read -p "Would you like to remove all of these kernel? [y/n] " answer_remove

case $answer_remove in 
	[Yy]* ) echo -e "\nPurge all old kernel...\n"
		apt purge $(dpkg --list 'linux-image*'|awk '{ if ($1=="ii") print $2}'|grep -v $KERNEL_VERSION)
		echo -e "\nRemove all unused packages...\n"
		apt autoremove
		echo -e "\nUpdate the GRUB\n"
		update-grub
		;;
	[Nn]* ) echo "Exiting..."; exit 1
		;;
	* ) echo "Please answer yes or no."; exit 1;;
esac

echo
read -p "Would you restart the system now? [y/n] " answer_reboot

case $answer_reboot in
	[Yy]* ) echo "Restart in 5 seconds..."
		sleep 5
		reboot
		;;
	[Nn]* ) echo "Done."; exit 0
		;;
	* ) echo "Please answer yes or no."; exit 1;;
esac
