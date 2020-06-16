#!/bin/bash
# Copyright (C) 2020 Arezqui Belaid
#
# The Initial Developer of the Original Code is
# Arezqui Belaid <info@star2billing.com>
#

DATETIME=$(date +"%Y%m%d%H%M%S")


# 1. Backup current DB
# mv /var/lib/freeswitch/db/freeswitchcdr.db /var/lib/freeswitch/db/freeswitchcdr_backup_$DATETIME.db

# 2. Download SQL to create DB
wget --no-check-certificate https://raw.githubusercontent.com/areski/excdr-pusher/master/data/create-fscdr-db.sql -O /tmp/create_sqlitedb.sql
cat /tmp/create_sqlitedb.sql | sqlite3 /tmp/new_fscdr_db.db

# 3. Replace DB
# mv /tmp/new_fscdr_db.db /var/lib/freeswitch/db/freeswitchcdr.db