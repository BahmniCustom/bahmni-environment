#!/bin/sh
set -e -x

 

CHANGE_LOG_TABLE="-Dliquibase.databaseChangeLogTableName=liquibasechangelog -Dliquibase.databaseChangeLogLockTableName=liquibasechangeloglock"
LIQUIBASE_JAR="<%= tomcatInstallationDirectory %>/webapps/openmrs/WEB-INF/lib/liquibase-core-2.0.5.jar"
DRIVER="com.mysql.jdbc.Driver"
CREDS="--url=jdbc:mysql://localhost:3306/openmrs --username=root --password=password"
CLASSPATH="<%= build_output_dir %>/<%= openmrs_distro_file_name_prefix %>/<%= openmrs_war_file_name %>.war"
WORKING_DIR="<%= build_output_dir %>/<%= migrationsDirectory %>"

cd $WORKING_DIR 
java $CHANGE_LOG_TABLE -jar $LIQUIBASE_JAR --driver=$DRIVER --classpath=$CLASSPATH --changeLogFile=liquibase.xml $CREDS update
cd -