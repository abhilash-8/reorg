--- part-list.sql
spool part-list.out
def owner=&1
COLUMN table_name FORMAT A30
COLUMN partition FORMAT A30
COLUMN table_owner FORMAT A30
COLUMN partition_name FORMAT A30
COLUMN high_value FORMAT A85

with xml as (
  select dbms_xmlgen.getxmltype('select table_name, table_owner , partition_name, high_value from dba_tab_partitions where table_owner like ''&owner''') as x
  from   dual
)
  select extractValue(rws.object_value, '/ROW/TABLE_OWNER') table_owner,
                 extractValue(rws.object_value, '/ROW/TABLE_NAME') table_name,
         extractValue(rws.object_value, '/ROW/PARTITION_NAME') partition,
         extractValue(rws.object_value, '/ROW/HIGH_VALUE') high_value
  from   xml x,
         table(xmlsequence(extract(x.x, '/ROWSET/ROW'))) rws
         order by table_name,high_value;
                   
spool off
undef owner 
