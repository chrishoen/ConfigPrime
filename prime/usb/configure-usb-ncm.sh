#!/bin/bash


modprobe libcomposite

# create gadget
mkdir /sys/kernel/config/usb_gadget/g1
cd /sys/kernel/config/usb_gadget/g1
echo "0x112b" > idVendor
echo "0x000d" > idProduct

mkdir strings/0x409
echo "0123456789" > strings/0x409/serialnumber
echo "Stenograph" > strings/0x409/manufacturer
echo "Luminex" > strings/0x409/product

# create config
mkdir configs/c.1
mkdir configs/c.1/strings/0x409
echo "my configuration" > configs/c.1/strings/0x409/configuration

# create function - general serial
# this shows up in windows device manager as a com port
# Stenograph Writer Serial Port (COM3)
# this show up here as /dev/ttyGS1
mkdir functions/gser.usb0
ln -s functions/gser.usb0 configs/c.1

# create function - stenograph proprietary serial
# catalyst uses this to talk to the writer
# this show up here as /dev/ttyGS0
mkdir functions/acm.usb0
ln -s functions/acm.usb0 configs/c.1

# create function - ncm, network control model
# this shows up in windows as a cdc ncm device
# this is used for usb ethernet
mkdir functions/ncm.usb0
echo "1a:55:89:a2:69:42" > functions/ncm.usb0/host_addr
echo "1a:55:89:a2:69:41" > functions/ncm.usb0/dev_addr
ln -s functions/ncm.usb0 configs/c.1

# activate
udevadm settle -t 5 || true
ls /sys/class/udc/ > UDC
sleep 1
ifconfig usb0 192.168.7.2 netmask 255.255.255.0


