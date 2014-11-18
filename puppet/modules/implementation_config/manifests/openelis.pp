class implementation_config::openelis {

  exec { "copyLogoToOpenelis" :
    command   => "cp ${build_output_dir}/${implementation_name}_config/openelis/images/labLogo.jpg ${tomcatInstallationDirectory}/webapps/${openelis_war_file_name}/WEB-INF/reports/images",
    provider  => shell,
    path      => "${os_path}",
    onlyif    => "test -f ${build_output_dir}/${implementation_name}_config/openelis/images/labLogo.jpg"
  }

  exec { "copyLogoToOpenelisForReportConfig" :
    command   => "cp ${build_output_dir}/${implementation_name}_config/openelis/images/labLogo.jpg ${tomcatInstallationDirectory}/webapps/${openelis_war_file_name}/images",
    provider  => shell,
    path      => "${os_path}",
    onlyif    => "test -f ${build_output_dir}/${implementation_name}_config/openelis/images/labLogo.jpg"
  }
  
  file { "${build_output_dir}/OpenElis.zip " : ensure => absent, purge => true}

  exec { "bahmni_openelis_codebase_for_liquibase_jar" :
    provider => "shell",
    command  => "unzip -o -q ${build_output_dir}/OpenElis.zip -d ${temp_dir} ${deployment_log_expression}",
    path     => "${os_path}",
    onlyif    => "test -f ${build_output_dir}/${implementation_name}_config/migrations/openelis/liquibase.xml",
    require   => [File["${bahmni_openelis_temp_dir}"]]
  }

  implementation_config::migrations { "implementation_config_migrations_openelis":
    implementation_name => "${implementation_name}",
    app_name            => "openelis"
  }
}