class hadoop {
  $hadoop_version = "hadoop-2.4.0"
  $java_path = "/usr/java/jdk1.7.0_45"
  $hadoopdata = "/opt/hadoopdata"
  $replication_count = 1
  
  file { "/var/tmp/${hadoop_version}.tar.gz":
    source => "puppet:///modules/hadoop/${hadoop_version}.tar.gz",
    owner => root,
    group => root,
    mode => 644
  }
  
  exec { "unpack_hadoop":
    command => "tar -zxf /var/tmp/${hadoop_version}.tar.gz -C /opt",
    path => $path,
    creates => "/opt/${hadoop_version}",
    require => File["/var/tmp/${hadoop_version}.tar.gz"]
  }

  file { "/var/tmp/jdk-7u45-linux-i586.rpm":
    source =>  "puppet:///modules/hadoop/jdk-7u45-linux-i586.rpm",
    owner => root,
    group => root,
    mode => 755 
  }
  
  exec { "install_java":
    command => "rpm -i /var/tmp/jdk-7u45-linux-i586.rpm",
    path => $path,
    creates => "${java_path}",
    require => File["/var/tmp/jdk-7u45-linux-i586.rpm"] 
  }
  
  file { "/opt/${hadoop_version}/etc/hadoop/core-site.xml":
    content => template("hadoop/core-site.xml.erb"),
    mode => 644, 
    owner => root,
    group => root,
    require => Exec["unpack_hadoop"]
  }
  
  file { "/opt/${hadoop_version}/etc/hadoop/hdfs-site.xml":
    content => template("hadoop/hdfs-site.xml.erb"),
    mode => 644, 
    owner => root,
    group => root,
    require => Exec["unpack_hadoop"]
  } 

  file { "/opt/${hadoop_version}/etc/hadoop/mapred-site.xml":
    source => "puppet:///modules/hadoop/mapred-site.xml",
    mode => 644, 
    owner => root,
    group => root,
    require => Exec["unpack_hadoop"]
  }
   
  file { "/opt/${hadoop_version}/etc/hadoop/yarn-site.xml":
    source => "puppet:///modules/hadoop/yarn-site.xml",
    mode => 644, 
    owner => root,
    group => root,
    require => Exec["unpack_hadoop"]
  }
  
  file { "/opt/${hadoop_version}/etc/hadoop/hadoop-env.sh":
    content => template("hadoop/hadoop-env.sh.erb"),
    mode => 644,
    owner => root,
    group => root,
    require => Exec["unpack_hadoop"]
  } 
  
  file { "/root/.ssh":
    ensure => 'directory',
    mode => 600,
    owner => root,
    group => root
  }
  
  file { "/root/.ssh/id_rsa":
    source => "puppet:///modules/hadoop/id_rsa",
    mode => 600,
    owner => root,
    group => root,
    require => File["/root/.ssh"] 
  }
 
  file { "/root/.ssh/id_rsa.pub":
    source => "puppet:///modules/hadoop/id_rsa.pub",
    mode => 644,
    owner => root,
    group => root,
    require => File["/root/.ssh"]
  }

  ssh_authorized_key { "ssh_key":
    ensure => "present",
    key    => "AAAAB3NzaC1yc2EAAAADAQABAAABAQDblRgDqfqGglZ/RemhY5BnSp2hkpd+NhGbm0tlV/2f6Be6YpI7OmblkIS4KWjd6A8kcETahSGndfBXzBTAYhcQOMfB7CZEEmb06swd4Dyb8y1bLmoSBT9MCV3gUvQtgWyVPgNcMnQ+aEGYy6BH4zMgrqfbMlJuoInmbYOH/8Cbxz6D9CKOy/dOA+6B8AqrmiH2XJf7lSCaBriPD7w+e/bxvKQOGqISTT3ykTtm6mid7GEAarPR8nod4af1Yrqat6EorhkBYfboJsaqFOdHlkFZyHwOh6NMH4f4YV3mU4W7ggbbiJx5gPGm0LmGkmCcLEzLnMFeauxWSSLPKz5f25Bx",
    type   => "ssh-rsa",
    user   => "root",
    require => File['/root/.ssh/id_rsa.pub']
  }

  file {"/root/.bash_profile":
    source => "puppet:///modules/hadoop/bash_profile",
    mode => 644,
    owner => root,
    group => root
  }

  file{"/etc/sudoers":
    content => template("hadoop/sudoers.erb"),
    owner => "root",
    group => "root",
    mode => "400"
  }
  service { "iptables":
    ensure => "stopped",
    enable => false
  }
}

