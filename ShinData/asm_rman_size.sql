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

set linesize 400
set pagesize 40
col handle for a115
break on report
compute sum of size_gb on report
select handle, round(bytes/1024/1024/1024, 2) size_gb from v$backup_piece order by 1;

HANDLE                                                                                                                 SIZE_GB
------------------------------------------------------------------------------------------------------------------- ----------
+DATA/ENSRACDB/BACKUPSET/2023_02_26/annnf0_tag20230226t105912_0.300.1129805973                                            1.59
+DATA/ENSRACDB/BACKUPSET/2023_02_26/annnf0_tag20230226t105912_0.315.1129806459                                            1.36
+DATA/ENSRACDB/BACKUPSET/2023_02_26/annnf0_tag20230226t105912_0.316.1129806185                                            1.41
+DATA/ENSRACDB/BACKUPSET/2023_02_26/annnf0_tag20230226t105912_0.319.1129806037                                            1.57
+DATA/ENSRACDB/BACKUPSET/2023_02_26/annnf0_tag20230226t114146_0.303.1129808507                                             .01
+DATA/ENSRACDB/BACKUPSET/2023_02_26/annnf0_tag20230226t114146_0.307.1129808509                                             .01
+DATA/ENSRACDB/BACKUPSET/2023_02_26/ncnnn0_tag20230226t112357_0.320.1129808487                                             .02
+DATA/ENSRACDB/BACKUPSET/2023_02_26/nnndn0_tag20230226t112357_0.329.1129807463                                             .92
+DATA/ENSRACDB/BACKUPSET/2023_02_26/nnndn0_tag20230226t112357_0.330.1129807521                                               0
+DATA/ENSRACDB/BACKUPSET/2023_02_26/nnndn0_tag20230226t112357_0.332.1129807449                                            1.86
+DATA/ENSRACDB/F406EC7DD60E08A4E053B501A8C0E830/BACKUPSET/2023_02_26/nnndn0_tag20230226t112357_0.322.1129808441            .17
+DATA/ENSRACDB/F406EC7DD60E08A4E053B501A8C0E830/BACKUPSET/2023_02_26/nnndn0_tag20230226t112357_0.326.1129808229            .31
+DATA/ENSRACDB/F406EC7DD60E08A4E053B501A8C0E830/BACKUPSET/2023_02_26/nnndn0_tag20230226t112357_0.328.1129808039            .33
+DATA/ENSRACDB/F4076752F3358672E053B501A8C09E32/BACKUPSET/2023_02_26/nnndn0_tag20230226t112357_0.323.1129808429            .03
+DATA/ENSRACDB/F4076752F3358672E053B501A8C09E32/BACKUPSET/2023_02_26/nnndn0_tag20230226t112357_0.325.1129808213            .32
+DATA/ENSRACDB/F4076752F3358672E053B501A8C09E32/BACKUPSET/2023_02_26/nnndn0_tag20230226t112357_0.327.1129807597            .38
+DATA/c-935108157-20230226-00                                                                                              .02
                                                                                                                    ----------
sum                                                                                                                      10.31

17 rows selected.

[grid@ensrac01 ~]$ asmcmd
ASMCMD> 
ASMCMD> cd data
ASMCMD> 
ASMCMD> pwd
+data
ASMCMD> 
ASMCMD> ls
ENSRACDB/
c-935108157-20230226-00
ASMCMD> 
ASMCMD> ls -sh
Block_Size  Blocks     Bytes     Space  Name
                                        ENSRACDB/
       16K    1212     18.9M       19M  c-935108157-20230226-00 => +DATA/ENSRACDB/AUTOBACKUP/2023_02_26/s_1129808523.305.1129808533
ASMCMD> 

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
