#!/bin/bash

cd /tmp

if [ "$(getconf LONG_BIT)" == "64" ]; then arch=amd64; else arch=i386; fi

function download_package() {
	wget $(lynx -listonly -dont-wrap-pre -dump $kernelURL | grep "$1" | grep "$2" | grep "$arch" | cut -d ' ' -f 4 | uniq)
}

# Getting the latest kernel version on kernel.org
latestKernelVersion=$(curl -s https://www.kernel.org | grep -oP "\d.\d.\d(?=</a>)")

kernelURL="https://kernel.ubuntu.com/~kernel-ppa/mainline/v$latestKernelVersion/"

echo "Dowloading the version $latestKernelVersion generic kernel."
# Download the kernel
download_package generic headers
CODE_HEADERS="$?"
download_package generic image
CODE_IMAGE="$?"
download_package generic modules
CODE_MODULE="$?"

if [ "$CODE_HEADERS" != "0" ] || [ "$CODE_IMAGE" != "0" ] || [ "$CODE_MODULE" != "0" ]; then
	echo "Cannot download kernel file from kernel.ubuntu.com."
	echo "Exiting..."
	exit 1
fi

# Download the shared kernel headers
wget $(lynx -listonly -dont-wrap-pre -dump $kernelURL | grep all | cut -d ' ' -f 4 | uniq)

# Install the kernel
echo "Installing Linux Kernel v$latestKernelVersion..."
sudo dpkg -i linux*.deb
echo "Installation completed. You may reboot if you want to use your fresh new Kernel."

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

