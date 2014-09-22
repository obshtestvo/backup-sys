all:
	cp host/do_backup.sh /
	cp host/backup.sh /usr/local/sbin
	for c in $(ls cont); do cp host/$c/do_backup.sh /var/lib/lxc/$c/rootfs/; done
