REM
REM     Script:        minus_inline_external_table.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Apr 10, 2021
REM
REM     Last tested:
REM             20.2.0.0.0 -- Preview version in the Oracle Public Cloud
REM
REM     Purpose:
REM       This SQL script uses to compare the entries between two log files.
REM       Firstly I create two separate inline external tables for those two log  files
REM       secondly I use the SQL Set opertor "minus" to compare those two inline external
REM       tables for finding out the different entries.
REM       By the way I have downloaded two log files from here:
REM       https://github.com/guestart/A-demo-with-secure-copying-RMAN-EXP-DP-backup-files-to-another-server/tree/main/tmp_log_files
REM       and saved them to the directory "/tmp" of my oracle 20c test database server.
REM

ALTER USER c##qwz IDENTIFIED BY "DB20ctest!@#";

GRANT create any directory TO c##qwz;

CONN c##qwz/"DB20ctest!@#";

CREATE OR REPLACE DIRECTORY ext_tmp AS '/tmp';

SET LINESIZE 150
SET PAGESIZE 100

SELECT * FROM external (
(
  file_loc varchar2(65)
)
  DEFAULT DIRECTORY ext_tmp
  LOCATION ( 'tmp_20210403033001_local_all.log' )
);

SELECT * FROM external (
(
  file_loc varchar2(65)
)
  DEFAULT DIRECTORY ext_tmp
  LOCATION ( 'tmp_20210403033001_remote_all.log' )
);

SELECT * FROM external (
(
  file_loc varchar2(65)
)
  DEFAULT DIRECTORY ext_tmp
  LOCATION ( 'tmp_20210403033001_remote_all.log' )
)
MINUS
SELECT * FROM external (
(
  file_loc varchar2(65)
)
  DEFAULT DIRECTORY ext_tmp
  LOCATION ( 'tmp_20210403033001_local_all.log' )
);

-- The following is the returned outcome.
-- 
-- FILE_LOC
-- -----------------------------------------------------------------
-- 2021-04-02/DATA_level0_PRODB1_3626_10_havram0u.bak
-- 2021-04-02/DATA_level0_PRODB1_3626_11_havram0u.bak
-- 2021-04-02/DATA_level0_PRODB1_3626_12_havram0u.bak
-- 2021-04-02/DATA_level0_PRODB1_3626_13_havram0u.bak
-- 2021-04-02/DATA_level0_PRODB1_3626_1_havram0u.bak
-- 2021-04-02/DATA_level0_PRODB1_3626_2_havram0u.bak
-- 2021-04-02/DATA_level0_PRODB1_3626_3_havram0u.bak
-- 2021-04-02/DATA_level0_PRODB1_3626_4_havram0u.bak
-- 2021-04-02/DATA_level0_PRODB1_3626_5_havram0u.bak
-- 2021-04-02/DATA_level0_PRODB1_3626_6_havram0u.bak
-- 2021-04-02/DATA_level0_PRODB1_3626_7_havram0u.bak
-- 2021-04-02/DATA_level0_PRODB1_3626_8_havram0u.bak
-- 2021-04-02/DATA_level0_PRODB1_3626_9_havram0u.bak
-- 2021-04-02/DATA_level0_PRODB1_3627_1_hbvram0u.bak
-- 2021-04-02/DATA_level0_PRODB1_3627_2_hbvram0u.bak
-- 2021-04-02/DATA_level0_PRODB1_3627_3_hbvram0u.bak
-- 2021-04-02/DATA_level0_PRODB1_3627_4_hbvram0u.bak
-- 2021-04-02/DATA_level0_PRODB1_3627_5_hbvram0u.bak
-- 2021-04-02/DATA_level0_PRODB1_3627_6_hbvram0u.bak
-- 2021-04-02/DATA_level0_PRODB1_3627_7_hbvram0u.bak
-- 2021-04-02/DATA_level0_PRODB1_3628_1_hcvram0u.bak
-- 2021-04-02/DATA_level0_PRODB1_3628_2_hcvram0u.bak
-- 2021-04-02/DATA_level0_PRODB1_3628_3_hcvram0u.bak
-- 2021-04-02/DATA_level0_PRODB1_3628_4_hcvram0u.bak
-- 2021-04-02/DATA_level0_PRODB1_3628_5_hcvram0u.bak
-- 2021-04-02/DATA_level0_PRODB1_3628_6_hcvram0u.bak
-- 2021-04-02/DATA_level0_PRODB1_3628_7_hcvram0u.bak
-- 2021-04-02/DATA_level0_PRODB1_3628_8_hcvram0u.bak
-- 2021-04-02/DATA_level0_PRODB1_3629_10_hdvram0u.bak
-- 2021-04-02/DATA_level0_PRODB1_3629_11_hdvram0u.bak
-- 2021-04-02/DATA_level0_PRODB1_3629_1_hdvram0u.bak
-- 2021-04-02/DATA_level0_PRODB1_3629_2_hdvram0u.bak
-- 2021-04-02/DATA_level0_PRODB1_3629_3_hdvram0u.bak
-- 2021-04-02/DATA_level0_PRODB1_3629_4_hdvram0u.bak
-- 2021-04-02/DATA_level0_PRODB1_3629_5_hdvram0u.bak
-- 2021-04-02/DATA_level0_PRODB1_3629_6_hdvram0u.bak
-- 2021-04-02/DATA_level0_PRODB1_3629_7_hdvram0u.bak
-- 2021-04-02/DATA_level0_PRODB1_3629_8_hdvram0u.bak
-- 2021-04-02/DATA_level0_PRODB1_3629_9_hdvram0u.bak
-- 2021-04-02/DATA_level0_PRODB2_27330_1_m2vralv4.bak
-- 2021-04-02/DATA_level0_PRODB2_27330_2_m2vralv4.bak
-- 2021-04-02/DATA_level0_PRODB2_27330_3_m2vralv4.bak
-- 2021-04-02/DATA_level0_PRODB2_27330_4_m2vralv4.bak
-- 2021-04-02/DATA_level0_PRODB2_27330_5_m2vralv4.bak
-- 2021-04-02/DATA_level0_PRODB2_27330_6_m2vralv4.bak
-- 2021-04-02/DATA_level0_PRODB2_27330_7_m2vralv4.bak
-- 2021-04-02/DATA_level0_PRODB2_27330_8_m2vralv4.bak
-- 2021-04-02/DATA_level0_PRODB2_27331_1_m3vralv4.bak
-- 2021-04-02/DATA_level0_PRODB2_27331_2_m3vralv4.bak
-- 2021-04-02/DATA_level0_PRODB2_27331_3_m3vralv4.bak
-- 2021-04-02/DATA_level0_PRODB2_27331_4_m3vralv4.bak
-- 2021-04-02/DATA_level0_PRODB2_27331_5_m3vralv4.bak
-- 2021-04-02/DATA_level0_PRODB2_27331_6_m3vralv4.bak
-- 2021-04-02/DATA_level0_PRODB2_27331_7_m3vralv4.bak
-- 2021-04-02/DATA_level0_PRODB2_27332_1_m4vralv4.bak
-- 2021-04-02/DATA_level0_PRODB2_27332_2_m4vralv4.bak
-- 2021-04-02/DATA_level0_PRODB2_27332_3_m4vralv4.bak
-- 2021-04-02/DATA_level0_PRODB2_27332_4_m4vralv4.bak
-- 2021-04-02/DATA_level0_PRODB2_27332_5_m4vralv4.bak
-- 2021-04-02/DATA_level0_PRODB2_27332_6_m4vralv4.bak
-- 2021-04-02/DATA_level0_PRODB2_27333_1_m5vralv4.bak
-- 2021-04-02/DATA_level0_PRODB2_27333_2_m5vralv4.bak
-- 2021-04-02/DATA_level0_PRODB2_27333_3_m5vralv4.bak
-- 2021-04-02/DATA_level0_PRODB2_27333_4_m5vralv4.bak
-- 2021-04-02/DATA_level0_PRODB2_27333_5_m5vralv4.bak
-- 2021-04-02/DATA_level0_PRODB2_27333_6_m5vralv4.bak
-- 2021-04-02/archivelog_PRODB1_3631_1_hfvrb0vv.bak
-- 2021-04-02/archivelog_PRODB1_3632_1_hgvrb0vv.bak
-- 2021-04-02/archivelog_PRODB1_3633_1_hhvrb0vv.bak
-- 2021-04-02/archivelog_PRODB1_3634_1_hivrb0vv.bak
-- 2021-04-02/archivelog_PRODB2_27326_1_luvralre.bak
-- 2021-04-02/archivelog_PRODB2_27327_1_lvvralre.bak
-- 2021-04-02/archivelog_PRODB2_27328_1_m0vralre.bak
-- 2021-04-02/archivelog_PRODB2_27329_1_m1vralre.bak
-- 2021-04-02/archivelog_PRODB2_27335_1_m7vras18.bak
-- 2021-04-02/archivelog_PRODB2_27336_1_m8vras18.bak
-- 2021-04-02/archivelog_PRODB2_27337_1_m9vras18.bak
-- 2021-04-02/archivelog_PRODB2_27338_1_mavras18.bak
-- controlfile/c-298590189-20210403-00
-- controlfile/c-3701130036-20210403-00
-- log/prodb1_level0_2021-04-02.log
-- log/prodb1_maintenance_2021-04-02.log
-- log/prodb1_validate_2021-04-02.log
-- log/prodb2_level0_2021-04-02.log
-- log/prodb2_maintenance_2021-04-02.log
-- log/prodb2_validate_2021-04-02.log
-- 
-- 86 rows selected.
