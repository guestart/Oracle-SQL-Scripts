REM
REM     Script:        set_sqlprompt.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Nov 17, 2022
REM
REM     Last tested:
REM             11.2.0.4
REM             12.2.0.1
REM             19.3.0.0
REM
REM     Purpose:
REM       Give your SQL*Plus connect to mark a noticeable prompt.
REM

set time on
set termout off
column propmt_q new_value propmt_q
select upper(user) || '@' || p.value || '/' || i.host_name as propmt_q from v$instance i, v$parameter p where p.name = 'db_unique_name';
set sqlprompt '&propmt_q> '

-- For example:

-- [oracle@yyds01 admin]$ vi glogin.sql 
-- --
-- -- Copyright (c) 1988, 2005, Oracle.  All Rights Reserved.
-- --
-- -- NAME
-- --   glogin.sql
-- --
-- -- DESCRIPTION
-- --   SQL*Plus global login "site profile" file
-- --
-- --   Add any SQL*Plus commands here that are to be executed when a
-- --   user starts SQL*Plus, or uses the SQL*Plus CONNECT command.
-- --
-- -- USAGE
-- --   This script is automatically run
-- --
-- set time on
-- set termout off
-- column propmt_q new_value propmt_q
-- select upper(user) || '@' || p.value || '/' || i.host_name as propmt_q from v$instance i, v$parameter p where p.name = 'db_unique_name';
-- set sqlprompt '&propmt_q> '
-- ~
-- ~
-- ~
-- "glogin.sql" 20L, 570C written                                                                                    
-- [oracle@yyds01 admin]$ sqlplus / as sysdba
-- 
-- SQL*Plus: Release 19.0.0.0.0 - Production on Thu Nov 17 14:11:29 2022
-- Version 19.3.0.0.0
-- 
-- Copyright (c) 1982, 2019, Oracle.  All rights reserved.
-- 
-- 
-- Connected to:
-- Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
-- Version 19.3.0.0.0
-- 
-- 14:11:30 SYS@yydsdb/yyds01> exit
-- Disconnected from Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
-- Version 19.3.0.0.0
