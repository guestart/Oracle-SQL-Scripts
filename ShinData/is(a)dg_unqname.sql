REM
REM     Script:        is(a)dg_unqname.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Nov 18, 2022
REM
REM     Last tested:
REM             11.2.0.4
REM             12.2.0.1
REM             19.3.0.0
REM
REM     Purpose:
REM       Checking "IsDG", "IsADG", "DG Primary Uname" and "DG Physical standby Uname" on oracle data guard primary database.
REM

set linesize 200
set pagesize 20
col key   for a25
col value for a25

with dgpry as
(select 'DG Primary Uname' key,
        value
 from v$parameter where name = 'db_unique_name'
),
dgstby as
(select 'DG Physical standby Uname' key,
        db_unique_name value
 from v$archive_dest
 where target = 'STANDBY'
),
listagg_dgstby as
(select key,
        listagg(value, ',') within group(order by value) value
 from dgstby
 group by key
),
isdg as
(select 'IsDG' key,
        (case when (select value from listagg_dgstby) is not null then 'yes'
              when (select value from listagg_dgstby) is null     then 'no'
         end
        ) value
 from dual
),
isadg as
(select distinct 'IsADG' key,
        decode(database_mode, 'MOUNTED-STANDBY', 'no', 'OPEN_READ-ONLY', 'yes') value
 from v$archive_dest_status
 where type = 'PHYSICAL'
 and lower(db_unique_name) in (select lower(db_unique_name) from v$archive_dest where target = 'STANDBY')
)
select * from isdg
union all
select * from isadg
union all
select * from dgpry
union all
select * from listagg_dgstby;

KEY                       VALUE
------------------------- -------------------------
IsDG                      yes
IsADG                     no
DG Primary Uname          yydsdb
DG Physical standby Uname yydsdbdg07
