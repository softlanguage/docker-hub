- docker exec -it migrate-mysql-devops bash

```sh
# 1. prepare
docker exec -it migrate-mysql-devops bash

# 2. backup to local sql
mysqldump -h 192.168.2.197 -P9033 \
    --set-gtid-purged=OFF \
    --default-character-set=utf8mb4 \
    --routines \
    --triggers \
    -p -uroot -B crm_yxb > ./bak_crm_yxb.sql


# 3. test on local-mysql (check mysql5.7's encode: utf8mb4_general_ci, utf8mb4_unicode_ci)
sed 's/utf8mb4_0900_ai_ci/utf8mb4_general_ci/g' bak_crm_yxb.sql | mysql -D demo --force
```