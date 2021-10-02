<html>
<h1> Oracle SQL Scripts </h1>
<body>
<h3> Bug: </h3>
<pre>
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/Bug/invoke_procedure_in_trigger.sql">invoke_procedure_in_trigger.sql</a> - PL/SQL compiler will report the very weird error of PLS-00103 if adding a comment after the call procedure clause in a trigger
</pre>
<h3> DB Design Demo: </h3>
<pre>
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/DB_Design_Demo/annual_report_demo.sql">annual_report_demo.sql</a> - Using a simple SQL Demo of DB Design to build my Annual Report
</pre>
<h3> SCN: </h3>
<pre>
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/SCN/database_scn.sql">database_scn.sql</a> - Checking SCN number of oracle database (via joining two number of oracle dynamic performance view v$datafile and v$datafile_header)
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/SCN/datafile_header_scn.sql">datafile_header_scn.sql</a> - Checking SCN number (for both the column "checkpoint_change#" and "resetlogs_change#" via the oracle dynamic performance view v$datafile_header) of the header of data file
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/SCN/datafile_scn.sql">datafile_scn.sql</a> - Checking SCN number (in the column "checkpoint_change#" via the oracle dynamic performance view v$datafile) of current control file
</pre>
<h3> SQL Quiz: </h3>
<pre>
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/SQL%20Quiz/quiz_intersect.sql">quiz_intersect.sql</a> - Taking a SQL Quiz for Intersect I once noticed on a place where I seem like to not remember it a few days ago
</pre>
<h3> SQL Set Demos: </h3>
<pre>
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/SQL%20Set%20Demos/minus_inline_external_table.sql">minus_inline_external_table.sql</a> - Comparing the entries between two log files by SQL Set Operator "minus" after creating two separate inline external tables for those two log files in oracle database 20c
</pre>
<h3> Acquiring Pool SQL: </h3>
<pre>
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/acquiring_pool_sql/buffer_gets_rank_top_5_sql_on_sqlstats.sql">buffer_gets_rank_top_5_sql_on_sqlstats.sql</a> - Ranking Top 5 SQL for buffer_gets (High CPU) on "v$sqlstats" of Oracle
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/acquiring_pool_sql/disk_reads_rank_top_5_sql_on_sqlstats.sql">disk_reads_rank_top_5_sql_on_sqlstats.sql</a> - Ranking Top 5 SQL for disk_reads (High I/O) on "v$sqlstats" of Oracle
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/acquiring_pool_sql/poor_parsing_applications_rank_top_5_sql_on_sqlstats.sql">poor_parsing_applications_rank_top_5_sql_on_sqlstats.sql</a> - Ranking Top 5 SQL for poor parsing applications (parse_calls/executions) on "v$sqlstats" of Oracle
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/acquiring_pool_sql/shared_memory_rank_top_5_sql_on_sqlstats.sql">shared_memory_rank_top_5_sql_on_sqlstats.sql</a> - Ranking Top 5 SQL for shared memory (Memory hogs) on "v$sqlstats" of Oracle
</pre>
<h3> Active Data Guard: </h3>
<pre>
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/adg/check_dg_phystdby_log_apply.sql">check_dg_phystdby_log_apply.sql</a> - Checking primany and physical standby's redo log on Oracle Data Guard (active) whether is applied
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/adg/check_dg_redo_apply.sql">check_dg_redo_apply.sql</a> - The improved version checking redo data apply on Oracle Data Guard physical standby database
</pre>
<h3> ASH: </h3>
<pre>
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/ash/ash_event_count_topN.sql">ash_event_count_topN.sql</a> - View the Top-N event counts from ASH
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/ash/ash_event_count_topN_new.sql">ash_event_count_topN_new.sql</a> - The improved version of "ash_event_count_topN.sql"
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/ash/ash_event_count_topN_2.sql">ash_event_count_topN_2.sql</a> - The improved version of "ash_event_count_topN_new.sql"
</pre>
<h3> AWR Trend: </h3>
<pre>
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/awr_trend/acquire_aas.sql">acquire_aas.sql</a> - Acquiring Average Active Sessions (AAS) from the historical AWR reports
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/awr_trend/acquire_aas_2.sql">acquire_aas_2.sql</a> - The 2nd version of acquiring Average Active Sessions (AAS) from the historical AWR reports
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/awr_trend/acquire_clc.sql">acquire_clc.sql</a> - Acquiring Current Logons Count from the historical AWR reports
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/awr_trend/acquire_cpu_load.sql">acquire_cpu_load.sql</a> - Acquiring CPU Load from the historical AWR reports
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/awr_trend/acquire_cpu_load_2.sql">acquire_cpu_load_2.sql</a> - The 2nd version of acquiring CPU Load from the historical AWR reports
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/awr_trend/acquire_cpu_usage.sql">acquire_cpu_usage.sql</a> - Acquiring CPU Usage from the historical AWR reports
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/awr_trend/acquire_dbtime.sql">acquire_dbtime.sql</a> - Acquiring DB time from the historical AWR reports
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/awr_trend/acquire_dbtime_2.sql">acquire_dbtime_2.sql</a> - The 2nd version of acquiring DB time from the historical AWR reports
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/awr_trend/acquire_io_mbps.sql">acquire_io_mbps.sql</a> - Acquiring IO MBPS from the historical AWR reports
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/awr_trend/acquire_io_mbps_2.sql">acquire_io_mbps_2.sql</a> - The 2nd version of acquiring IO MBPS from the historical AWR reports
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/awr_trend/acquire_iops.sql">acquire_iops.sql</a> - Acquiring IOPS from the historical AWR reports
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/awr_trend/acquire_iops_2.sql">acquire_iops_2.sql</a> - The 2nd version of acquiring IOPS from the historical AWR reports
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/awr_trend/acquire_lps.sql">acquire_lps.sql</a> - Acquiring Logons Per Second from the historical AWR reports
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/awr_trend/acquire_network_mbps.sql">acquire_network_mbps.sql</a> - Acquiring Network MBPS from the historical AWR reports
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/awr_trend/acquire_redo_gen_mbps.sql">acquire_redo_gen_mbps.sql</a> - Acquiring Redo Generated MBPS from the historical AWR reports
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/awr_trend/acquire_rwps.sql">acquire_rwps.sql</a> - Acquiring Redo Writes Per Second from the historical AWR reports
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/awr_trend/acquire_tps.sql">acquire_tps.sql</a> - Acquiring TPS from the historical AWR reports
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/awr_trend/acquire_tps_2.sql">acquire_tps_2.sql</a> - The 2nd version of acquiring TPS from the historical AWR reports
</pre>
<h3> Capacity Planning: </h3>
<pre>
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/capacity_planning/checking_table_growth.sql">checking_table_growth.sql</a> - Checking the growth of table
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/capacity_planning/checking_table_growth_2.sql">checking_table_growth_2.sql</a> - The 2nd version of checking the growth of table
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/capacity_planning/checking_table_used_size.sql">checking_table_used_size.sql</a> - Focusing on checking the used size and other situations (such as, num_rows, blocks, avg_row_len and so on) of table
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/capacity_planning/checking_tablespace_growth.sql">checking_tablespace_growth.sql</a> - Checking the growth of tablespace
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/capacity_planning/checking_tablespace_growth_2.sql">checking_tablespace_growth_2.sql</a> - The 2nd version of checking the growth of tablespace
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/capacity_planning/monitor_big_table_size.sql">monitor_big_table_size.sql</a> - Monitoring the used size of big tables by using VIEW, PROCEDURE, SCHEDULER in the schema 'monitor'
</pre>
<h3> Dig IP via oracle function: </h3>
<pre>
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/dig_ip_via_function/dig_ip_via_function.sql">dig_ip_via_function.sql</a> - Digging all of IP Addresses connecting to Oracle DB Server via pre-created function "resolveHost"
</pre>
<h3> Dig IP via oracle trigger: </h3>
<pre>
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/dig_ip_via_trigger/dig_ip_via_trigger.sql">dig_ip_via_trigger.sql</a> - Digging all of IP Addresses connecting to Oracle DB Server via pre-created trigger "on_logon_trigger"
</pre>
<h3> Dig listener log: </h3>
<pre>
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/dig_listener_log_xml/dig_ip_via_listener_log_xml.sql">dig_ip_via_listener_log_xml.sql</a> - Digging real IP Address from the "XML" format of listener log file "log.xml"
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/dig_listener_log_xml/dig_ip_via_listener_log_xml_2.sql">dig_ip_via_listener_log_xml_2.sql</a> - The 2nd version of the prior SQL script "dig_ip_via_listener_log_xml.sql", the sole distinguish is this time I use "*" (using "NEWLINE" on 1st version) as a record delimited character when I create that external table
</pre>
<h3> Expdp: </h3>
<pre>
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/expdp/expdp_exclude_stats.sql">expdp_exclude_stats.sql</a> - Simulate the circumstance of adding this parameter "statistics=none" or "exclude=statistics" at the end of a usual EXPDP command
</pre>
<h3> Grant: </h3>
<pre>
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/grant/bgs_role_syn.sql">bgs_role_syn.sql</a> - Batch grant (only) select privilege on specific user (prod)'s all of tables to a new role (prod) and then grant this role to new user (qwz)
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/grant/bgs_role_syn_tab.sql">bgs_role_syn_tab.sql</a> - Batch grant (only) select privilege on specific user (prod)'s all of tables to a new role (prod) and then grant this role to new user (qwz), at the same time it could also query out schema (prod)'s all of table names on schema (qwz)
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/grant/bgs_role_syn_tab_2.sql">bgs_role_syn_tab_2.sql</a> - The 2nd version of 'bgs_role_syn_tab.sql', which use a materialized view 'u_tables' to accomplish the same function
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/grant/bgs_role_syn_tab_3.sql">bgs_role_syn_tab_3.sql</a> - Grant (only) select privilege on specific user (prod)'s tables T1 to a new role (bbs) and then grant this role to new user (qwz). At the same time it could also query out table T1's latest data on schema (qwz)
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/grant/bgs_scheduler.sql">bgs_scheduler.sql</a> - Regularly refresh view "u_tables" being created via running SQL script "bgs_role_syn_tab_2.sql"
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/grant/bth_grt_sel.sql">bth_grt_sel.sql</a> - Batch grant (only) select privilege on specific user's all of tables to a new user 'qwz'
</pre>
<h3> Migration Compare: </h3>
<pre>
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/migration_compare/migration_before_and_after_compare.sql">migration_before_and_after_compare.sql</a> - Comparing all of tables' total numbers (before and after migration) on all of production users
</pre>
<h3> Materialized View: </h3>
<pre>
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/mview/materialized_view_demo.sql">materialized_view_demo.sql</a> - Creating a demo of oracle materialized view on 'TEST' schema, by the way guiding you how to periodically (via using an oracle job) and manually refresh it
</pre>
<h3> PLSQL: </h3>
<pre>
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/plsql/dyn_crt_table/dyn_crt_table.sql">dyn_crt_table.sql</a> - Using to dynamically create a test table via substitution variable of SQL*Plus on <a href="https://github.com/guestart/Oracle-SQL-Scripts/tree/master/plsql/dyn_crt_table">dyn_crt_table</a> subdir
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/plsql/dyn_crt_table/dyn_crt_table_2.sql">dyn_crt_table_2.sql</a> - Using to dynamically create a test table via *ACCEPT* command of SQL*Plus on <a href="https://github.com/guestart/Oracle-SQL-Scripts/tree/master/plsql/dyn_crt_table">dyn_crt_table</a> subdir
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/plsql/dyn_crt_table/dyn_crt_table_3.sql">dyn_crt_table_3.sql</a> - Using to dynamically create a test table via using a concatenation string "||" on <a href="https://github.com/guestart/Oracle-SQL-Scripts/tree/master/plsql/dyn_crt_table">dyn_crt_table</a> subdir
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/plsql/dyn_crt_table/dyn_crt_table_4.sql">dyn_crt_table_4.sql</a> - Using to dynamically create a test table via using a q/Q delimiter, e.g q'[...]' or Q'[...]' on <a href="https://github.com/guestart/Oracle-SQL-Scripts/tree/master/plsql/dyn_crt_table">dyn_crt_table</a> subdir
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/plsql/grant/bgs_role_syn_2.sql">bgs_role_syn_2.sql</a> - The 2nd version of 'bgs_role_syn.sql' you can see here - https://github.com/guestart/Oracle-SQL-Scripts/blob/master/grant/bgs_role_syn.sql on <a href="https://github.com/guestart/Oracle-SQL-Scripts/tree/master/plsql/grant">grant</a> subdir
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/plsql/grant/bgs_role_syn_3.sql">bgs_role_syn_3.sql</a> - The 3rd version of 'bgs_role_syn.sql' you can see here - https://github.com/guestart/Oracle-SQL-Scripts/blob/master/grant/bgs_role_syn.sql on <a href="https://github.com/guestart/Oracle-SQL-Scripts/tree/master/plsql/grant">grant</a> subdir
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/plsql/grant/bth_grt_sel_2.sql">bth_grt_sel_2.sql</a> - The 2nd version of 'bth_grt_sel.sql' you can see here - https://github.com/guestart/Oracle-SQL-Scripts/blob/master/grant/bth_grt_sel.sql on <a href="https://github.com/guestart/Oracle-SQL-Scripts/tree/master/plsql/grant">grant</a> subdir
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/plsql/grant/bth_grt_sel_3.sql">bth_grt_sel_3.sql</a> - The 3rd version of 'bth_grt_sel.sql' you can see here - https://github.com/guestart/Oracle-SQL-Scripts/blob/master/grant/bth_grt_sel.sql on <a href="https://github.com/guestart/Oracle-SQL-Scripts/tree/master/plsql/grant">grant</a> subdir
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/plsql/performance_compare/identity_column_compare.sql">identity_column_compare.sql</a> - Comparing comsuing time (and cpu time) by using 3 different identity column in 3 different tables to insert some dummy data into those tables, you can see here on <a href="https://github.com/guestart/Oracle-SQL-Scripts/tree/master/plsql/performance_compare">performance_compare</a> subdir
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/plsql/performance_compare/insert_approach_compare.sql">insert_approach_compare.sql</a> - Comparing spending time (and cpu time) when using 3 number of different approaches to insert some data into a table, you can see here on <a href="https://github.com/guestart/Oracle-SQL-Scripts/tree/master/plsql/performance_compare">performance_compare</a> subdir
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/plsql/puzzle_plsql/compare_plsql_output.sql">compare_plsql_output.sql</a> - Comparing the output result of two types of PLSQL code - https://stevenfeuersteinonplsql.blogspot.com/2019/11/plsql-puzzle-what-code-can-be-removed.html on <a href="https://github.com/guestart/Oracle-SQL-Scripts/tree/master/plsql/puzzle_plsql">puzzle_plsql</a> subdir
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/plsql/puzzle_plsql/compare_plsql_output_2.sql">compare_plsql_output_2.sql</a> - The 2nd version of SQL script "compare_plsql_output.sql" which has been simplified by still using anonymous PLSQL block, this means that my processing flow will become simple on <a href="https://github.com/guestart/Oracle-SQL-Scripts/tree/master/plsql/puzzle_plsql">puzzle_plsql</a> subdir
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/plsql/puzzle_plsql/string-indexed_collection.sql">string-indexed_collection.sql</a> - A quick little #PLSQL puzzle written by Steven Feuerstein (Oracle) on Twitter on Dec 10, 2019 on <a href="https://github.com/guestart/Oracle-SQL-Scripts/tree/master/plsql/puzzle_plsql">puzzle_plsql</a> subdir
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/plsql/revoke/brs_role_syn_2.sql">brs_role_syn_2.sql</a> - The 2nd version of 'brs_role_syn.sql' you can see here - https://github.com/guestart/Oracle-SQL-Scripts/blob/master/revoke/brs_role_syn.sql on <a href="https://github.com/guestart/Oracle-SQL-Scripts/tree/master/plsql/revoke">revoke</a> subdir
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/plsql/revoke/brs_role_syn_3.sql">brs_role_syn_3.sql</a> - The 3rd version of 'brs_role_syn.sql' you can see here - https://github.com/guestart/Oracle-SQL-Scripts/blob/master/revoke/brs_role_syn.sql on <a href="https://github.com/guestart/Oracle-SQL-Scripts/tree/master/plsql/revoke">revoke</a> subdir
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/plsql/revoke/bth_rvk_sel_2.sql">bth_rvk_sel_2.sql</a> - The 2nd version of 'bth_rvk_sel.sql' you can see here - https://github.com/guestart/Oracle-SQL-Scripts/blob/master/revoke/bth_rvk_sel.sql on <a href="https://github.com/guestart/Oracle-SQL-Scripts/tree/master/plsql/revoke">revoke</a> subdir
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/plsql/revoke/bth_rvk_sel_3.sql">bth_rvk_sel_3.sql</a> - The 3rd version of 'bth_rvk_sel.sql' you can see here - https://github.com/guestart/Oracle-SQL-Scripts/blob/master/revoke/bth_rvk_sel.sql on <a href="https://github.com/guestart/Oracle-SQL-Scripts/tree/master/plsql/revoke">revoke</a> subdir
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/plsql/brgs_role_syn_tab.sql">brgs_role_syn_tab.sql</a> - Creating or replacing a user-defined procedure 'brgs_role_syn_tab' on schema SZD_BBS_V2
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/plsql/brgs_role_syn_tab_2.sql">brgs_role_syn_tab_2.sql</a> - The 2nd version of 'brgs_role_syn_tab.sql', on this version I simplify my user-defined procedure 'brgs_role_syn_tab_2' based on 'brgs_role_syn_tab' on schema SZD_BBS_V2
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/plsql/brgs_role_syn_tab_3.sql">brgs_role_syn_tab_3.sql</a> - The 3rd version of 'brgs_role_syn_tab.sql', on this version I create a materiralzed view "u_tables" on my user-defined procedure "brgs_role_syn_tab_3" on grantor schema SZD_BBS_V2
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/plsql/brst2_scheduler.sql">brst2_scheduler.sql</a> - Creating a user-defined job 'BRST2_JOB' on schema SZD_BBS_V2, the primary intention is it could regularly/periodically execute my procedure 'brgs_role_syn_tab_2' on schema SZD_BBS_V2
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/plsql/brst3_scheduler.sql">brst3_scheduler.sql</a> - Creating a user-defined job 'BRST3_JOB' on schema SZD_BBS_V2, the primary intention is it could regularly/periodically execute my procedure 'rgy_refresh_mview_uts' on schema SZD_BBS_V2
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/plsql/brst_scheduler.sql">brst_scheduler.sql</a> - Creating a user-defined job 'BRST_JOB' on schema SZD_BBS_V2, the primary intention is it could regularly/periodically execute my procedure 'brgs_role_syn_tab' on schema SZD_BBS_V2
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/plsql/rgy_refresh_mview_uts.sql">rgy_refresh_mview_uts.sql</a> Regularly refreshing MView "u_tables" created by procedure "brgs_role_syn_tab_3" from the SQL script "brgs_role_syn_tab_3.sql"
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/plsql/switch_redo_log_for_recycle.sql">switch_redo_log_for_recycle.sql</a> - Switching all of online redo log for a recycle on oracle database
</pre>
<h3> Recent Metrics: </h3>
<pre>
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/recent_metrics/acquire_recent_aas.sql">acquire_recent_aas.sql</a> - Acquiring the recent Average Active Sessions (AAS) from the Oracle DPV v$sysmetric_history and v$sysmetric_summary
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/recent_metrics/acquire_recent_clc.sql">acquire_recent_clc.sql</a> - Acquiring the recent Current Logons Count (CLC) from the Oracle DPV v$sysmetric_history and v$sysmetric_summary
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/recent_metrics/acquire_recent_cpu_load.sql">acquire_recent_cpu_load.sql</a> - Acquiring the recent CPU Load from the Oracle DPV v$sysmetric_history and v$sysmetric_summary
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/recent_metrics/acquire_recent_cpu_usage.sql">acquire_recent_cpu_usage.sql</a> - Acquiring the recent CPU Usage from the Oracle DPV v$sysmetric_history and v$sysmetric_summary
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/recent_metrics/acquire_recent_dbcpu_time_ratio.sql">acquire_recent_dbcpu_time_ratio.sql</a> - Acquiring the recent Database CPU Time Ratio from the Oracle DPV v$sysmetric_history and v$sysmetric_summary
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/recent_metrics/acquire_recent_dbtime.sql">acquire_recent_dbtime.sql</a> - Acquiring the recent Database Time from the Oracle DPV v$sysmetric_history and v$sysmetric_summary
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/recent_metrics/acquire_recent_dbwait_time_ratio.sql">acquire_recent_dbwait_time_ratio.sql</a> - Acquiring the recent Database Wait Time Ratio from the Oracle DPV v$sysmetric_history and v$sysmetric_summary
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/recent_metrics/acquire_recent_io_mbps.sql">acquire_recent_io_mbps.sql</a> - Acquiring the recent IO MBPS from the Oracle DPV v$sysmetric_history and v$sysmetric_summary
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/recent_metrics/acquire_recent_iops.sql">acquire_recent_iops.sql</a> - Acquiring the recent IO(Requests)PS from the Oracle DPV v$sysmetric_history and v$sysmetric_summary
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/recent_metrics/acquire_recent_lps.sql">acquire_recent_lps.sql</a> - Acquiring the recent Logons Per Second (LPS) from the Oracle DPV v$sysmetric_history and v$sysmetric_summary
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/recent_metrics/acquire_recent_network_mbps.sql">acquire_recent_network_mbps.sql</a> - Acquiring the recent Network MBPS from the Oracle DPV v$sysmetric_history and v$sysmetric_summary
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/recent_metrics/acquire_recent_redo_gen_mbps.sql">acquire_recent_redo_gen_mbps.sql</a> - Acquiring the recent Redo Generated MBPS from the Oracle DPV v$sysmetric_history and v$sysmetric_summary
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/recent_metrics/acquire_recent_rwps.sql">acquire_recent_rwps.sql</a> - Acquiring the recent Redo Writes Per Second (RWPS) from the Oracle DPV v$sysmetric_history and v$sysmetric_summary
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/recent_metrics/acquire_recent_tps.sql">acquire_recent_tps.sql</a> - Acquiring the recent Transactions Per Second (TPS) from the Oracle DPV v$sysmetric_history and v$sysmetric_summary
</pre>
<h3> Revoke: </h3>
<pre>
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/revoke/brs_role_syn.sql">brs_role_syn.sql</a> - Revoke new role (prod) from new user (qwz) to whom if (once) being granted on schema 'SYS'
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/revoke/brs_role_syn_tab.sql">brs_role_syn_tab.sql</a> - Revoke new role (prod) from new user (qwz) to whom if (once) being granted on schema 'SYS', furthermore revoke select privilege on new role (prod) and drop this role
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/revoke/brs_role_syn_tab_2.sql">brs_role_syn_tab_2.sql</a> - The 2nd version of 'brs_role_syn_tab.sql'
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/revoke/brs_role_syn_tab_3.sql">brs_role_syn_tab_3.sql</a> - The 3rd version of 'brs_role_syn_tab.sql'
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/revoke/bth_rvk_sel.sql">bth_rvk_sel.sql</a> - Batch revoke (only) select privilege on specific user's all of tables from a new user 'qwz' whom if being granted to
</pre>
<h3> Routine Inspection: </h3>
<pre>
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/routine_inspection/all_prod_user.sql">all_prod_user.sql</a> - Listing all of production users by dba_users (excluding sys related users)
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/routine_inspection/break_compute_demo.sql">break_compute_demo.sql</a> - Breaking (SQL*Plus command) tablespace_name and computing (SQL*Plus command) dropped size based on recyclebin object "BIN$..." existing in Oracle Static Data Dictionary View "dba_segments"
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/routine_inspection/check_non_default_parameter.sql">check_non_default_parameter.sql</a> - Checking whether there are some non-default parameters on Oracle database
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/routine_inspection/check_total_size_oracle_db.sql">check_total_size_oracle_db.sql</a> - Checking total sizes of Oracle database
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/routine_inspection/connect_machine_via_sql_id.sql">connect_machine_via_sql_id.sql</a> - Checking the machine name connecting to Oracle Database Server via inputting a specific value of SQL_ID
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/routine_inspection/ctl_file_path_in_rman_backupsets.sql">ctl_file_path_in_rman_backupsets.sql</a> - Listing all of control file's locaiton in rman backupsets
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/routine_inspection/db_buffer_cache_hit_ratio.sql">db_buffer_cache_hit_ratio.sql</a> - Displaying cache hit ratio for Oracle database
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/routine_inspection/dropped_object_of_recyclebin.sql">dropped_object_of_recyclebin.sql</a> - Getting some dropped objects (such as TABLE, INDEX, SEQUENCE) from recyclebin via checking static data dictionary (SDD) "DBA_RECYCLEBIN" on Oracle Database
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/routine_inspection/get_ddl_of_object_via_passing_in_arguments.sql">get_ddl_of_object_via_passing_in_arguments.sql</a> - Getting DDL statement of an object (such as TABLE, INDEX, SEQUENCE, VIEW, FUNCTION and PROCEDURE) via calling SQL Script meanwhile passing in some arguments on Oracle Database
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/routine_inspection/get_ddl_of_object_via_using_accept.sql">get_ddl_of_object_via_using_accept.sql</a> -Getting DDL statement of an object (such as TABLE, INDEX, SEQUENCE, VIEW, FUNCTION and PROCEDURE) via using "accept" of SQL*Plus command on Oracle Database
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/routine_inspection/get_ddl_of_object_via_using_substitution_variable.sql">get_ddl_of_object_via_using_substitution_variable.sql</a> - Getting DDL statement of an object (such as TABLE, INDEX, SEQUENCE, VIEW, FUNCTION and PROCEDURE) via using substitution variable of SQL*Plus on Oracle Database
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/routine_inspection/get_dyn_perf_view_def.sql">get_dyn_perf_view_def.sql</a> - Getting the definition of dynamic performance view on Oracle Database
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/routine_inspection/get_dyn_perf_view_def_2.sql">get_dyn_perf_view_def_2.sql</a> - The 2nd version of SQL script "get_dyn_perf_view_def.sql" - using "accept" of SQL*Plus command on Oracle Database
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/routine_inspection/get_dyn_perf_view_def_3.sql">get_dyn_perf_view_def_3.sql</a> - The 3rd version of SQL script "get_dyn_perf_view_def.sql" - calling SQL Script "get_dyn_perf_view_def_3.sql" meanwhile passing in argument on Oracle Database
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/routine_inspection/hit_ratio_db_buffer_cache.sql">hit_ratio_db_buffer_cache.sql</a> - Displaying db buffer cache hit ratio for Oracle database
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/routine_inspection/hit_ratio_db_buffer_cache_2.sql">hit_ratio_db_buffer_cache_2.sql</a> - The 2nd version displaying db buffer cache hit ratio for Oracle database
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/routine_inspection/hit_ratio_db_buffer_cache_3.sql">hit_ratio_db_buffer_cache_3.sql</a> - The 3rd version displaying db buffer cache hit ratio for Oracle database
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/routine_inspection/per_machine_act_conn_num_aggr_by_user.sql">per_machine_act_conn_num_aggr_by_user.sql</a> - Showing per machine's active connect numbers after aggregating by username on v$session, meanwhile showing column client_info, that's to say, client's ip address
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/routine_inspection/rman_backup_check.sql">rman_backup_check.sql</a> - Displaying rman backup situation for Oracle database
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/routine_inspection/rman_backup_check_2.sql">rman_backup_check_2.sql</a> - The 2nd version displaying rman backup situation for Oracle database
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/routine_inspection/rman_backup_check_3.sql">rman_backup_check_3.sql</a> - The 3rd version displaying rman backup situation for Oracle database
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/routine_inspection/rman_backup_check_4.sql">rman_backup_check_4.sql</a> - The 4th version displaying rman backup situation for Oracle database
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/routine_inspection/rman_backup_check_plsql_1.sql">rman_backup_check_plsql_1.sql</a> - The 1st version displaying rman backup situation for Oracle database by calling common explicit cursor (open ... fetch ... close) on PL/SQL code
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/routine_inspection/rman_backup_check_plsql_2.sql">rman_backup_check_plsql_2.sql</a> - The 2nd version displaying rman backup situation for Oracle database by calling implicit cursor (for ... in ...) on PL/SQL code
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/routine_inspection/spfile_path_in_rman_backupsets.sql">spfile_path_in_rman_backupsets.sql</a> - Listing all of spfile's locaiton in rman backupsets
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/routine_inspection/tablespace_free_space.sql">tablespace_free_space.sql</a> - Checking the free space of tablespaces (including Data and Temp) on Oracle Database
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/routine_inspection/tablespace_non-temp_compare_total_size.sql">tablespace_non-temp_compare_total_size.sql</a> - Comparing the difference about total size (using more than one INLINE VIEW) of all of the non-temp tablespaces on Oracle Database
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/routine_inspection/tablespace_non-temp_compare_total_size_simple_version.sql">tablespace_non-temp_compare_total_size_simple_version.sql</a> - Comparing the difference about total size (using simple version) of all of the non-temp tablespaces on Oracle Database
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/routine_inspection/tablespace_non-temp_compare_total_size_with_as.sql">tablespace_non-temp_compare_total_size_with_as.sql</a> - Comparing the difference about total size (using WITH ... AS ...) of all of the non-temp tablespaces on Oracle Database
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/routine_inspection/tablespace_non-temp_recyclebin_rollup_segment_name.sql">tablespace_non-temp_recyclebin_rollup_segment_name.sql</a> - Checking the per blocks number (or dropped size) and its SUM by ROLLUP (segment_name) on non-temp tablespaces of Oracle Database
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/routine_inspection/tablespace_per_used_size_and_rollup.sql">tablespace_per_used_size_and_rollup.sql</a> - Checking the used size of per tablespace (and all) using "rollup" clause on Oracle Database
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/routine_inspection/tablespace_per_used_size_and_total_size.sql">tablespace_per_used_size_and_total_size.sql</a> - Checking the used size of per tablespace (and all) on Oracle Database
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/routine_inspection/tablespace_used_size_1.sql">tablespace_used_size_1.sql</a> - The 1st version Checking the used size of tablespace on Oracle Database
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/routine_inspection/tablespace_used_size_2.sql">tablespace_used_size_2.sql</a> - The 2nd version Checking the used size of tablespace on Oracle Database
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/routine_inspection/tablespace_utilization_rate.sql">tablespace_utilization_rate.sql</a> - Checking the utilization rate of all of the tablespace on Oracle Database
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/routine_inspection/tablespace_utilization_rate_2.sql">tablespace_utilization_rate_2.sql</a> - The 2nd (relatively simple) version of SQL script "tablespace_utilization_rate.sql" - using view both "sys.sm$ts_avail" and "sys.sm$ts_free" to check the utilization rate of non-Temporary tablespace
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/routine_inspection/temporary_tablespace_used_size.sql">temporary_tablespace_used_size.sql</a> - Checking the used size of all of TEMPORARY tablespaces on Oracle Database
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/routine_inspection/temporary_tablespace_used_size_2.sql">temporary_tablespace_used_size_2.sql</a> - The 2nd version of SQL script "temporary_tablespace_used_size.sql" on Oracle Database
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/routine_inspection/top_10_segment_on_sysaux_tbs.sql">top_10_segment_on_sysaux_tbs.sql</a> - Showing top 10 segment objects on sysaux tablespace
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/routine_inspection/top_10_segment_on_system_tbs.sql">top_10_segment_on_system_tbs.sql</a> - Showing top 10 segment objects on system tablespace
</pre>
<h3> Scheduler: </h3>
<pre>
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/scheduler/scheduler_demo.sql">scheduler_demo.sql</a> - Check running situation of oracle scheduler/job
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/scheduler/user_scheduler_job_log.sql">user_scheduler_job_log.sql</a> - Check the executing/running situation of the oracle scheduer/job log on 'TEST' schema
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/scheduler/user_scheduler_jobs.sql">user_scheduler_jobs.sql</a> - Checking the some information of the oracle scheduer/job on 'TEST' schema
</pre>
<h3> SQL Tuning: </h3>
<pre>
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/sql_tuning/check_data_dictionary_tables_and_views.sql">check_data_dictionary_tables_and_views.sql</a> - Check data dictionary tables and views of Oracle
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/sql_tuning/check_sql_execution_plan_table.sql">check_sql_execution_plan_table.sql</a> - Check the SQL statement's execution plan
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/sql_tuning/check_sql_multiple_execution_plans.sql">check_sql_multiple_execution_plans.sql</a> - Check SQL multiple execution plans
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/sql_tuning/check_sql_multiple_execution_plans_2.sql">check_sql_multiple_execution_plans_2.sql</a> - Check SQL multiple execution plans-2
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/sql_tuning/like_expression.sql">like_expression.sql</a> - Optimize the SQL statement with LIKE expression on Oracle Database
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/sql_tuning/like_expression_2.sql">like_expression_2.sql</a> - The 2nd version of like_expression.sql, which will focus on talking about these two cases: "%qw" and "q%w"
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/sql_tuning/optimize_query_null_value.sql">optimize_query_null_value.sql</a> - Optimize the SQL query of "NULL" value
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/sql_tuning/pagination_query_ascending_index.sql">pagination_query_ascending_index.sql</a> - Observing the execution plan of top-N and pagination query on Oracle Database via calling DBMS_XPLAN.display_cursor()
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/sql_tuning/pagination_query_bug.sql">pagination_query_bug.sql</a> - Observing the execution plan of top-N and pagination query on Oracle Database via setting autotrace traceonly
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/sql_tuning/topN_query_descending_index(bug).sql">topN_query_descending_index(bug).sql</a> - Observing the execution plan of top-N (20) query on Oracle Database via calling DBMS_XPLAN.display_cursor()
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/sql_tuning/user_index_columns.sql">user_index_columns.sql</a> - Checking the related index columns info by inputting a table name when using SQL*Plus to connect to a user on Oracle Database
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/sql_tuning/user_index_expressions.sql">user_index_expressions.sql</a> - Checking the related index expressions on several columns by inputting a table name when using SQL*Plus to connect to a user on Oracle Database
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/sql_tuning/user_indexes.sql">user_indexes.sql</a> - Checking the related indexes info by inputting a table name when using SQL*Plus to connect to a user on Oracle Database
</pre>
<h3> Statistics Info: </h3>
<pre>
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/statistics_info/all_tables_mods_on_all_proc_users.sql">all_tables_mods_on_all_proc_users.sql</a> - Check DML of all of tables from all of production users
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/statistics_info/all_tables_stats_on_all_proc_users.sql">all_tables_stats_on_all_proc_users.sql</a> - Check statistics of all of tables from all of production users
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/statistics_info/table_column_statistics.sql">table_column_statistics.sql</a> - Check some related statistics of column of table
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/statistics_info/table_mods_on_proc_user.sql">table_mods_on_proc_user.sql</a> - Only check modifications of table or user which has been appointed
<a href="https://github.com/guestart/Oracle-SQL-Scripts/blob/master/statistics_info/table_stats_on_proc_user.sql">table_stats_on_proc_user.sql</a> - Only check statistics of table or user which has been appointed
</pre>
</body>
</html>
