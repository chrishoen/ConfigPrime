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

# create function
mkdir functions/cust1.usb0
ln -s functions/cust1.usb0 configs/c.1

# create function
mkdir functions/cust2.usb0
ln -s functions/cust2.usb0 configs/c.1

# activate
ls /sys/class/udc > UDC
