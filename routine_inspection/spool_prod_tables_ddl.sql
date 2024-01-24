REM
REM     Script:        spool_prod_tables_ddl.sql
REM     Author:        Quanwen Zhao
REM     Dated:         JAN 23, 2024
REM
REM     Last tested:
REM             11.2.0.4
REM             19.13.0.0
REM
REM     Purpose:
REM       This sql script uses to check the ddl situation for all the tables of the specific production user by the oracle internal function "dbms_metadata.get_ddl".
REM

-- three number of SQL scripts, but we can just running (2) first and then (3), we'll get result on /tmp/spo_prod_tables_ddl.sql.

-- (1) /tmp/user_tables_ddl.sql
-- (2) /tmp/spool_user_tables_ddl.sql
-- (3) /tmp/spool_prod_tables_ddl.sql



cat /tmp/user_tables_ddl.sql

set linesize 400
set pagesize 400
col table_ddl for a100
select Q'[select dbms_metadata.get_ddl('TABLE', ]' || Q'[']' || table_name || Q'[', ']' || owner || Q'[') from dual;]' as table_ddl
from dba_tables
where owner = upper('&owner');


cat /tmp/spool_user_tables_ddl.sql

set long 999999999
set pagesize 0     -- setting page size is 0
set heading off    -- disable column heading
set feedback off   -- disable query result prompt info
set echo off       -- disable command echoing
set termout on     -- enable outputting to the terminal
set trimspool on   -- eliminating the extra blank spaces on for the output result
spool '/tmp/spo_user_tables_ddl.sql'
@/tmp/user_tables_ddl.sql;
spool off
set heading on
set feedback on
set echo on


cat /tmp/spool_prod_tables_ddl.sql

set long 999999999
set pagesize 0     -- setting page size is 0
set heading off    -- disable column heading
set feedback off   -- disable query result prompt info
set echo off       -- disable command echoing
set termout on     -- enable outputting to the terminal
set trimspool on   -- eliminating the extra blank spaces on for the output result
execute dbms_metadata.set_transform_param(dbms_metadata.session_transform, 'STORAGE', false);
spool '/tmp/spo_prod_tables_ddl.sql'
@/tmp/spo_user_tables_ddl.sql;
spool off
execute dbms_metadata.set_transform_param(dbms_metadata.session_transform, 'DEFAULT');
set heading on
set feedback on
set echo on
