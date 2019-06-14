-- -----------------------------------------------------------------
--
--  FileName    : check_dg_redo_apply.sql
--
--  Description : This sql script used to check redo data apply on
--
--                Oracle DataGuard physical standby database.
--
--  Author      : Quanwen Zhao
--
--  Create Date : 2017/07/11
--
-- -----------------------------------------------------------------

SET heading      ON
SET trimspool    ON
SET newpage      NONE
SET echo         OFF
SET feedback     OFF
SET verify       OFF
SET define       OFF
SET termout      OFF
SET timing       OFF
SET colsep       "|"

SET linesize 400
SET pagesize 200

----------------------------------------------------------------
 -- Query value of current date oracle physical standby database
----------------------------------------------------------------

COL current_scn FOR 9999999999999999

SELECT scn_to_timestamp(current_scn) FROM v$database;

PROMPT

---------------------------------------------------------------------------------
 -- Query max value of sequence# and applied's status is yes by 'v$archived_log'
---------------------------------------------------------------------------------

SELECT MAX(sequence#) FROM v$archived_log WHERE applied='YES';

PROMPT

--------------------------------------------------------------------------------
 -- Query max value of sequence# and applied's status is no by 'v$archived_log'
--------------------------------------------------------------------------------

SELECT MAX(sequence#) FROM v$archived_log WHERE applied='NO';

PROMPT

----------------------------------------------------------------------------
 -- Query value of 'process','pid','status' and etc. by 'v$managed_standby'
----------------------------------------------------------------------------

SELECT process,pid,status,sequence#,block#,blocks,delay_mins FROM v$managed_standby;

PROMPT

----------------------------------------------------------------------
 -- Query value of 'sequence#','status','archived' by 'v$standby_log'
----------------------------------------------------------------------

SELECT sequence#,status,archived FROM v$standby_log;

PROMPT

-------------------------------------------
 -- Query all value by 'v$dataguard_stats'
-------------------------------------------

COL name          FOR  a24
COL value         FOR  a12
COL unit          FOR  a28
COL time_computed FOR  a20
COL datum_time    FOR  a20

SELECT * FROM v$dataguard_stats;
