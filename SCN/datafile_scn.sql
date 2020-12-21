REM
REM     Script:        datafile_scn.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Dec 21, 2020
REM
REM     Last tested:
REM             11.2.0.4
REM             19.3.0.0
REM
REM     Purpose:
REM       This SQL script uses to check SCN number (in the column "checkpoint_change#" via the oracle 
REM       dynamic performance view v$datafile) of current control file.
REM

SET PAGESIZE 50

COLUMN checkpoint_change# FORMAT 99999999999999
COLUMN resetlogs_change#  FORMAT 99999999999999

SELECT file#, checkpoint_change# FROM v$datafile ORDER BY 1;

-- Give an example for checking the SCN number of current control file of oracle database.

     FILE# CHECKPOINT_CHANGE#
---------- ------------------
         1        21958785029
         2        21958785029
         3        21958785029
         4        21958785029
         5        21958785029
         6        21958785029
         7        21958785029
         8        21958785029
         9        21958785029
        10        21958785029
        11        21958785029
        12        21958785029
        13        21958785029
        14        21958785029
        15        21958785029
        16        21958785029
        17        21958785029
        18        21958785029
        19        21958785029
        20        21958785029
        21        21958785029
        22        21958785029
        23        21958785029
        24        21958785029
        25        21958785029
        26        21958785029
        27        21958785029
        28        21958785029
        29        21958785029
        30        21958785029
        31        21958785029
        32        21958785029
        33        21958785029

33 rows selected.
