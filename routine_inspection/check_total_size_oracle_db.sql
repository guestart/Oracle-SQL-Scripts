-- Check total sizes of oracle database

SELECT
(SELECT SUM(bytes)/POWER(2, 30) AS data_size FROM dba_data_files)
+
(SELECT NVL(SUM(bytes), 0)/POWER(2, 30) AS temp_size FROM dba_temp_files)
+
(SELECT SUM(bytes)/POWER(2, 30) AS redo_size FROM sys.v$log)
+
(SELECT SUM(BLOCK_SIZE * FILE_SIZE_BLKS)/POWER(2, 30) AS controlfile_size FROM v$controlfile) AS "Size in GB"
FROM
dual
/
