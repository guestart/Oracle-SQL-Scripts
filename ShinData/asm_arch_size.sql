REM
REM     Script:        asm_arch_size.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Jan 25, 2023
REM     Updated:       Feb 26, 2023
REM
REM     Last tested:
REM             11.2.0.4
REM             12.2.0.1
REM             19.3.0.0
REM
REM     Purpose:
REM       Checking archive log occupied asm disk size and used rate on oracle database.
REM

with al as
(select substr(name, 2, instr(name, '/', 1)-2) as disk_name,
        round((sum(blocks*block_size)/1024/1024/1024), 2) as arc_used_gb
 from v$archived_log
 where standby_dest = 'NO'
 and deleted = 'NO'
 and name like '+%'
 group by substr(name, 2, instr(name, '/', 1)-2)
),
atg as
(select ad.name,
        al.arc_used_gb,
        case type
          when 'EXTERN' then round(ad.total_mb/1024,   2)
          when 'NORMAL' then round(ad.total_mb/1024/2, 2)
          when 'HIGH'   then round(ad.total_mb/1024/3, 2)
        end act_total_gb
 from v$asm_diskgroup ad, al
 where ad.name = al.disk_name
)
select name as ASM_DISK_NAME,
       arc_used_gb as ARC_USED_GB,
       round(arc_used_gb/act_total_gb, 4)*100 as PERCENT_SPACE_USED
from atg
;

ASM_DISK_NAME                  ARC_USED_GB PERCENT_SPACE_USED
------------------------------ ----------- ------------------
DATA                                 15.85               31.7

with af as
(select group_number,
        case redundancy
          when 'HIGH'   then round(sum(space)/1024/1024/1024, 2)/3
          when 'MIRROR' then round(sum(space)/1024/1024/1024, 2)/2
          when 'UNPROT' then round(sum(space)/1024/1024/1024, 2)
        end act_used_gb,
        round(sum(space)/1024/1024/1024, 2)used_gb
 from v$asm_file
 where type in ('ARCHIVELOG')
 group by group_number,
          case redundancy
            when 'HIGH'   then round(sum(space)/1024/1024/1024, 2)/3
            when 'MIRROR' then round(sum(space)/1024/1024/1024, 2)/2
            when 'UNPROT' then round(sum(space)/1024/1024/1024, 2)
          end
)
select ad.name as ASM_DISK_NAME,
       af.act_used_gb as ARC_USED_GB,
       round(af.used_gb/(ad.total_mb/1024), 4)*100 as PERCENT_SPACE_USED
from v$asm_diskgroup ad, af
where ad.group_number = af.group_number;

when 'HIGH'   then round(sum(space)/1024/1024/1024, 2)/3
                                     *
ERROR at line 13:
ORA-00934: group function is not allowed here


with af as
(select group_number,
        decode(redundancy, 'HIGH', round(sum(space)/1024/1024/1024, 2)/3, 'MIRROR', round(sum(space)/1024/1024/1024, 2)/2, 'UNPROT', round(sum(space)/1024/1024/1024, 2)) act_used_gb,
        round(sum(space)/1024/1024/1024, 2) used_gb
 from v$asm_file
 where type in ('ARCHIVELOG')
 group by group_number,
          decode(redundancy, 'HIGH', round(sum(space)/1024/1024/1024, 2)/3, 'MIRROR', round(sum(space)/1024/1024/1024, 2)/2, 'UNPROT', round(sum(space)/1024/1024/1024, 2))
)
select ad.name as ASM_DISK_NAME,
       af.act_used_gb as ARC_USED_GB,
       round(af.used_gb/(ad.total_mb/1024), 4)*100 as PERCENT_SPACE_USED
from v$asm_diskgroup ad, af
where ad.group_number = af.group_number;

decode(redundancy, 'HIGH', round(sum(space)/1024/1024/1024, 2)/3, 'MIRROR', round(sum(space)/1024/1024/1024, 2)/2, 'UNPROT', round(sum(space)/1024/1024/1024, 2))
                                           *
ERROR at line 8:
ORA-00934: group function is not allowed here

with af as
(select group_number,
        redundancy,
        round(sum(space)/1024/1024/1024, 2) used_gb
 from v$asm_file
 where type in ('ARCHIVELOG')
 group by group_number,
          redundancy
),
aug as
(select af.group_number,
        case af.redundancy
          when 'HIGH'   then af.used_gb/3
          when 'MIRROR' then af.used_gb/2
          when 'UNPROT' then af.used_gb
        end act_used_gb
 from af
)
select ad.name as ASM_DISK_NAME,
       aug.act_used_gb as ARC_USED_GB,
       round(af.used_gb/(ad.total_mb/1024), 4)*100 as PERCENT_SPACE_USED
from v$asm_diskgroup ad, af, aug
where ad.group_number = af.group_number
and af.group_number = aug.group_number;

ASM_DISK_NAME                  ARC_USED_GB PERCENT_SPACE_USED
------------------------------ ----------- ------------------
DATA                                16.045              32.09

with af as
(select group_number,
        redundancy,
        round(sum(space)/1024/1024/1024, 2) used_gb
 from v$asm_file
 where type in ('ARCHIVELOG')
 group by group_number,
          redundancy
),
aug as
(select af.group_number,
        decode(af.redundancy, 'HIGH', af.used_gb/3, 'MIRROR', af.used_gb/2, 'UNPROT', af.used_gb) act_used_gb
 from af
)
select ad.name as ASM_DISK_NAME,
       aug.act_used_gb as ARC_USED_GB,
       round(af.used_gb/(ad.total_mb/1024), 4)*100 as PERCENT_SPACE_USED
from v$asm_diskgroup ad, af, aug
where ad.group_number = af.group_number
and af.group_number = aug.group_number;

ASM_DISK_NAME                  ARC_USED_GB PERCENT_SPACE_USED
------------------------------ ----------- ------------------
DATA                                16.045              32.09
