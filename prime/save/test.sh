cd $(dirname $(readlink -f $0))


my_program=/var/tmp/Dev_RisLib/build/ThreadSynch/ThreadSynch

if ! [ -f $my_program ]
then
my_program=/opt/cprint/bin/ThreadSynch
fi

echo $my_program
rlfe sudo $my_program $1




