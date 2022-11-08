-- the sql, call by 2__mysql_init.zsh --
stop slave;
RESET SLAVE all;

-- for set user's pwd
ALTER USER 'dev'@'%' ACCOUNT LOCK;

-- switch the running config table to UAT
DROP TABLE IF EXISTS tenant.saas_tenant_dbs;
CREATE OR REPLACE VIEW tenant.saas_tenant_dbs AS
select id AS id, uuid AS uuid, tenant_id AS tenant_id, db_code AS db_code, 
db_text AS db_text, is_default AS is_default, status AS status, is_deleted AS is_deleted, 
author AS author, editor AS editor, created AS created, modified AS modified
from uat_only.saas_tenant_dbs;

DROP TABLE IF EXISTS tenant.sys_config;
CREATE OR REPLACE VIEW tenant.sys_config AS
select id AS id, uuid AS uuid, tenant_id AS tenant_id, name AS name, cnf_key AS cnf_key, 
cnf_byte AS cnf_byte, cnf_text AS cnf_text, created AS created, modified AS modified
from uat_only.sys_config;


-- unlock user && change user pwd for UAT --
ALTER USER 'dev'@'%' IDENTIFIED BY 'zyB1003e1289';
ALTER USER 'dba'@'%' IDENTIFIED BY 'zyb#B1003';
ALTER USER 'root'@'%' IDENTIFIED BY 'FH7ipt39NJzc1s';
-- the readonly user
RENAME USER 'readall'@'%' TO 'readonly'@'%';
ALTER USER 'readonly'@'%' IDENTIFIED BY 'Read123';
-- unlock dev
ALTER USER 'dev'@'%' ACCOUNT UNLOCK;

