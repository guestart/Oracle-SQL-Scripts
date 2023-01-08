REM
REM     Script:        params_not_default.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Aug 08, 2022
REM
REM     Last tested:
REM             11.2.0.4
REM             12.2.0.1
REM             19.3.0.0
REM
REM     Purpose:
REM       Checking the current value (not default by modified) of parameters of oracle database.
REM

-- on 10g, 11g:

select name,
       decode(type, 1, 'Boolean', 2, 'String', 3, 'Integer', 4, 'Parameter file', 5, 'Reserved', 6, 'Big integer') type,
       value,  -- here
       description
from v$parameter where  isdefault = 'FALSE'
order by name;

-- from 12g:

select name,
       decode(type, 1, 'Boolean', 2, 'String', 3, 'Integer', 4, 'Parameter file', 5, 'Reserved', 6, 'Big integer') type,
       value current_value,  -- here
       default_value,        -- here
       description
from v$parameter where  isdefault = 'FALSE'
order by name;
