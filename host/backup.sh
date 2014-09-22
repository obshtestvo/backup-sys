#!/bin/sh 

name=backup
key=FDA82047
bd=/enc-backup

mkdir -p $bd
umask 0177

#set -x

if [ -f /var/run/$name.pid ]; then
        if [ -d /proc/`cat /var/run/$name.pid` ] ; then
                echo $name.sh already running!
                exit 0
        fi
fi

echo $$ > /var/run/$name.pid
trap "rm -f /var/run/$name.pid" exit SIGHUP SIGINT SIGTERM 

rm -f $bd/*

cd /var/lib/lxc || exit 3
for cont in *; do
	( 
		ssh -T -i /root/.ssh/backup_key_rsa root@$cont.cont 2>/dev/null
		if [ ! -d $cont/rootfs/backup ]; then
			continue
		fi
		cd $cont/rootfs/backup || continue
		for fl in *; do
			gpg --no-tty --homedir=/root/.gnupg -q --encrypt -r $key -o $bd/${cont}_${fl}.gpg $fl 2>/dev/null >/dev/null
		done
	)
done
bash /do_backup.sh

cd /backup
cont=koi
for fl in *; do
	gpg --no-tty --homedir=/root/.gnupg -q --encrypt -r $key -o $bd/${cont}_${fl}.gpg $fl 2>/dev/null >/dev/null
done

cd $bd 

#tar cf - *gpg
#rm *
rm -f /var/run/$name.pid
