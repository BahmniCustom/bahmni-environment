#!/bin/bash
set -e -x

WEBAPPS_DIR="<%= @tomcatInstallationDirectory %>/webapps"
OPENMRS_MODULE_DIR="<%= @openmrs_modules_dir %>"
CHANGE_LOG_TABLE="-Dliquibase.databaseChangeLogTableName=liquibasechangelog -Dliquibase.databaseChangeLogLockTableName=liquibasechangeloglock"
TEMP_DIR="<%= @temp_dir %>"
LIQUIBASE_JAR="${TEMP_DIR}/liquibase-core-2.0.5.jar"
DRIVER="com.mysql.jdbc.Driver"
CREDS="--url=jdbc:mysql://<%= ['config::db_server'] %>:3306/openmrs --username=root --password=password "
COMMON_CLASSPATH="<%= scope['config::build_output_dir'] %>/<%= @openmrs_distro_file_name_prefix %>/<%= @openmrs_war_file_name %>.war"
SNAPSHOTS_DIR=${TEMP_DIR}/snapshots


function run-liquibase-migration {
    CHANGE_LOG_DIR=$1
    CHANGE_LOG_FILE=$2
    if [ -a $CHANGE_LOG_DIR/$CHANGE_LOG_FILE ]; then
        cd $CHANGE_LOG_DIR
        java  $CHANGE_LOG_TABLE -jar $LIQUIBASE_JAR --driver=$DRIVER --classpath=$COMMON_CLASSPATH --changeLogFile=$CHANGE_LOG_FILE $CREDS update $3
    else
        echo "Could not find $1/$2 . Moving on"
    fi
}

function run-snapshot-migrations {
    run-liquibase-migration $SNAPSHOTS_DIR/$1/openmrs/resources liquibase-schema-only.xml
    run-liquibase-migration $SNAPSHOTS_DIR/$1/openmrs/resources liquibase-core-data.xml
    run-liquibase-migration $SNAPSHOTS_DIR/$1/openmrs/resources liquibase-update-to-latest.xml
    run-liquibase-migration $SNAPSHOTS_DIR/$1/bahmni-core/bahmnicore-omod migrations/dependent-modules/liquibase.xml
    run-liquibase-migration $SNAPSHOTS_DIR/$1/openmrs-atomfeed liquibase.xml
    run-liquibase-migration $SNAPSHOTS_DIR/$1/openmrs-module-appframework liquibase.xml
    run-liquibase-migration $SNAPSHOTS_DIR/$1/openmrs-module-calculation liquibase.xml
    run-liquibase-migration $SNAPSHOTS_DIR/$1/openmrs-module-metadatamapping liquibase.xml
    run-liquibase-migration $SNAPSHOTS_DIR/$1/openmrs-module-providermanagement liquibase.xml
    run-liquibase-migration $SNAPSHOTS_DIR/$1/openmrs-module-uiframework liquibase.xml
    run-liquibase-migration $SNAPSHOTS_DIR/$1/bahmni-core/bahmnicore-omod liquibase.xml
    run-liquibase-migration $SNAPSHOTS_DIR/$1/openmrs-module-bahmniapps/resources liquibase.xml
    run-liquibase-migration $SNAPSHOTS_DIR/$1 liquibase.xml
    run-liquibase-migration $SNAPSHOTS_DIR/$1/atomfeed sql/db_migrations.xml -DschemaName=openmrs
    <% if scope['config::bahmni_openelis_required'] == "true" %>
        run-liquibase-migration $SNAPSHOTS_DIR/$1/bahmni-core/openmrs-elis-atomfeed-client-omod liquibase.xml
    <% end %>
    <% if scope['config::artifactory_server_base_url'] == "true" %>
        run-liquibase-migration $SNAPSHOTS_DIR/$1/bahmni-core/openerp-atomfeed-client-omod liquibase.xml
    <% end %>
}

for dir in  `ls $SNAPSHOTS_DIR | sort -t- -n`
do
    run-snapshot-migrations $dir
done

exit 0