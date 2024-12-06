spool frag.out
def pct=&1
set pages 2000
col owner for a20
col table_name for a40
compute sum of FRAGMENTED_SPACE_MB on report
BREAK ON REPORT
prompt ### All Tables Fragmentation
select * from
(
select owner,table_name,avg_row_len,round(((blocks*16/1024)),2) "TOTAL_SIZE_MB",
round((num_rows*avg_row_len/1024/1024),2) "ACTUAL_SIZE_MB",
round(((blocks*16/1024)-(num_rows*avg_row_len/1024/1024)),2) "FRAGMENTED_SPACE_MB",
(round(((blocks*16/1024)-(num_rows*avg_row_len/1024/1024)),2)/round(((blocks*16/1024)),2))*100 "percentage"
from dba_tables
where round(((blocks*16/1024)-(num_rows*avg_row_len/1024/1024)),2) > 50
and (round(((blocks*16/1024)-(num_rows*avg_row_len/1024/1024)),2)/round(((blocks*16/1024)),2))*100 > &pct
and owner not in (select username from dba_users where ORACLE_MAINTAINED='Y')
order by FRAGMENTED_SPACE_MB desc
)
where
rownum <= 1001;


prompt ### Partitioned Table Fragmentation 
col table_owner for a20
col partition_name for a30

compute sum of FRAGMENTED_SPACE_MB on report
BREAK ON REPORT
select * from
(
select TABLE_OWNER,table_name,PARTITION_NAME,avg_row_len,round(((blocks*16/1024)),2) "TOTAL_SIZE_MB",
round((num_rows*avg_row_len/1024/1024),2) "ACTUAL_SIZE_MB",
round(((blocks*16/1024)-(num_rows*avg_row_len/1024/1024)),2) "FRAGMENTED_SPACE_MB",
(round(((blocks*16/1024)-(num_rows*avg_row_len/1024/1024)),2)/round(((blocks*16/1024)),2))*100 "percentage"
from dba_tab_partitions
where round(((blocks*16/1024)-(num_rows*avg_row_len/1024/1024)),2) > 50
and (round(((blocks*16/1024)-(num_rows*avg_row_len/1024/1024)),2)/round(((blocks*16/1024)),2))*100 > &pct
and TABLE_OWNER not in (select username from dba_users where ORACLE_MAINTAINED='Y')
order by FRAGMENTED_SPACE_MB desc
)
where
rownum <= 1001;


prompt ### Partitioned Index Fragmentation 
col index_name for a30
col index_owner for a30
col partition_name for a30

select INDEX_OWNER,INDEX_NAME,PARTITION_NAME,TABLESPACE_NAME from dba_ind_partitions where PARTITION_NAME in 
( 
	select PARTITION_NAME
	from dba_tab_partitions
	where round(((blocks*16/1024)-(num_rows*avg_row_len/1024/1024)),2) > 50
	and (round(((blocks*16/1024)-(num_rows*avg_row_len/1024/1024)),2)/round(((blocks*16/1024)),2))*100 > &pct
	and TABLE_OWNER not in (select username from dba_users where ORACLE_MAINTAINED='Y')
);
undef pct
