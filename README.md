# Backup Configuration for Obshtestvo.bg Infrastructure #

## Contents ##
 * `Makefile` updates the scripts
 * `host/`
   * `do_backup.sh` - does backup for the host
   * `backup.sh` - collects backups for the containers
 * `cont/$CONTAINER` the backup script for each container

## How Does It Work ##

### Backup initiation, stage 1

A script gets triggered by cron for user bckp on **marla.ludost.net**, which
logs into **koi.obshtestvo.bg** with a specific ssh key and triggers
`/usr/local/sbin/backup.sh`. That script prepares the backups and pipes
them in tar format to stdout. This is described in `/root/.ssh/authorized_keys`.

### /usr/local/sbin/backup.sh

This script triggers the backup creation using ssh in all containers it
finds, calling `/do_backup.sh` over ssh. For this to work for the container, in
it in `/root/.ssh/authrorized_keys` there should be a line that allows calling
`/do_backup.sh` using the backup key (which can be located on 
**koi.obshtestvo.bg** in `/root/.ssh/`).

All `do_backup.sh` scripts create a `/backup` directory in the container, which
then gets encrypted using gpg with a key that can be found in `/root/gnupg`:
 
```
pub   4096R/FDA82047 2014-09-22
uid                  Obshtestvo Backup <root@koi.obshtestvo.bg>
sub   4096R/09EDA521 2014-09-22
```

The encrypted files are sent in tar format to stdout.

### Per-container `/do_backup.sh`

For this script to be able to work, the following is required in the container:

* In `/root/.ssh/authorized_keys`, an entry for the backup key should be made,
starting with `command="/do_backup.sh",no-pty,no-port-forwarding,no-X11-forwarding,no-agent-forwarding`.
* If mysql databases are available in the container, the default debian config
files should be available in `/etc/mysql/debian.cnf`.
* If pgsql databases are available in the container, the database has to run
as the postgres user and sudo must be available.
