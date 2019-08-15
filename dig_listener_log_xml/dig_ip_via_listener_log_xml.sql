REM
REM        Script:        dig_ip_via_listener_log_xml.sql
REM        Author:        Quanwen Zhao
REM        Dated:         Aug 14, 2019
REM
REM        Purpose:
REM            This SQL script uses to dig real IP Address from the "XML" format of listener log file "log.xml".
REM
REM        Last tested:
REM                Oracle 11.2.0.4.0
REM

PROMPT =========================
PROMPT Executing on "SYS" schema
PROMPT =========================

CREATE OR REPLACE DIRECTORY listener_log_xml AS '/u01/app/oracle/diag/tnslsnr/xxxx/listener/alert';

DROP TABLE listener_log_xml;

CREATE TABLE listener_log_xml (line VARCHAR2(4000))
ORGANIZATION EXTERNAL (
  TYPE ORACLE_LOADER
  DEFAULT DIRECTORY listener_log_xml
  ACCESS PARAMETERS (
    RECORDS DELIMITED BY NEWLINE
    NOBADFILE
    NOLOGFILE
    NODISCARDFILE
    FIELDS LDRTRIM
    MISSING FIELD VALUES ARE NULL
    REJECT ROWS WITH ALL NULL FIELDS
    (
      line CHAR(4000)
    )
  )
  LOCATION ('log.xml')
)
REJECT LIMIT UNLIMITED
/
    
SET LONG 999999999    
SET PAGESIZE 80

SELECT line FROM listener_log_xml WHERE rownum <= 18
/

SET PAGESIZE 200
COLUMN host FORMAT a15

SELECT DISTINCT host
FROM
  ( SELECT SUBSTR(host, 1, INSTR(host, ')')-1) AS host
    FROM
      ( SELECT 
          -- CASE WHEN line LIKE '%HOST=%' THEN SUBSTR(line, INSTR(line, 'HOST=', -1, 1)+5) END host
          SUBSTR(line, INSTR(line, 'HOST=', -1, 1)+5) AS host
        FROM listener_log_xml
        WHERE line LIKE '%establish%'
      )
  )
ORDER BY 1
/

-- 
-- The following demo is a detailed operation steps on a specific production system of oracle database.
-- 
-- BTW due to security reason I deliberately hidden my real IP Address and db_name 
-- on version 11.2.0.4.0 of my oracle Production System.
-- 
-- SYS@xxxx> create or replace directory LISTENER_LOG_XML as '/u01/app/oracle/diag/tnslsnr/xxxx/listener/alert';
-- 
-- Directory created.
-- 
-- SYS@xxxx> drop table listener_log_xml;
-- drop table listener_log_xml
--            *
-- ERROR at line 1:
-- ORA-00942: table or view does not exist
-- 
-- SYS@xxxx> create table listener_log_xml (line varchar2(4000))
--   2  organization external (
--   3    type oracle_loader
--   4    default directory LISTENER_LOG_XML
--   5    access parameters (
--   6      records delimited by newline
--   7      nobadfile
--   8      nologfile
--   9      nodiscardfile
--  10      fields ldrtrim
--  11      missing field values are null
--  12      reject rows with all null fields
--  13      ( 
--  14        line char(4000)
--  15      )
--  16    )
--  17    location ('log.xml')
--  18  )
--  19  reject limit unlimited
--  20  /
-- 
-- Table created.
-- 
-- SYS@xxxx> set long 999999999
-- SYS@xxxx> set pagesize 80
-- SYS@xxxx> select line from listener_log_xml where rownum <= 18
-- /
-- 
-- LINE
-- --------------------------------------------------------------------------------
-- <msg time='2019-08-14T10:26:27.507+08:00' org_id='oracle' comp_id='tnslsnr'
--  type='UNKNOWN' level='16' host_id='xxxx'
--  host_addr='xxx.xxx.xxx.xxx' version='1'>
--  <txt>14-AUG-2019 10:26:27 * (CONNECT_DATA=(CID=(PROGRAM=)(HOST=__jdbc__)(USER=r
-- oot))(SERVICE_NAME=xxxx)(CID=(PROGRAM=)(HOST=__jdbc__)(USER=root))) * (ADDRESS
-- =(PROTOCOL=tcp)(HOST=xxx.xxx.xxx.xxx)(PORT=33953)) * establish * xxxx * 0
-- 
--  </txt>
-- </msg>
-- <msg time='2019-08-14T10:26:27.549+08:00' org_id='oracle' comp_id='tnslsnr'
--  type='UNKNOWN' level='16' host_id='xxxx'
--  host_addr='xxx.xxx.xxx.xxx'>
--  <txt>14-AUG-2019 10:26:27 * (CONNECT_DATA=(CID=(PROGRAM=)(HOST=__jdbc__)(USER=r
-- oot))(SERVICE_NAME=xxxx)(CID=(PROGRAM=)(HOST=__jdbc__)(USER=root))) * (ADDRESS
-- =(PROTOCOL=tcp)(HOST=xxx.xxx.xxx.xxx)(PORT=33954)) * establish * xxxx * 0
-- 
--  </txt>
-- </msg>
-- <msg time='2019-08-14T10:26:27.553+08:00' org_id='oracle' comp_id='tnslsnr'
--  type='UNKNOWN' level='16' host_id='xxxx'
--  host_addr='xxx.xxx.xxx.xxx'>
--  <txt>14-AUG-2019 10:26:27 * (CONNECT_DATA=(CID=(PROGRAM=)(HOST=__jdbc__)(USER=r
-- oot))(SERVICE_NAME=xxxx)(CID=(PROGRAM=)(HOST=__jdbc__)(USER=root))) * (ADDRESS
-- =(PROTOCOL=tcp)(HOST=xxx.xxx.xxx.xxx)(PORT=47094)) * establish * xxxx * 0
-- 
--  </txt>
-- </msg>
-- 
-- 18 rows selected.
-- 
-- SYS@xxxx> set pagesize 200
-- SYS@xxxx> col host for a15
-- SYS@xxxx> select distinct host
--   2  from
--   3    ( select substr(host, 1, instr(host, ')')-1) as host
--   4      from
--   5        ( select
--   6            -- case when line like '%HOST=%' then substr(line, instr(line, 'HOST=', -1, 1)+5) end host
--   7            substr(line, instr(line, 'HOST=', -1, 1)+5) as host
--   8          from listener_log_xml
--   9          where line like '%establish%'
--  10        )
--  11    )
--  12  order by 1  
--  13  /
-- 
-- HOST
-- ---------------
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- xxx.xxx.xxx.xxx
-- 
-- 114 rows selected.
