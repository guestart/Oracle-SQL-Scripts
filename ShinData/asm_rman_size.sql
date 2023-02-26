REM
REM     Script:        asm_rman_size.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Feb 26, 2023
REM
REM     Last tested:
REM             11.2.0.4
REM             12.2.0.1
REM             19.3.0.0
REM
REM     Purpose:
REM       Checking rman backupset and autobackup occupied asm disk size and used rate on oracle database.
REM

select substr(handle, 2, instr(handle, '/', 1)-2) as asm_disk_name,
       round(sum(bytes)/1024/1024/1024, 2) as size_gb
from v$backup_piece
where deleted = 'NO'
and handle like '+%'
group by substr(handle, 2, instr(handle, '/', 1)-2);

ASM_DISK_NAME       SIZE_GB
---------------  ----------
DATA                  10.29

with af as
(select group_number,
        redundancy,
        round(sum(space)/1024/1024/1024, 2) used_gb
 from v$asm_file
 where type in ('BACKUPSET', 'AUTOBACKUP')
 group by group_number,
          redundancy
),
bug as
(select af.group_number,
        case af.redundancy
          when 'HIGH'   then af.used_gb/3
          when 'MIRROR' then af.used_gb/2
          when 'UNPROT' then af.used_gb
        end back_used_gb
 from af
)
select ad.name as ASM_DISK_NAME,
       ad.total_mb/1024 as TOTAL_GB,
       bug.back_used_gb as BACK_USED_GB,
       round(bug.back_used_gb/(ad.total_mb/1024), 4)*100 as PERCENT_SPACE_USED
from v$asm_diskgroup ad, af, bug
where ad.group_number = af.group_number
and af.group_number = bug.group_number;

ASM_DISK_NAME                    TOTAL_GB BACK_USED_GB PERCENT_SPACE_USED
------------------------------ ---------- ------------ ------------------
DATA                                  130        10.31               7.93
