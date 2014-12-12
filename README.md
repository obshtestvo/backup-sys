# Backup Configuration for Obshtestvo.bg Infrastructure #

## Contents ##
 * `Makefile` updates the scripts
 * `host/`
   * `do_backup.sh` - does backup for the host
   * `backup.sh` - collects backups for the containers
 * `cont/$CONTAINER` the backup script for each container

## Backup storage/strategy.

On **marla.ludost.net**, the backup is initiated *every morning at 6:06am* and
is kept for *one week*. All backups are full backups, no incremental or
differential ones.


## How to add a container to be backed up

Do nothing. The container setup script adds the needed scripts and keys where
needed. The `do_backup.sh` script gets taken from `templates/do_backup.sh` of
the `github.com/obshtestvo/create-lxc` repository, and the `authorized_keys`
gets copied from the host, which contains what's needed.

## How to modify what's being backed up

In this repository, in `cont/` create a directory with the name of the
container, put there a modified `do_backup.sh` and when done run `make` from
the top level directory of this repository, to install it.

If you have a hard time understanding the script, **DO NOT TOUCH IT** and ask
someone else.

Also, please note **NOT TO PUT ANY PASSWORDS OR OTHER SECRET DATA IN THE REPO**,
as we don't want to be known as another example of people leaving their
passwords/secrets for everyone to see on github.

## Restoring from backup

* If **koi.obshtestvo.bg** had died or you need something not from the latest
backup, ask Vasil Kolev for the encrypted files.
    * TODO some more people need access
    * Decrypt the file with the key on **koi.obshtestvo.bg**
        * If yo you don't have the passphrase for the key, ask Vasil
        * Vasil also has a backup of the key
        * TODO More people should have the key and passphrase
* OR
    * If you need the latest backup, look in `/backup` of the container for the
unencrypted files, or `/backup` on the host
* Take the needed archives/files and restore what you need

## How Does It Work ##

### Backup initiation, stage 1

A script gets triggered by cron for user `bckp` on **marla.ludost.net**, which
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



