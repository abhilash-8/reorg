-------------------------------------------------------------------------------------------------
--Script Name    : tab_ind.sql
--Description    : Identify all details about a Table and it's indexes before/after reorg
--Args           : @tab_ind owner table_name 
--Author         : Abhilash Kumar Bhattaram
--Email          : abhilash8@gmail.com
--GitHb          : https://github.com/abhilash-8/reorg
-------------------------------------------------------------------------------------------------
SET VERIFY OFF
SET LINESIZE 200
def owner=&1
def table_name=&2
COLUMN table_owner FORMAT A20
COLUMN index_owner FORMAT A20
COLUMN table_name FORMAT A30
COLUMN index_name FORMAT A20
COLUMN index_type FORMAT A20
COLUMN index_owner FORMAT A20
COLUMN index_type FORMAT A40
COLUMN tablespace_name FORMAT A20
COLUMN column_name FORMAT A40
COLUMN object_name FORMAT A30
COLUMN subobject_name FORMAT A30
COLUMN data_type FORMAT A10
COLUMN FILE_NAME NEW_VALUE SPOOL_FILE NOPRINT
SELECT '.tabind_'||'&owner'||'_'||'&table_name'||'.txt' FILE_NAME FROM dual;
SPOOL &SPOOL_FILE

prompt ### Table Columns 
select owner,table_name,column_name,data_type,data_length,last_analyzed,histogram from dba_tab_columns 
where owner like '&owner' and table_name like '&table_name';

prompt ### Index Tablespaces
SELECT table_owner,
       table_name,
       owner AS index_owner,
       index_name,
       tablespace_name,
       num_rows,
       status,
       index_type
FROM   dba_indexes
WHERE  table_owner = '&owner'
AND    table_name = '&table_name'
ORDER BY table_owner, table_name, index_owner, index_name;

prompt ### Indexed Columns 
select index_owner,table_name,index_name,column_name from dba_ind_columns where table_name = '&table_name' and table_owner like '&owner';

prompt ### Index Created Timestamp

select owner,object_name,subobject_name,object_type,last_ddl_time,created from dba_objects where object_name in 
(
SELECT 
       index_name       
FROM   dba_indexes
WHERE  table_owner = '&owner'
AND    table_name = '&table_name'
) 
and owner in 
(
SELECT 
       owner       
FROM   dba_indexes
WHERE  table_owner = '&owner'
AND    table_name = '&table_name'
)
order by created ;

prompt ### Table Segments Sizes 

compute sum of MB on report
--break on report on _date on inst skip 1
break on report on _date

set lines 200 pages 500
col tablespace_name for a25
col topseg_segment_name head SEGMENT_NAME for a40
col topseg_seg_owner HEAD OWNER FOR A25
col segment_type for a20
        select
                round(SUM(bytes/1048576)) MB,
                tablespace_name,
                owner topseg_seg_owner,
                segment_name topseg_segment_name,
                --partition_name,
                segment_type,
    case when count(*) > 1 then count(*) else null end partitions
        from dba_segments
        where 
        owner in
        (
                                SELECT 
                                       owner       
                                FROM   dba_tables 
                                WHERE  owner = '&owner'
                                AND    table_name = '&table_name'                               
         )
         and 
        segment_name in
        (
                                SELECT 
                                       table_name       
                                FROM   dba_tables 
                                WHERE  owner = '&owner'
                                AND    table_name = '&table_name'                               
         )        
  group by
                tablespace_name,
                owner,
                segment_name,
                segment_type
        order by MB desc;


prompt ### Index Segments Sizes

compute sum of MB on report
--break on report on _date on inst skip 1
break on report on _date

set lines 200 pages 500
col tablespace_name for a25
col topseg_segment_name head SEGMENT_NAME for a40
col topseg_seg_owner HEAD OWNER FOR A25
col segment_type for a20
        select
                round(SUM(bytes/1048576)) MB,
                tablespace_name,
                owner topseg_seg_owner,
                segment_name topseg_segment_name,
                --partition_name,
                segment_type,
    case when count(*) > 1 then count(*) else null end partitions
        from dba_segments
        where
        owner in
        (                       
                                        SELECT table_owner
                                        FROM   dba_indexes
                                        WHERE  table_owner = '&owner'
                                        AND    table_name = '&table_name'
                )
         and
        segment_name in
        (
                                        SELECT index_name
                                        FROM   dba_indexes
                                        WHERE  table_owner = '&owner'
                                        AND    table_name = '&table_name'
         )
  group by
                tablespace_name,
                owner,
                segment_name,
                segment_type
        order by MB desc;

undef owner
undef table_name
spool off
