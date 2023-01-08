REM
REM     Script:        dg_gap_status.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Nov 24, 2022
REM
REM     Last tested:
REM             11.2.0.4
REM             12.2.0.1
REM             19.3.0.0
REM
REM     Purpose:
REM       Checking the gap status on oracle data guard primary database.
REM

set linesize 200

col db_unique_name for a15
col dest_name      for a20
col gap_status     for a18

WITH primary AS (
SELECT thread#, MAX(sequence#) maxsequence
FROM v$archived_log
WHERE archived = 'YES'
AND resetlogs_change# = (SELECT d.resetlogs_change# FROM v$database d)
GROUP BY thread#
ORDER BY thread#),
standby AS (
SELECT thread#, MAX(sequence#) maxsequence
FROM v$archived_log
WHERE applied = 'YES'
AND resetlogs_change# = (SELECT d.resetlogs_change# FROM v$database d)
GROUP BY thread#
ORDER BY thread#),
no_applied_seq AS (
SELECT primary.thread#,
       primary.maxsequence pry_arch_logseq,
       NVL(standby.maxsequence, 0) stby_apply_logseq,
       primary.maxsequence - NVL(standby.maxsequence, 0) no_applied_log
FROM  primary, standby
WHERE primary.thread# = standby.thread#(+)
),
gap_info AS (
SELECT inst_id,
       db_unique_name,
       dest_id,
       dest_name,
       status,
       gap_status
FROM gv$archive_dest_status
WHERE status = 'VALID'
AND type = 'PHYSICAL')
SELECT gi.inst_id,
       gi.db_unique_name,
       gi.dest_name,
       gi.status,
       gi.gap_status trans_gap,
       nas.pry_arch_logseq primary_seq,
       nas.stby_apply_logseq standby_seq,
       nas.no_applied_log applied_gap
FROM no_applied_seq nas, gap_info gi
WHERE nas.thread# = gi.inst_id
ORDER BY gi.inst_id;
