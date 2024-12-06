-------------------------------------------------------------------------------------------------
--Script Name    : reorg_gen_nonpart_ind_part_tab.sql
--Description    : Generate reorg DDL for a global indexes for partitioned tables
--Args           : @reorg_gen_nonpart_ind_part_tab owner table_name
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
SELECT 'reorg_nonpart_ind_part_tab'||'&owner'||'_'||'&table_name'||'.sql' FILE_NAME FROM dual;
SPOOL &SPOOL_FILE
select 'alter index '||owner||'.'||index_name||' rebuild parallel 24 ;' "---REBUILD_INDEX" from dba_indexes
where table_name like '&table_name'
and owner like '&owner'
and PARTITIONED='NO';
select 'alter index '||owner||'.'||index_name||' noparallel ;' "---REBUILD_INDEX" from dba_indexes
where table_name like '&table_name'
and owner like '&owner'
and PARTITIONED='NO';
spool off
undef owner
undef table_name

