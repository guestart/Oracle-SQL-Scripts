SET echo     OFF
SET feedback OFF
SET newpage  NONE
SET verify   OFF
SET define   OFF
SET term     OFF
SET trims    ON
SET heading  OFF
SET timing   OFF

SET linesize 600
SET pagesize 0

COLUMN owner       FORMAT a30
COLUMN object_type FORMAT a30
COLUMN object_name FORMAT a128
COLUMN table_name  FORMAT a30

SPOOL migration_validate.txt

SELECT owner
       , object_type
       , object_name
FROM dba_objects
WHERE owner IN (
                 SELECT username
                 FROM dba_users
                 WHERE account_status = 'OPEN'
                 AND default_tablespace NOT IN ('SYSTEM', 'SYSAUX')
               )
ORDER BY 1,2,3
/

SELECT owner
       , table_name
FROM dba_tables
WHERE owner IN (
                 SELECT username
                 FROM dba_users
                 WHERE account_status = 'OPEN'
                 AND default_tablespace NOT IN ('SYSTEM', 'SYSAUX')
               )
ORDER BY 1,2
/

SET serveroutput ON;

DECLARE
  t_owner VARCHAR2(50);
  t_name  VARCHAR2(100);
  t_num   NUMBER(10) DEFAULT 0;
  
CURSOR c_owner_table IS 
SELECT owner
       , table_name
FROM dba_tables
WHERE owner IN (
                 SELECT username
                 FROM dba_users
                 WHERE account_status = 'OPEN'
                 AND default_tablespace NOT IN ('SYSTEM', 'SYSAUX')
               )
ORDER BY 1,2
/

BEGIN
  FOR cur_owner_table IN c_owner_table
  LOOP
    t_owner := cur_owner_table.owner;
    t_name  := cur_owner_table.table_name;
    EXECUTE IMMEDIATE 'select count(*) from '||t_owner||'.'||t_name into t_num; 
    --select owner,table_name into t_owner,t_name from cur_owner_table;
    DBMS_OUTPUT.put_line('Owner: '||t_owner||', '||'Table_Name: '||t_name||', '||'Table_Num: '||t_num);
  END LOOP;
END;
/

SPOOL OFF
