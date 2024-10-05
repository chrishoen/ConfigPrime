#!/bin/sh
cd "$(dirname "$0")"

my_program="/opt/prime/bin/ProtoUdpMsg"
sudo setcap 'cap_sys_nice=eip cap_sys_resource=eip cap_fowner=eip cap_ipc_lock=eip cap_ipc_owner=eip cap_net_bind_service=eip' $my_program
$my_program $1 $2 $3 $4
