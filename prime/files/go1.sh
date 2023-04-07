#!/bin/sh
cd "$(dirname "$0")"

my_program="/home/root/stenograph/bin/sbr-emulator"
sudo setcap 'cap_sys_nice=eip' $my_program
$my_program -cli
exit




