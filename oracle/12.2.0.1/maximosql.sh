#!/bin/bash

#Main
echo "DB HostName: " $DB_HOST_NAME
echo "Oracle SID: " $ORACLE_SID
sqlplus sys/$ORACLE_PWD@//$DB_HOST_NAME:1521/$ORACLE_SID as sysdba <<EOF
alter session set "_ORACLE_SCRIPT"=true;
CREATE TABLESPACE MAXDATA DATAFILE 'maxdata.dbf' SIZE 1000M REUSE AUTOEXTEND ON MAXSIZE UNLIMITED;
create temporary tablespace maxtemp tempfile 'maxtemp.dbf' SIZE 1000M REUSE AUTOEXTEND ON MAXSIZE UNLIMITED;
CREATE TABLESPACE MAXINDEX DATAFILE 'maxindex.dbf' SIZE 1000M REUSE AUTOEXTEND ON MAXSIZE UNLIMITED;
create user maximo identified by $ORACLE_PWD default tablespace maxdata temporary tablespace maxtemp;
grant dba to maximo;
grant connect to maximo;
grant create job to maximo;
grant create trigger to maximo;
grant create session to maximo;
grant create sequence to maximo;
grant create synonym to maximo;
grant create table to maximo;
grant create view to maximo;
grant create procedure to maximo;
grant alter session to maximo;
grant execute on ctxsys.ctx_ddl to maximo;
alter user maximo quota unlimited on maxdata;
alter user maximo quota unlimited on maxindex
EOF

