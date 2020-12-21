REM
REM     Script:        datafile_header_scn.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Dec 21, 2020
REM
REM     Last tested:
REM             11.2.0.4
REM             19.3.0.0
REM
REM     Purpose:
REM       This SQL script uses to check SCN number (for both the column "checkpoint_change#"
REM       and "resetlogs_change#" via the oracle dynamic performance view v$datafile_header)
REM       of the header of data file.
REM

SET PAGESIZE 50

COLUMN checkpoint_change# FORMAT 99999999999999
COLUMN resetlogs_change#  FORMAT 99999999999999

SELECT file#, checkpoint_change#, resetlogs_change# FROM v$datafile ORDER BY 1;

-- Give an example for checking the SCN number of the header of data file of oracle database.
-- Perhaps you have noticed that the value of checkpoint_change# of each data file is different,
-- hence, they all will need to do recover operation.

     FILE# CHECKPOINT_CHANGE# RESETLOGS_CHANGE#
---------- ------------------ -----------------
         1        21958770996       21941768965
         2        21958776941       21941768965
         3        21958771643       21941768965
         4        21958771647       21941768965
         5        21957599830       21941768965
         6        21957607654       21941768965
         7        21957612336       21941768965
         8        21958771647       21941768965
         9        21957612340       21941768965
        10        21958771647       21941768965
        11        21957581729       21941768965
        12        21957621046       21941768965
        13        21957581733       21941768965
        14        21957581734       21941768965
        15        21958770996       21941768965
        16        21957628386       21941768965
        17        21957639152       21941768965
        18        21957634588       21941768965
        19        21957640705       21941768965
        20        21957643500       21941768965
        21        21957653540       21941768965
        22        21957581748       21941768965
        23        21958727950       21941768965
        24        21958729922       21941768965
        25        21958738488       21941768965
        26        21958743184       21941768965
        27        21958745143       21941768965
        28        21958747079       21941768965
        29        19360995011       21941768965
        30        21958756237       21941768965
        31        21958756477       21941768965
        32        21958757410       21941768965
        33        21958760638       21941768965

33 rows selected.
