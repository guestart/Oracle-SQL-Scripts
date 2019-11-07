REM
REM     Script:        get_dyn_perf_view_def_3.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Nov 07, 2019
REM
REM     Notice:
REM       SQL> desc v$fixed_view_definition
REM             Name                                      Null?    Type
REM             ----------------------------------------- -------- ----------------------------
REM             VIEW_NAME                                          VARCHAR2(30)
REM             VIEW_DEFINITION                                    VARCHAR2(4000)
REM
REM     Purpose:
REM       The 3rd version of SQL script "get_dyn_perf_view_def.sql" - calling SQL Script "get_dyn_perf_view_def_3.sql"
REM       meanwhile passing in argument on Oracle Database.
REM

SET VERIFY   OFF
SET PAGESIZE 400

PROMPT =====================
PROMPT running on SYS schema
PROMPT =====================

SELECT view_definition
  FROM v$fixed_view_definition
 WHERE view_name = UPPER ('&1')
/

-- A simple demo here which I give.
-- 
-- SQL> @get_dyn_perf_view_def_3.sql gv$temp_space_header
-- =====================
-- running on SYS schema
-- =====================
-- 
-- VIEW_DEFINITION
-- --------------------------------------------------------------------------------
-- select  FILE# , CREATION_CHANGE# , CREATION_TIME , TS# , RFILE# , STATUS , ENABL
-- ED , BYTES, BLOCKS, CREATE_BYTES , BLOCK_SIZE , NAME from GV$TEMPFILE where inst
-- _id = USERENV('Instance')
