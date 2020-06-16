

# 1. Backup current DB
mv /tmp/test.db /tmp/test_old.db

# 2. Download SQL to create DB
cat ./data/create-fscdr-db.sql | sqlite3 /tmp/test.db

# 3. Replace DB
