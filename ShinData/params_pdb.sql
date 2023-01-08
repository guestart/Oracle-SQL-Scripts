REM
REM     Script:        params_pdb.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Aug 09, 2022
REM
REM     Last tested:
REM             11.2.0.4
REM             12.2.0.1
REM             19.3.0.0
REM
REM     Purpose:
REM       Checking the oracle database parameter value that is able to be modified on pdb level.
REM

12c:

select name,
       decode(type, 1, 'Boolean', 2, 'String', 3, 'Integer', 4, 'Parameter file', 5, 'Reserved', 6, 'Big integer') type,
       value,
       description
from v$parameter where ispdb_modifiable = 'TRUE' 
order by name;
