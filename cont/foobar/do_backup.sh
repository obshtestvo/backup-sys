#!/bin/bash
set -e

BACKUP_DIR=/backup

umask 0077

mkdir -p "$BACKUP_DIR"
rm -f "$BACKUP_DIR"/*

tar --use-compress-program=pbzip2 -cPf "$BACKUP_DIR/etc.tar.bz2" /etc/ /do_backup.sh
tar --use-compress-program=pbzip2 -cPf "$BACKUP_DIR/dirs.tar.bz2" /root/
tar --use-compress-program=pbzip2 -cPf "$BACKUP_DIR/logs.tar.bz2" /var/log/

