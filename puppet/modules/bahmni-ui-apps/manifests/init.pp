class bahmni-ui-apps {
  file { "${httpd_deploy_dir}" :
    ensure      => directory,
    owner       => "${bahmni_user}",
    group       => "${bahmni_user}",
    mode        => 775,
  }

  exec { "change_rights_for_httpd_deploy_dir" :
    provider => "shell",
    command => "chown -R ${bahmni_user}:${bahmni_user} ${httpd_deploy_dir}; chmod -R ug+w,a+r ${httpd_deploy_dir}",
    path => "${os_path}",
    require => File["${httpd_deploy_dir}"],
  }

  bahmni-ui-app {"registration": appName => "registration"}
  bahmni-ui-app {"home": appName => "home"}
  bahmni-ui-app {"opd": appName => "opd"}
  bahmni-ui-app {"bahmni_config": appName => "bahmni_config"}
}