-- running on oracle data guard primary database:

set linesize 400
set pagesize 1000
col name for a80
select file#, name from v$datafile ordr by 1;
select file#, name from v$tempfile ordr by 1;

set linesize 400
set pagesize 1000
col file_name for a80
select file_id, file_name from dba_data_files order by 1;
select file_id, file_name from dba_temp_files order by 1;

set linesize 400
set pagesize 1000
col substr_datafile for a100
select substr(file_name, instr(file_name, 'DATAFILE')) substr_datafile from dba_data_files;

set linesize 400
set pagesize 1000
col new_df_location_on_stb for a100
select case when instr(file_name, 'DATAFILE') > 0 then Q'[set newname for datafile ]' || file_id || Q'[ to '+X86_DATA01/XXX_STB/]' || substr(file_name, instr(file_name, 'DATAFILE')) || Q'[';]'
            when instr(file_name, 'datafile') > 0 then Q'[set newname for datafile ]' || file_id || Q'[ to '+X86_DATA01/XXX_STB/]' || substr(file_name, instr(file_name, 'datafile')) || Q'[';]'
       end new_df_location_on_stb
from dba_data_files;

set linesize 400
set pagesize 1000
col substr_tempfile for a100
select substr(file_name, instr(file_name, 'TEMPFILE')) substr_tempfile from dba_temp_files;

set linesize 400
set pagesize 1000
col new_tf_location_on_stb for a100
select case when instr(file_name, 'TEMPFILE') > 0 then Q'[set newname for tempfile ]' || file_id || Q'[ to '+X86_DATA01/XXX_STB/]' || substr(file_name, instr(file_name, 'TEMPFILE')) || Q'[';]'
            when instr(file_name, 'tempfile') > 0 then Q'[set newname for tempfile ]' || file_id || Q'[ to '+X86_DATA01/XXX_STB/]' || substr(file_name, instr(file_name, 'tempfile')) || Q'[';]'
       end new_tf_location_on_stb
from dba_temp_files;

-- running on oracle data guard physical standby database:

vi /home/oracle/tmp/restore_XXX.conf
run{
allocate channel ch00 type sbt_tape;
allocate channel ch01 type sbt_tape;
allocate channel ch02 type sbt_tape;
allocate channel ch03 type sbt_tape;
allocate channel ch04 type sbt_tape;
allocate channel ch05 type sbt_tape;
allocate channel ch06 type sbt_tape;
allocate channel ch07 type sbt_tape;
send 'NB_ORA_CLIENT=XXX_db_nbu,NB_ORA_SERV=nbumaster01';
set newname for datafile 1 to '+X86_DATA01/XXX_STB/DATAFILE/system.xxx.xxxxxxxx';
......
set newname for tempfile 1 to '+X86_DATA01/XXX_STB/TEMPFILE/temp.xxx.xxxxxxxx';
restore database;
switch datafile all;
switch tempfile all;
restore channel ch00;
restore channel ch01;
restore channel ch02;
restore channel ch03;
restore channel ch04;
restore channel ch05;
restore channel ch06;
restore channel ch07;
}

vi /home/oracle/tmp/restore_XXX.sh
#!/bin/bash
rman target / nocatalog cmdfile=/home/oracle/tmp/restore_XXX.conf log=/home/oracle/tmp/restore_XXX.log
