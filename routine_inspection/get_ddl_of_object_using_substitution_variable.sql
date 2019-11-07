REM
REM     Script:        get_ddl_of_object_using_substitution_variable.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Nov 05, 2019
REM     Updated:       Nov 06, 2019
REM       (1) Adding "SET VERIFY OFF" to avoid showing like this prompt messages
REM           "old   1: SELECT DBMS_METADATA.get_ddl(UPPER('&object_type'), UPPER('&object_name'), UPPER('&owner_name')) FROM dual
REM            new   1: SELECT DBMS_METADATA.get_ddl(UPPER('view'), UPPER('sm$ts_free'), UPPER('sys')) FROM dual"
REM           when I finish inputting the 3 substitution variables;
REM       (2) Meantime replacing all of like this prompt messages 
REM           "old   1: SELECT DBMS_METADATA.get_ddl(UPPER('&object_type'), UPPER('&object_name'), UPPER('&owner_name')) FROM dual
REM            new   1: SELECT DBMS_METADATA.get_ddl(UPPER('view'), UPPER('sm$ts_free'), UPPER('sys')) FROM dual"
REM            on my demo which I give at the end of this SQL script.
REM
REM     Purpose:
REM       This SQL script usually uses to get DDL statement of an object (such as TABLE, INDEX, SEQUENCE,
REM       VIEW, FUNCTION and PROCEDURE) via using substitution variable of SQL*Plus on Oracle Database.
REM

SET VERIFY   OFF
SET LONG     1000000000
SET LINESIZE 200
SET PAGESIZE 200

PROMPT =====================
PROMPT running on SYS schema
PROMPT =====================

SELECT DBMS_METADATA.get_ddl(UPPER('&object_type'), UPPER('&object_name'), UPPER('&owner_name')) FROM dual
/

-- The following are several demo which here I give.

-- SELECT DBMS_METADATA.get_ddl(UPPER('&object_type'), UPPER('&object_name'), UPPER('&owner_name')) FROM dual
-- /
-- Enter value for object_type: view
-- Enter value for object_name: sm$ts_avail
-- Enter value for owner_name: sys
-- 
-- DBMS_METADATA.GET_DDL(UPPER('VIEW'),UPPER('SM$TS_AVAIL'),UPPER('SYS'))
-- --------------------------------------------------------------------------------
-- 
--   CREATE OR REPLACE FORCE VIEW "SYS"."SM$TS_AVAIL" ("TABLESPACE_NAME", "BYTES") AS
--   select tablespace_name, sum(bytes) bytes from dba_data_files
--     group by tablespace_name
-- 
-- SELECT DBMS_METADATA.get_ddl(UPPER('&object_type'), UPPER('&object_name'), UPPER('&owner_name')) FROM dual
-- /
-- Enter value for object_type: view
-- Enter value for object_name: sm$ts_used
-- Enter value for owner_name: sys
-- 
-- DBMS_METADATA.GET_DDL(UPPER('VIEW'),UPPER('SM$TS_USED'),UPPER('SYS'))
-- --------------------------------------------------------------------------------
-- 
--   CREATE OR REPLACE FORCE VIEW "SYS"."SM$TS_USED" ("TABLESPACE_NAME", "BYTES") AS
--   select tablespace_name, sum(bytes) bytes from dba_segments
--     group by tablespace_name
-- 
-- SELECT DBMS_METADATA.get_ddl(UPPER('&object_type'), UPPER('&object_name'), UPPER('&owner_name')) FROM dual
-- /
-- Enter value for object_type: view
-- Enter value for object_name: sm$ts_free
-- Enter value for owner_name: sys
-- 
-- DBMS_METADATA.GET_DDL(UPPER('VIEW'),UPPER('SM$TS_FREE'),UPPER('SYS'))
-- --------------------------------------------------------------------------------
-- 
--   CREATE OR REPLACE FORCE VIEW "SYS"."SM$TS_FREE" ("TABLESPACE_NAME", "BYTES") AS
--   select tablespace_name, sum(bytes) bytes from dba_free_space
--     group by tablespace_name
-- 
-- SELECT DBMS_METADATA.get_ddl(UPPER('&object_type'), UPPER('&object_name'), UPPER('&owner_name')) FROM dual
-- /
-- Enter value for object_type: view
-- Enter value for object_name: dba_temp_free_space
-- Enter value for owner_name: sys
-- 
-- DBMS_METADATA.GET_DDL(UPPER('VIEW'),UPPER('DBA_TEMP_FREE_SPACE'),UPPER('SYS'))
-- --------------------------------------------------------------------------------
-- 
--   CREATE OR REPLACE FORCE VIEW "SYS"."DBA_TEMP_FREE_SPACE" ("TABLESPACE_NAME", "TABLESPACE_SIZE", "ALLOCATED_SPACE", "F
-- REE_SPACE") AS
--   SELECT tsh.tablespace_name,
--          tsh.total_bytes/tsh.inst_count,
--          tsh.bytes_used/tsh.inst_count,
--          (tsh.bytes_free/tsh.inst_count) + (nvl(ss.free_blocks, 0) * ts$.blocksize)
--     FROM (SELECT tablespace_name, sum(bytes_used + bytes_free) total_bytes,
--                  sum(bytes_used) bytes_used, sum(bytes_free) bytes_free,
--                  count(distinct inst_id) inst_count
--             FROM gv$temp_space_header
--             GROUP BY tablespace_name) tsh,
--          (SELECT tablespace_name, sum(free_blocks) free_blocks
--             FROM gv$sort_segment
--             GROUP BY tablespace_name) ss,
--          ts$
--     WHERE ts$.name = tsh.tablespace_name and
--           tsh.tablespace_name = ss.tablespace_name (+)
-- 
-- SELECT DBMS_METADATA.get_ddl(UPPER('&object_type'), UPPER('&object_name'), UPPER('&owner_name')) FROM dual
-- /
-- Enter value for object_type: view
-- Enter value for object_name: dba_free_space
-- Enter value for owner_name: sys
-- 
-- DBMS_METADATA.GET_DDL(UPPER('VIEW'),UPPER('DBA_FREE_SPACE'),UPPER('SYS'))
-- --------------------------------------------------------------------------------
-- 
--   CREATE OR REPLACE FORCE VIEW "SYS"."DBA_FREE_SPACE" ("TABLESPACE_NAME", "FILE_ID", "BLOCK_ID", "BYTES", "BLOCKS", "RE
-- LATIVE_FNO") AS
--   select ts.name, fi.file#, f.block#,
--        f.length * ts.blocksize, f.length, f.file#
-- from sys.ts$ ts, sys.fet$ f, sys.file$ fi
-- where ts.ts# = f.ts#
--   and f.ts# = fi.ts#
--   and f.file# = fi.relfile#
--   and ts.bitmapped = 0
-- union all
-- select
--        ts.name, fi.file#, f.ktfbfebno,
--        f.ktfbfeblks * ts.blocksize, f.ktfbfeblks, f.ktfbfefno
-- from sys.ts$ ts, sys.x$ktfbfe f, sys.file$ fi
-- where ts.ts# = f.ktfbfetsn
--   and f.ktfbfetsn = fi.ts#
--   and f.ktfbfefno = fi.relfile#
--   and ts.bitmapped <> 0 and ts.online$ in (1,4) and ts.contents$ = 0
-- union all
-- select
--        ts.name, fi.file#, u.ktfbuebno,
--        u.ktfbueblks * ts.blocksize, u.ktfbueblks, u.ktfbuefno
-- from sys.recyclebin$ rb, sys.ts$ ts, sys.x$ktfbue u, sys.file$ fi
-- where ts.ts# = rb.ts#
--   and rb.ts# = fi.ts#
--   and u.ktfbuefno = fi.relfile#
--   and u.ktfbuesegtsn = rb.ts#
--   and u.ktfbuesegfno = rb.file#
--   and u.ktfbuesegbno = rb.block#
--   and ts.bitmapped <> 0 and ts.online$ in (1,4) and ts.contents$ = 0
-- union all
-- select ts.name, fi.file#, u.block#,
--        u.length * ts.blocksize, u.length, u.file#
-- from sys.ts$ ts, sys.uet$ u, sys.file$ fi, sys.recyclebin$ rb
-- where ts.ts# = u.ts#
--   and u.ts# = fi.ts#
--   and u.segfile# = fi.relfile#
--   and u.ts# = rb.ts#
--   and u.segfile# = rb.file#
--   and u.segblock# = rb.block#
--   and ts.bitmapped = 0
