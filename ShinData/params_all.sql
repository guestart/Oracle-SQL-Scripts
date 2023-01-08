REM
REM     Script:        params_all.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Aug 01, 2022
REM
REM     Last tested:
REM             11.2.0.4
REM             12.2.0.1
REM             19.3.0.0
REM
REM     Purpose:
REM       Checking all of the parameters of oracle database.
REM

select name,
       decode(type, 1, 'Boolean', 2, 'String', 3, 'Integer', 4, 'Parameter file', 5, 'Reserved', 6, 'Big integer') type,
       value,
       description
from v$parameter 
order by name;
