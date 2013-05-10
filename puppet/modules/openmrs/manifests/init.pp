class openmrs {
  $log4j_xml_file = "${tomcatInstallationDirectory}/webapps/openmrs/WEB-INF/classes/log4j.xml"
  $web_xml_file = "$tomcatInstallationDirectory/webapps/openmrs/WEB-INF/web.xml"

  file { "/home/${bahmni_user}/.OpenMRS" :
    ensure      => directory,
    owner       => "${bahmni_user}",
    group       => "${bahmni_user}",
    mode        => 666
  }

  file { "/home/${bahmni_user}/.OpenMRS/openmrs-runtime.properties" :
    ensure      => present,
    owner       => "${bahmni_user}",
    group       => "${bahmni_user}",
    mode        => 644,
    content     => template("openmrs/openmrs-runtime.properties"),
    require     => File["/home/${bahmni_user}/.OpenMRS"],
  }

  exec { "openmrs_webapp" :
    command   => "unzip -o -q ${build_output_dir}/openmrs.war -d ${tomcatInstallationDirectory}/webapps/openmrs ${deployment_log_expression}",
    provider  => shell,
    path      => "${os_path}",
    require   => File["${deployment_log_file}"]
  }

  file { "${log4j_xml_file}" :
    ensure      => present,
    content     => template("openmrs/log4j.xml.erb"),
    owner       => "${bahmni_user}",
    require     => Exec["openmrs_webapp"],
    mode        => 644
  }

  file { "${web_xml_file}" :
    ensure      => present,
    content     => template("openmrs/web.xml"),
    owner       => "${bahmni_user}",
    require     => Exec["openmrs_webapp"],
    mode        => 644
  }

  file { "${temp_dir}/create-openmrs-db.sql" :
    ensure      => present,
    content     => template("openmrs/database.sql"),
    owner       => "${bahmni_user}",
    group       => "${bahmni_user}"
  }

  exec { "openmrs_database" :
    command     => "mysql -uroot -p${mysqlRootPassword} < ${temp_dir}/create-openmrs-db.sql ${deployment_log_expression}",
    path        => "${os_path}",
    provider    => shell,
    require     => File["${temp_dir}/create-openmrs-db.sql"]
  }

  file { "${temp_dir}/run-liquibase.sh" :
    ensure      => present,
    content     => template("openmrs/run-liquibase.sh"),
    owner       => "${bahmni_user}",
    mode        => 544
  }

  exec { "openmrs_data" :
    command     => "${temp_dir}/run-liquibase.sh ${deployment_log_expression}",
    path        => "${os_path}",
    provider    => "shell",
    cwd         => "${tomcatInstallationDirectory}/webapps",
    require     => [Exec["openmrs_database"], File["${temp_dir}/run-liquibase.sh"], Exec["openmrs_webapp"]]
  }
}