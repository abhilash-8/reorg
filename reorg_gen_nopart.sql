-------------------------------------------------------------------------------------------------
--Script Name    : reorg_gen_nopart.sql
--Description    : Generate reorg DDL for a non partitioned table
--Args           : @reorg_gen_nopart owner table_name
--Author         : Abhilash Kumar Bhattaram
--Email          : abhilash8@gmail.com
--GitHb          : https://github.com/abhilash-8/reorg
-------------------------------------------------------------------------------------------------
col ---REORG_TABLE for a100
col ---REBUILD_INDEX for a100
col ---RUN_STATS for a500
def owner=&1
def table_name=&2
set verify off
set feedback off
set time off
set timing off
set serveroutput off
COLUMN FILE_NAME NEW_VALUE SPOOL_FILE NOPRINT
SELECT 'reorg_'||'&owner'||'_'||'&table_name'||'.sql' FILE_NAME FROM dual;
SPOOL &SPOOL_FILE
select 'alter table '||owner||'.'||table_name||' move parallel 24;' "---REORG_TABLE"from dba_tables
where table_name like '&table_name'
and owner like '&owner'
and PARTITIONED='NO';
select 'alter table '||owner||'.'||table_name||' noparallel;' "---REORG_TABLE" from dba_tables
where table_name like '&table_name'
and owner like '&owner'
and PARTITIONED='NO';
select 'alter index '||owner||'.'||index_name||' rebuild parallel 24 ;' "---REBUILD_INDEX" from dba_indexes
where table_name like '&table_name'
and owner like '&owner'
and PARTITIONED='NO';
select 'alter index '||owner||'.'||index_name||' noparallel ;' "---REBUILD_INDEX" from dba_indexes
where table_name like '&table_name'
and owner like '&owner'
and PARTITIONED='NO';
prompt ----Stats Update for  "&owner"."&table_name"
select '--EXECUTE DBMS_STATS.GATHER_TABLE_STATS(OWNNAME =>'||''''||owner||''''||' , TABNAME =>'||''''||table_name||''''||' ,OPTIONS =>'||''''||'GATHER AUTO'||''''||' , CASCADE =>'||'TRUE'||' , GRANULARITY=>'||''''||'ALL'||''''||',DEGREE =>'||'20'||' , METHOD_OPT =>'||''''||'FOR ALL COLUMNS SIZE AUTO'||''''||'); ' "---RUN_STATS" from dba_tab_statistics where owner like '&owner' and table_name like '&table_name' ;
prompt ---- Stop Reorg for "&owner"."&table_name"
spool off
undef owner
undef table_name
