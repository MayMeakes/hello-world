DBA的思想天空
select name,e.isdefault,e.value,p.description
from v$ses_optimizer_env e left outer 
		join v$parameter p using (name)
		join v$session using (sid)
where audsid =1378
order by isdefault,name;

col cursor_cache_hits format a20 truncate;
col soft_parses format a20 truncate;
col hard_parses format a20 truncate;
select
to_char(100 * sess / calls, '9999990.00') || '%' cursor_cache_hits,
to_char(100 * (calls - sess - hard) / calls, '999990.00') || '%' soft_parses,
to_char(100 * hard / calls, '999990.00') || '%' hard_parses
from
( select value calls from v$sysstat where name = 'parse count (total)' ),
( select value hard from v$sysstat where name = 'parse count (hard)' ),
( select value sess from v$sysstat where name = 'session cursor cache hits' );


Select 'session_cached_cursors' parameter, lpad(value, 5) value,
decode(value, 0, ' n/a', to_char(100 * used / value, '990') || '%') usage
from
( select
max(s.value) used
from
v$statname n,
v$sesstat s
where
n.name = 'session cursor cache count' and
s.statistic# = n.statistic#
),
( select
value
from
v$parameter
where
name = 'session_cached_cursors'
) ;


column indx heading "indx|indx num"
column kghlurcr heading "RECURRENT|CHUNKS"
column kghlutrn heading "TRANSIENT|CHUNKS"
column kghlufsh heading "FLUSHED|CHUNKS"
column kghluops heading "PINS AND|RELEASES"
column kghlunfu heading "ORA-4031|ERRORS"
column kghluNFS heading "LAST ERROR|SIZE"
select
indx,
kghlurcr,
kghlutrn,
kghlufsh,
kghluops,
kghlunfu,
kghluNFS
from
sys.x$kghlu
where
inst_id = userenv('Instance');
























