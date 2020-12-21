REM
REM     Script:        database_scn.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Dec 21, 2020
REM
REM     Last tested:
REM             11.2.0.4
REM             19.3.0.0
REM
REM     Purpose:
REM       This SQL script uses to check SCN number of oracle database (via joining two number of oracle 
REM       dynamic performance view v$datafile and v$datafile_header).
REM

SET PAGESIZE 50

COLUMN df_cc  FORMAT 99999999999999
COLUMN dfh_cc FORMAT 99999999999999

SELECT  df.file# AS df_file
      , df.checkpoint_change# AS df_cc
      , dfh.file# AS dfh_file
      , dfh.checkpoint_change# AS dfh_cc
FROM    v$datafile df
      , v$datafile_header dfh
WHERE   df.file# = dfh.file#;

-- Give an example for checking the SCN number of oracle database.

   DF_FILE           DF_CC   DFH_FILE          DFH_CC
---------- --------------- ---------- ---------------
         1     21973307002          1     21973307002
         2     21973307002          2     21973307002
         3     21973307002          3     21973307002
         4     21973307002          4     21973307002
         5     21973307002          5     21973307002
         6     21973307002          6     21973307002
         7     21973307002          7     21973307002
         8     21973307002          8     21973307002
         9     21973307002          9     21973307002
        10     21973307002         10     21973307002
        11     21973307002         11     21973307002
        12     21973307002         12     21973307002
        13     21973307002         13     21973307002
        14     21973307002         14     21973307002
        15     21973307002         15     21973307002
        16     21973307002         16     21973307002
        17     21973307002         17     21973307002
        18     21973307002         18     21973307002
        19     21973307002         19     21973307002
        20     21973307002         20     21973307002
        21     21973307002         21     21973307002
        22     21973307002         22     21973307002
        23     21973307002         23     21973307002
        24     21973307002         24     21973307002
        25     21973307002         25     21973307002
        26     21973307002         26     21973307002
        27     21973307002         27     21973307002
        28     21973307002         28     21973307002
        29     21973307002         29     21973307002
        30     21973307002         30     21973307002
        31     21973307002         31     21973307002
        32     21973307002         32     21973307002
        33     21973307002         33     21973307002

33 rows selected.
