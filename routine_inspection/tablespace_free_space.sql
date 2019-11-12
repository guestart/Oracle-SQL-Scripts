REM
REM     Script:        tablespace_free_space.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Nov 12, 2019
REM
REM     Purpose:
REM       This SQL script usually uses to check the free space of tablespaces (including Data and Temp) on Oracle Database.
REM
REM     Notice:
REM       I just slightly formatted Tom Kyte's this SQL on https://asktom.oracle.com/Misc/free.html.
REM       The comments of every column of this SQL script are as follows:
REM       (1) Tablespace Name: name of tablespace,
REM                            leading '*' indicates a good locally managed tablespace,
REM                            leading blank means it is a bad dictionary managed tablespace.
REM                            Second character of A implies ASSM managed storage,
REM                            second character of M implies manually managed (pctused, freelists, etc are used to control space utilization);
REM       (2) MBytes: allocated space of the tablespace, sum of kbytes consumed by all datafiles associated with tablespace;
REM       (3) Used MBytes: space in the tablespace that is used by some segment;
REM       (4) Free MBytes: space in the tablespace not allocated to any segment;
REM       (5) %Used: ratio of free to allocated space;
REM       (6) LargestMBytes: mostly useful with dictionary managed tablespaces, the size of the largest contigously set of blocks available.
REM                          If this number in a dictionary managed tablespace is smaller than the next extent for some object,
REM                          that object could fail with "out of space" even if the FREE column says there is lots of free space;
REM       (7) MaxPoss MBytes: the autoextend max size (note CAN be smaller than the allocated size!!!!
REM                           you can set the maxsize to be less than the current size of a file);
REM       (8) %Max Used: how much of the maximum autoextend size has been used so far.

SET LINESIZE 200
SET PAGESIZE 200

COLUMN dummy          NOPRINT
COLUMN pct_used       FORMAT 999.9       HEADING "%|Used"
COLUMN name           FORMAT a25         HEADING "Tablespace Name"
COLUMN Mbytes         FORMAT 999,999,999 HEADING "MBytes" 
COLUMN Used_Mbytes    FORMAT 999,999,999 HEADING "Used|MBytes"
COLUMN Free_Mbytes    FORMAT 999,999,999 HEADING "Free|MBytes"
COLUMN Largest_Mbytes FORMAT 999,999,999 HEADING "Largest|MBytes"
COLUMN MAX_Size       FORMAT 999,999,999 HEADING "MaxPoss|MBytes"
COLUMN pct_max_used   FORMAT 999.9       HEADING "%|Max|Used"

BREAK   ON  REPORT
COMPUTE SUM OF Mbytes      ON REPORT 
COMPUTE SUM OF Free_Mbytes ON REPORT 
COMPUTE SUM OF Used_Mbytes ON REPORT 

SELECT ( SELECT DECODE(extent_management,'LOCAL','*',' ') || 
                DECODE(segment_space_management,'AUTO','a ','m ')
	       FROM dba_tablespaces
	       WHERE tablespace_name = b.tablespace_name
	     ) || NVL(b.tablespace_name,NVL(a.tablespace_name,'UNKOWN')) name
	     , Mbytes_alloc Mbytes
	     , Mbytes_alloc-NVL(Mbytes_free,0) Used_Mbytes
	     , NVL(Mbytes_free,0) Free_Mbytes
	     , ((Mbytes_alloc-NVL(Mbytes_free,0))/Mbytes_alloc)*100 pct_used
	     , NVL(Mbytes_largest,0) Largest_Mbytes
	     , NVL(Mbytes_MAX,Mbytes_alloc) MAX_Size
	     , DECODE(Mbytes_MAX,0,0,(Mbytes_alloc/Mbytes_MAX)*100) pct_max_used
FROM ( SELECT SUM(bytes)/1024/1024   Mbytes_free
              , MAX(bytes)/1024/1024 Mbytes_largest
	      , tablespace_name
       FROM  sys.dba_free_space
       GROUP BY tablespace_name
     ) a,
     ( SELECT SUM(bytes)/1024/1024      Mbytes_alloc
	      , SUM(MAXbytes)/1024/1024 Mbytes_max
	      , tablespace_name
       FROM sys.dba_data_files
       GROUP BY tablespace_name
       UNION ALL
       SELECT SUM(bytes)/1024/1024      Mbytes_alloc
	      , SUM(MAXbytes)/1024/1024 Mbytes_max
	      , tablespace_name
       FROM sys.dba_temp_files
       GROUP BY tablespace_name
     ) b
WHERE a.tablespace_name (+) = b.tablespace_name
ORDER BY 1
/

--                                                                                                        %
--                                                Used         Free      %      Largest      MaxPoss    Max
-- Tablespace Name                 MBytes       MBytes       MBytes   Used       MBytes       MBytes   Used
-- ------------------------- ------------ ------------ ------------ ------ ------------ ------------ ------
-- *a SYSAUX                      107,898       56,036       51,862   51.9        3,968       98,304  109.8
-- *a WWW_XXXXXXXXXXX             638,538      506,420      132,118   79.3        3,968      655,360   97.4
-- *a WWW_YYYYYYYYYYY               4,096            1        4,095     .0        3,958       32,768   12.5
-- *a USERS                         2,758        2,626          132   95.2          131       32,768    8.4
-- *m SYSTEM                      139,196          799      138,397     .6        3,968      163,840   85.0
-- *m WWW_XXXXXXXXXXX_TEMP         98,301       98,301            0  100.0            0       65,536  150.0
-- *m WWW_YYYYYYYYYYY_TEMP          1,024        1,024            0  100.0            0       32,768    3.1
-- *m TEMP                         32,767       32,767            0  100.0            0       32,768  100.0
-- *m UNDOTBS1                     25,845        5,019       20,826   19.4        3,968       32,768   78.9
--                           ------------ ------------ ------------
-- sum                          1,050,423      702,994      347,429
-- 
-- 9 rows selected.
