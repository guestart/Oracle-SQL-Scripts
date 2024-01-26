REM
REM     Script:        check_tab_part_range_situation.sql
REM     Author:        Quanwen Zhao
REM     Dated:         JAN 26, 2024
REM
REM     Last tested:
REM             11.2.0.4
REM             19.13.0.0
REM
REM     Purpose:
REM       This sql script uses to check the situation about partitioning table with range type for the specific production user by dba_part_tables and dba_tab_partitions.
REM

set linesize 400
set pagesize 400
col table_name for a30
col partitioning_type for a20
col partition_name for a20
col high_value for a80
select dpt.table_name,
       dpt.partitioning_type,
       dtp.partition_name,
       dtp.high_value
from dba_part_tables dpt, dba_tab_partitions dtp
where dpt.owner = dtp.table_owner
and dpt.table_name = dtp.table_name
and dpt.partitioning_type = 'RANGE'
and dpt.owner = upper('&owner')
order by 1,3;

-- How To Select Specific Interval Partition With Sysdate? (Doc ID 2325059.1)

with xml as (
  select dbms_xmlgen.getxmltype (
  'select table_name,
          partition_name,
          high_value
   from user_tab_partitions
   where table_name = ''<Table Name>''
  ') as x from dual
)
select extractValue(rws.object_value, '/ROW/TABLE_NAME') table_name,
       extractValue(rws.object_value, '/ROW/PARTITION_NAME') partition,
       extractValue(rws.object_value, '/ROW/HIGH_VALUE') high_value
from xml x,
     table(xmlsequence(extract(x.x, '/ROWSET/ROW'))) rws
ORDER BY extractValue(rws.object_value, '/ROW/HIGH_VALUE');

-- I've created what is suitable to my own according to the preceding MoS solution.

set linesize 400
set pagesize 400
col table_name for a30
col partitioning_type for a20
col partition_name for a20
col high_value for a80

with xml as (
  select dbms_xmlgen.getxmltype (
  'select dpt.table_name,
          dpt.partitioning_type,
          dtp.partition_name,
          dtp.high_value
   from dba_part_tables dpt, dba_tab_partitions dtp
   where dpt.owner = dtp.table_owner
   and dpt.table_name = dtp.table_name
   and dpt.partitioning_type = ''RANGE''  -- two number of single quotations instead of one double quotations in each left and right side
   and dpt.owner = upper(''&owner'')      -- two number of single quotations instead of one double quotations in each left and right side
  ') as x from dual
)
select extractValue(rws.object_value, '/ROW/TABLE_NAME') table_name,
       extractValue(rws.object_value, '/ROW/PARTITIONING_TYPE') partitioning_type,
       extractValue(rws.object_value, '/ROW/PARTITION_NAME') partition,
       extractValue(rws.object_value, '/ROW/HIGH_VALUE') high_value
from xml x,
     table(xmlsequence(extract(x.x, '/ROWSET/ROW'))) rws
ORDER BY extractValue(rws.object_value, '/ROW/TABLE_NAME'),
         extractValue(rws.object_value, '/ROW/HIGH_VALUE');
