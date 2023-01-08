REM
REM     Script:        params_default.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Aug 05, 2022
REM
REM     Last tested:
REM             11.2.0.4
REM             12.2.0.1
REM             19.3.0.0
REM
REM     Purpose:
REM       Checking the default parameters of oracle database.
REM

-- 11.2, only having value.
-- https://docs.oracle.com/cd/E11882_01/server.112/e40402/dynviews_2087.htm#REFRN30176

-- from 12.1, having default_value, value is reserved.
-- https://docs.oracle.com/database/121/REFRN/GUID-C86F3AB0-1191-447F-8EDF-4727D8693754.htm#REFRN30176

select name,
       decode(type, 1, 'Boolean', 2, 'String', 3, 'Integer', 4, 'Parameter file', 5, 'Reserved', 6, 'Big integer') type,
       value,
       description
from v$parameter where  isdefault = 'TRUE'
order by name;
