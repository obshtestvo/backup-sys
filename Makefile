all:
	cp host/do_backup.sh /
	install -m 0755 host/backup.sh /usr/local/sbin
	for c in $$(ls cont); do cp cont/$$c/do_backup.sh /var/lib/lxc/$$c/rootfs/; done
