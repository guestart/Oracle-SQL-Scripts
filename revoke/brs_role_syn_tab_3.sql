REM
REM     Script:    brs_role_syn_tab_3.sql
REM     Author:    Quanwen Zhao
REM     Dated:     Jul 18, 2019
REM
REM     Purpose:
REM         This SQL script uses to revoke new role (bbs) from new user (qwz) to whom if (once) being granted on schema 'SYS'.
REM
REM         If you wanna furthermore revoke select privilege on new role (bbs) and drop this role you can do the following steps:
REM           (01) Drop public synonym mv_t1 on schema 'prod';
REM           (02) Revoke 'select on mv_t1' from role 'bbs' on schema 'prod';
REM           (03) Drop materialized view 'mv_t1' on schema 'prod';
REM           (04) Drop role 'bbs' on schema 'SYS';
REM           (05) Revoke 'drop any materialized view' from schema 'prod' on schema 'SYS';
REM           (06) Revoke 'create any materialized view' from schema 'prod' on schema 'SYS';
REM           (07) Revoke 'drop public synonym' from schema 'prod' on schema 'SYS';
REM           (08) Revoke 'create public synonym' from schema 'prod' on schema 'SYS';
REM           (09) Drop user 'qwz' on schema 'SYS';
REM
REM         The advantage and convenience of this approach is that it could not only revoke more than one user but also just revoke role.
REM

SET long     10000
SET linesize 300
SET pagesize 0
 
SET echo      OFF
SET feedback  OFF
SET heading   OFF
SET termout   OFF
SET verify    OFF
SET trimout   ON
SET trimspool ON

PROMPT =========================
PROMPT Executing on "SYS" schema
PROMPT =========================

REVOKE bbs FROM qwz;

PROMPT ==========================
PROMPT Executing on "PROD" schema
PROMPT ==========================

-- switching to specific schema "prod", BTW I use Oracle SEPS (Security External Password Store) to achieve the intention
-- saving password of schema "prod".

CONN /@prod;

DROP PUBLIC SYNONYM mv_t1;
REVOKE SELECT ON mv_t1 FROM bbs;

DROP MATERIALIZED VIEW mv_t1;

PROMPT =========================
PROMPT Executing on "SYS" schema
PROMPT =========================

CONN / as sysdba;

DROP ROLE bbs;

REVOKE drop any materialized view FROM prod;
REVOKE create any materialized view FROM prod;

REVOKE drop public synonym FROM prod;
REVOKE create public synonym FROM prod;

REVOKE connect, resource FROM qwz;
DROP USER qwz;

-- Or just revoke role_name from new user_name.
-- REVOKE bbs FROM qwz;
