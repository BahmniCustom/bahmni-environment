class dcm4chee{
  $bahmni_location = "/var/lib/bahmni"
  $dcm4chee_location =  "${bahmni_location}/dcm4chee-2.18.1-psql"
  $dcm4chee_zip_filename = "dcm4chee-2.18.1-psql"
  $dcm4chee_server_xml_location = "${dcm4chee_location}/server/default/deploy/jboss-web.deployer"
  $dcm4chee_conf_location = "${dcm4chee_location}/server/default/conf"
  $dcm4chee_archive_directory = "${dcm4chee_location}/server/default/archive"

  $share_location = "/usr/share"
  $jboss_filename = "jboss-4.2.3.GA"
  $jboss_location = "${share_location}/${jboss_filename}"
  $jboss_zip_filename = "${jboss_filename}-jdk6"



  if ($bahmni_pacs_required == "true") {
    file { "copy_install_script" :
      path      => "${temp_dir}/install_dcm4chee.sh",
      ensure    => present,
      content   => template ("dcm4chee/install_dcm4chee.sh"),
      owner     => "${bahmni_user}",
      mode      => 664,
    }

    exec { "install_dcm4chee" :
      command     => "sh ${temp_dir}/install_dcm4chee.sh ${deployment_log_expression}",
      provider    => shell,
      path        => "${os_path}",
      user        => "${bahmni_user}",
      require     => File["copy_install_script"],
    }

    file { "copy_server_xml" :
      path      => "${dcm4chee_server_xml_location}/server.xml",
      ensure    => present,
      content   => template ("dcm4chee/server.xml"),
      owner     => "${bahmni_user}",
      mode      => 664,
      require   => Exec["install_dcm4chee"],
    }

    file { "copy_service_xml" :
      path      => "${dcm4chee_conf_location}/jboss-service.xml",
      ensure    => present,
      content   => template ("dcm4chee/jboss-service.xml"),
      owner     => "${bahmni_user}",
      mode      => 664,
      require   => Exec["install_dcm4chee"],
    }

    file { "/etc/init.d/dcm4chee" :
      ensure      => present,
      content     => template("dcm4chee/dcm4chee.initd.erb"),
      mode        => 777,
      group       => "root",
      owner       => "root",
      require     => [File["copy_server_xml"], File["copy_service_xml"]],
    }

    file { "copy_start_script" :
      path      => "${temp_dir}/start_dcm4chee.sh",
      ensure    => present,
      content   => template ("dcm4chee/start_dcm4chee.sh"),
      owner     => "${bahmni_user}",
      mode      => 664,
    }

    if $is_passive_setup == "false" {
      cron { "sync_dcm4chee_image_cron" :
        command => "rsync -rh --progress -i --itemize-changes --update --chmod=Du=r,Dg=rwx,Do=rwx,Fu=rwx,Fg=rwx,Fo=rwx -p ${dcm4chee_archive_directory}/ -e root@${passive_machine_ip}:${dcm4chee_archive_directory}",
        user    => "root",
        minute  => "*/1"
      }

      exec { "start_dcm4chee" :
        command     => "sh ${temp_dir}/start_dcm4chee.sh ${deployment_log_expression}",
        provider    => shell,
        path        => "${os_path}",
        user        => "${bahmni_user}",
        require     => File["copy_start_script"],
      }
    }
  }
}

class dcm4chee::database {
  file { "init_DB" :
    path    => "${temp_dir}/initDB.sh",
    ensure  => present,
    content => template ("dcm4chee/initDB.sh"),
    owner   => "${bahmni_user}",
    mode    => 664,
  }

  file { "setup_DB" :
    path    => "${temp_dir}/setupDB.sql",
    ensure  => present,
    content => template ("dcm4chee/setupDB.sql"),
    owner   => "${bahmni_user}",
    mode    => 664,
  }

  exec { "${temp_dir}/initDB.sh" :
    command     => "sh ${temp_dir}/initDB.sh ${deployment_log_expression}",
    provider    => shell,
    path        => "${os_path}",
    user        => "${bahmni_user}",
    require     => [File["setup_DB"], File["init_DB"]],
  }
}