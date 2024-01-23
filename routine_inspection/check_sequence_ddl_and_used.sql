REM
REM     Script:        check_sequence_ddl_and_used.sql
REM     Author:        Quanwen Zhao
REM     Dated:         JAN 24, 2024
REM
REM     Last tested:
REM             11.2.0.4
REM             19.13.0.0
REM
REM     Purpose:
REM       This sql script uses to check the define/used situation for the specific sequence of the specific production user by dba_sequences.
REM

-- checking the define situation of the sequences.

set long 999999999
set pagesize 0
set heading off
set feedback off
execute dbms_metadata.set_transform_param(dbms_metadata.session_transform, 'STORAGE', false);
select dbms_metadata.get_ddl('SEQUENCE', upper('&seq_name'), upper('&owner')) from dual;

-- checking the used situation of the sequences currently.

set linesize 400
set pagesize 400
col sequence_name for a35
col min_value for 999,999,999,999,999
col max_value for 999,999,999,999,999
col cycle_flag for a10
col order_flag for a10
select sequence_name,
       min_value,
       max_value,
       last_number,
       round(last_number/max_value, 2) used_perc,
       increment_by,
       cycle_flag,
       order_flag,
       cache_size
from dba_sequences
where sequence_owner = upper('&seq_owner')
and sequence_name = upper('&seq_name');
