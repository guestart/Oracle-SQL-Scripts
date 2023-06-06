REM
REM     Script:        dg_param_configuration.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Nov 18, 2022
REM
REM     Last tested:
REM             11.2.0.4
REM             12.2.0.1
REM             19.3.0.0
REM
REM     Purpose:
REM       Checking the parameter configuration on oracle data guard primary and physical standby database.
REM

set linesize 200
set pagesize 20
col key for a25
col value for a90
select inst_id,
       name,
       value
from gv$parameter
where name = 'log_archive_config'
union all
select inst_id,
       name,
       value
from gv$parameter
where name like '%log_archive_dest_%'
and name not like '%log_archive_dest_state%'
and value is not null;

-- or

set linesize 200
set pagesize 20
col name for a25
col value for a90
with dg_par as
(select name, value from v$parameter where name in ('log_archive_config', 'fal_server', 'fal_client', 'standby_file_management', 'db_file_name_convert', 'log_file_name_convert')),
ladN as
(select name, value from v$parameter where (name like 'log_archive_dest__' or name like 'log_archive_dest___') and value is not null),
ladsN as
(select name, value from v$parameter where name like 'log_archive_dest_state_%' and substr(name, 24) in (select substr(ladN.name, 18) from ladN))
select * from dg_par
union all
select * from ladN
union all
select * from ladsN
order by 1;
