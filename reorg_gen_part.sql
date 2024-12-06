-------------------------------------------------------------------------------------------------
--Script Name    : reorg_gen_part.sql
--Description    : Generate reorg DDL for a partitioned table
--Args           : @reorg_gen_part owner table_name partition_name
--Author         : Abhilash Kumar Bhattaram
--Email          : abhilash8@gmail.com
--GitHb          : https://github.com/abhilash-8/reorg
-------------------------------------------------------------------------------------------------
col ---REORG_TABLE_PARTITION for a120
col ---REBUILD_INDEX_PARTITION for a120
col ---RUN_STATS for a600
def table_owner=&1
def owner=&1
def table_name=&2
def partition_name=&3
set verify off
set feedback off
set time off
set timing off
set serveroutput off
set lines 600
COLUMN FILE_NAME NEW_VALUE SPOOL_FILE NOPRINT
SELECT 'reorg_part_'||'&owner'||'_'||'&table_name'||'_'||'&partition_name'||'.sql' FILE_NAME FROM dual;
SPOOL &SPOOL_FILE
select 'alter table '||table_owner||'.'||table_name||' move partition '||partition_name ||' parallel 24;' "---REORG_TABLE_PARTITION" from dba_tab_partitions
where table_name like '&table_name'
and table_owner like '&owner'
and partition_name like '&partition_name';
select 'alter table '||owner||'.'||table_name||' noparallel;' "---REORG_TABLE_PARTITION" from dba_tables
where table_name like '&table_name'
and owner like '&table_owner';

select 'alter index '||index_owner||'.'||index_name||' rebuild partition '||partition_name ||' parallel 24;' "---REORG_INDEX_PARTITION" from dba_ind_partitions
where index_owner like '&table_owner'
and partition_name like '&partition_name';

select 'alter index '||index_owner||'.'||index_name||' noparallel;' "---REORG_INDEX_PARTITION" from dba_ind_partitions
where index_owner like '&table_owner'
and partition_name like '&partition_name';

prompt ----Stats Update for  "&owner"."&table_name"
select '--EXECUTE DBMS_STATS.GATHER_TABLE_STATS(OWNNAME =>'||''''||owner||''''||' , TABNAME =>'||''''||table_name||''''||' , PARTNAME =>'||''''||partition_name||''''||' ,OPTIONS =>'||''''||'GATHER AUTO'||''''||' , CASCADE =>'||'TRUE'||' , GRANULARITY=>'||''''||'ALL'||''''||',DEGREE =>'||'20'||' , METHOD_OPT =>'||''''||'FOR ALL COLUMNS SIZE AUTO'||''''||'); ' "---RUN_STATS"
from dba_tab_statistics  where  owner like '&owner' and  table_name like '&table_name'  and partition_name like '&partition_name';

spool off
undef owner
undef table_name
undef partition_name

