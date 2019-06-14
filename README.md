<html>
<h1> Oracle SQL Scripts </h1>
<body>
<h3>ASH:</h3>
<pre>
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/ash/ash_event_count_topN.sql">ash_event_count_topN.sql</a> - View the Top-N event counts from ASH
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/ash/ash_event_count_topN_new.sql">ash_event_count_topN_new.sql</a> - The improved version of "ash_event_count_topN.sql"
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/ash/ash_event_count_topN_2.sql">ash_event_count_topN_2.sql</a> - The improved version of "ash_event_count_topN_new.sql"
</pre>
<h3>Statistics Info:</h3>
<pre>
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/statistics_info/all_tables_stats_on_all_proc_users.sql">all_tables_stats_on_all_proc_users.sql</a> - Check statistics of all of tables from all of production users
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/statistics_info/all_tables_mods_on_all_proc_users.sql">all_tables_mods_on_all_proc_users.sql</a> - Check DML of all of tables from all of production users
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/statistics_info/table_stats_on_proc_user.sql">table_stats_on_proc_user.sql</a> - Only check statistics of table or user which has been appointed
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/statistics_info/table_mods_on_proc_user.sql">table_mods_on_proc_user.sql</a> - Only check modifications of table or user which has been appointed
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/statistics_info/table_column_statistics.sql">table_column_statistics.sql</a> - Check some related statistics of column of table
</pre>
<h3>SQL Tuning:</h3>
<pre>
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/sql_tuning/check_data_dictionary_tables_and_views.sql">check_data_dictionary_tables_and_views.sql</a> - Check data dictionary tables and views of Oracle
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/sql_tuning/check_sql_multiple_execution_plans.sql">check_sql_multiple_execution_plans.sql</a> - Check SQL multiple execution plans
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/sql_tuning/check_sql_multiple_execution_plans_2.sql">check_sql_multiple_execution_plans_2.sql</a> - Check SQL multiple execution plans-2
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/sql_tuning/check_sql_execution_plan_table.sql">check_sql_execution_plan_table.sql</a> - Check the SQL statement's execution plan
</pre>
<h3>Capturing Bad SQL:</h3>
<pre>
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/capturing_bad_sql/buffer_gets_rank_top_5_sql_on_sqlstats.sql">buffer_gets_rank_top_5_sql_on_sqlstats.sql</a> - Ranking Top 5 SQL for buffer_gets (High CPU) on "v$sqlstats" of Oracle
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/capturing_bad_sql/disk_reads_rank_top_5_sql_on_sqlstats.sql">disk_reads_rank_top_5_sql_on_sqlstats.sql</a> - Ranking Top 5 SQL for disk_reads (High I/O) on "v$sqlstats" of Oracle
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/capturing_bad_sql/poor_parsing_applications_rank_top_5_sql_on_sqlstats.sql">poor_parsing_applications_rank_top_5_sql_on_sqlstats.sql</a> - Ranking Top 5 SQL for poor parsing applications (parse_calls/executions) on "v$sqlstats" of Oracle
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/capturing_bad_sql/shared_memory_rank_top_5_sql_on_sqlstats.sql">shared_memory_rank_top_5_sql_on_sqlstats.sql</a> - Ranking Top 5 SQL for shared memory (Memory hogs) on "v$sqlstats" of Oracle
</pre>
<h3> Routine Inspection:</h3>
<pre>
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/routine_inspection/all_prod_user.sql">all_prod_user.sql</a> - Listing all of production users by dba_users (excluding sys related users)
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/routine_inspection/per_machine_act_conn_num_aggr_by_user.sql">per_machine_act_conn_num_aggr_by_user.sql</a> - Showing per machine's active connect numbers after aggregating by username on v$session, meanwhile showing column client_info, that's to say, client's ip address
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/routine_inspection/top_10_segment_on_system_tbs.sql">top_10_segment_on_system_tbs.sql</a> - Showing top 10 segment objects on system tablespace
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/routine_inspection/top_10_segment_on_sysaux_tbs.sql">top_10_segment_on_sysaux_tbs.sql</a> - Showing top 10 segment objects on sysaux tablespace
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/routine_inspection/ctl_file_path_in_rman_backupsets.sql">ctl_file_path_in_rman_backupsets.sql</a> - Listing all of control file's locaiton in rman backupsets
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/routine_inspection/spfile_path_in_rman_backupsets.sql">spfile_path_in_rman_backupsets.sql</a> - Listing all of spfile's locaiton in rman backupsets
</pre>
<h3> Migration Compare:</h3>
<pre>
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/migration_compare/migration_before_and_after_compare.sql">migration_before_and_after_compare.sql</a> - Comparing all of tables' total numbers (before and after migration) on all of production users
</pre>
<h3> PLSQL:</h3>
<pre>
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/plsql/switch_redo_log_for_recycle.sql">switch_redo_log_for_recycle.sql</a> - Switching all of online redo log for a recycle on oracle database
</pre>
</body>
</html>
