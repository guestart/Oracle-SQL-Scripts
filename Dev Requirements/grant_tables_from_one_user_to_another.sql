REM
REM     Script:        grant_tables_from_one_user_to_another.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Jan 26, 2024
REM
REM     Last tested:
REM             11.2.0.4
REM             19.13.0.0
REM
REM     Purpose:
REM       This sql script uses to grant tables of one user to another on production system.
REM

PROMPT =====================
PROMPT Running on SYS schema
PROMPT =====================

sqlplus / as sysdba
create user a identified by "a" default tablespace sysaux temporary tablespace temp quota 10m on sysaux;
create user b identified by "b" default tablespace sysaux temporary tablespace temp quota 10m on sysaux;
grant connect, resource to a,b;

conn a/a
create table t1(id number, type varchar2(10));
insert into t1 values (1, 'hash');
insert into t1 values (2, 'range');
commit;
select * from t1;

conn b/b
select * from a.t1;  -- table a.t1 doesn't exists.

conn a/a
grant select on a.t1 to b;

conn b/b
select * from a.t1;  -- Has been existed the query result already.

-- How to transfer grant select on a schema's entire tables to another schema (Doc ID2213987.1)

-- ex:
-- When there are A,F schemas in DB
-- [1]. How to transfer the privilege of select on A schema's all table to F schema?

-- We need to create a PL/SQL to achieve it.
-- [1] Use the below PL/SQL to grant all of A's select on table privilege to F privilege.
conn /as sysdba
SQL> create user A identified by A;
User created.
SQL> create user F identified by F;
User created.
SQL> create table A.ta(id number);
Table created.
SQL> create table A.ta2(id number, name varchar2(10));
Table created.

SQL> select grantee,owner,table_name,grantor,privilege from dba_tab_privs where grantee='F';
no rows selected

BEGIN
  FOR R IN (SELECT owner, table_name FROM all_tables WHERE owner='A') LOOP
    EXECUTE IMMEDIATE 'grant select on '||R.owner||'.'||R.table_name||' to F';
  END LOOP;
END;
/

SQL> select grantee,owner,table_name,grantor,privilege from dba_tab_privs where grantee='F';

GRANTEE OWNER TABLE_NAME GRANTOR PRIVILEGE
------- ----- ---------- ------- ---------
F       A     TA         A       SELECT
F       A     TA2        A       SELECT

-- Granting the select privilege from all tables of one user to another, in other words, from the grantor_owner to grantee_owner.

PROMPT =====================
PROMPT Running on SYS schema
PROMPT =====================

DECLARE
  v_grantor_owner dba_users.username%type := upper('&grantor_owner');
  v_grantee_owner dba_users.username%type := upper('&grantee_owner');
BEGIN
  FOR bg IN (select owner, table_name from dba_tables where owner = v_grantor_owner)
  LOOP
    EXECUTE IMMEDIATE Q'[grant select on ]' || bg.owner || Q'[.]' || bg.table_name || Q'[ to ]' || v_grantee_owner;
  END LOOP; 
END;
/
