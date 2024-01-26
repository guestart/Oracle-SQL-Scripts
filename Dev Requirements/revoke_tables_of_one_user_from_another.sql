REM
REM     Script:        revoke_tables_of_one_user_from_another.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Jan 26, 2024
REM
REM     Last tested:
REM             11.2.0.4
REM             19.13.0.0
REM
REM     Purpose:
REM       This sql script uses to revoke tables of one user from another on production system.
REM

-- Revoking the select privilege of all tables of one user from another, in other words, from grantee_owner directly.

PROMPT =====================
PROMPT Running on SYS schema
PROMPT =====================

DECLARE
  v_grantor_owner dba_users.username%type := upper('&grantor_owner');
  v_grantee_owner dba_users.username%type := upper('&grantee_owner');
BEGIN
  FOR bg IN (select owner, table_name from dba_tables where owner = v_grantor_owner)
  LOOP
    EXECUTE IMMEDIATE Q'[revoke select on ]' || bg.owner || Q'[.]' || bg.table_name || Q'[ from ]' || v_grantee_owner;
  END LOOP; 
END;
/
