# reorg
Database DeFragmentation > 12c - Use the scripts as needed for your environment 
It's higly recommended to test the reorg scripts in Non Prod Environments.

# Identify Fragmentation 
Use the frag.sql to list the tables which are fragemented

for. e.g. to identify fragmentation > 70% , this script will also identify which partitions are fragmented. 
SQL> @frag 70

# Generate reorg scripts (for non partitioned tables)
Use the reorg_gen_nopart.sql , the script will spool the DDL reorg scripts for non partitioned tables

for e.g. to generate reorg scripts for SCOTT.HR table
SQL> @reorg_gen_nopart.sql SCOTT HR

# Generate reorg scripts (for partitioned tables)
Use the reorg_gen_part.sql , the script will spool the DDL reorg scripts for partitioned tables
Use the reorg_gen_nonpart_ind_part_tab.sql.sql , the script will spool the DDL reorg scripts for global indexes for partitioned tables 

for e.g. to generate reorg scripts for SALES.INVOICES table for partitions JAN2018 , FEB2018 , MAR2018 

SQL> @reorg_gen_nopart.sql SALES INVOICES JAN2018

SQL> @reorg_gen_nopart.sql SALES INVOICES FEB2018

SQL> @reorg_gen_nopart.sql SALES INVOICES MAR2018

It's highly recommended to reorg global indexes when partitions are reorg'd
SQL> @reorg_gen_nonpart_ind_part_tab.sql SALES INVOICES

# Statistics
All reorg DDL scripts come will auto generate the DBMS_STATS scripts , you can customise it to your needs






