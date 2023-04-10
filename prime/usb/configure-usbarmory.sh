#!/bin/bash

set -euo pipefail


GADGET_NAME=usbarmory
LANGUAGE=0x409 # English
MANUFACTURER="Inverse Path"
PRODUCT="USB Armory"
HOST_ADDRESS="1a:55:89:a2:69:42"
DEV_ADDRESS="1a:55:89:a2:69:41"

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi


echo "Loading libcomposite"
CONFIGFS=/sys/kernel/config/usb_gadget
modprobe libcomposite
while [ ! -d $CONFIGFS ]
do
  sleep 0.1
done


echo "Cleaning up existing gadget"
GADGET=$CONFIGFS/$GADGET_NAME
echo "Stopping getty"
systemctl stop getty@ttyGS0.service
echo "Removing config-level functions"
find $GADGET/configs/*/* -maxdepth 0 -type l -exec rm {} \; || true
echo "Removing config-level strings"
find $GADGET/configs/*/strings/* -maxdepth 0 -type d -exec rmdir {} \; || true
echo "Removing config-level OS descriptors"
find $GADGET/os_desc/* -maxdepth 0 -type l -exec rm {} \; || true
echo "Removing gadget-level functions"
find $GADGET/functions/* -maxdepth 0 -type d -exec rmdir {} \; || true
echo "Removing gadget-level strings"
find $GADGET/strings/* -maxdepth 0 -type d -exec rmdir {} \; || true
echo "Removing gadget-level configs"
find $GADGET/configs/* -maxdepth 0 -type d -exec rmdir {} \; || true
echo "Removing gadget"
rmdir $GADGET || true
echo "Starting getty"
systemctl start getty@ttyGS0.service


echo "Creating gadget"
mkdir $GADGET
cd $GADGET

echo "Configuring device identifiers"
echo 0x1d6b > idVendor  # Linux Foundation
echo 0x0104 > idProduct # Multifunction Composite Gadget
echo 0x0100 > bcdDevice # v1.0.0
echo 0x0200 > bcdUSB    # USB 2.0
mkdir strings/$LANGUAGE
echo $MANUFACTURER > strings/$LANGUAGE/manufacturer
echo $PRODUCT      > strings/$LANGUAGE/product

echo "Configuring gadget as composite device"
# https://msdn.microsoft.com/en-us/library/windows/hardware/ff540054(v=vs.85).aspx
echo 0xEF > bDeviceClass
echo 0x02 > bDeviceSubClass
echo 0x01 > bDeviceProtocol

echo "Configuring OS descriptors"
# https://msdn.microsoft.com/en-us/library/hh881271.aspx
echo 1       > os_desc/use
echo 0xcd    > os_desc/b_vendor_code
echo MSFT100 > os_desc/qw_sign

echo "Creating RNDIS function"
mkdir functions/rndis.usb0
echo $HOST_ADDRESS > functions/rndis.usb0/host_addr
echo $DEV_ADDRESS  > functions/rndis.usb0/dev_addr
# https://msdn.microsoft.com/en-us/windows/hardware/gg463179.aspx
echo RNDIS   > functions/rndis.usb0/os_desc/interface.rndis/compatible_id
echo 5162001 > functions/rndis.usb0/os_desc/interface.rndis/sub_compatible_id

echo "Creating serial function"
mkdir functions/acm.usb0

echo "Creating gadget configuration"
mkdir configs/c.1
echo 500 > configs/c.1/MaxPower
mkdir configs/c.1/strings/$LANGUAGE
echo "Config 1" > configs/c.1/strings/$LANGUAGE/configuration
ln -s functions/rndis.usb0 configs/c.1
ln -s functions/acm.usb0 configs/c.1
ln -s configs/c.1 os_desc/c.1

echo "Attaching gadget"
udevadm settle -t 5 || true
ls /sys/class/udc/ > UDC

sleep 1
ifconfig usb0 192.168.7.2 netmask 255.255.255.0

echo "Done!"
