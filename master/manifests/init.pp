package { 'git':
  ensure => installed,
  name => 'git',
}

package { 'jdk':
  ensure => installed,
  name => 'openjdk-7-jdk',
}

package { 'zip':
  ensure => installed,
  name => 'zip',
}

file { '/home/vagrant/.gitconfig':
  ensure  => present,
  owner   => 'vagrant',
  group   => 'vagrant',
  mode    => '0644',
  content => '[user]
               email = vagrant@seitenbau.com
               name  = vagrant',
}

class { 'jenkins': 
  lts => 1
}

jenkins::plugin {
  "credentials" : 
    version => "1.8.2";
  "ssh-slaves" : 
    version => "1.2";
  "ssh-credentials" : 
    version => "1.4";
  "ssh-agent" : 
    version => "1.3";
  "git-client" : 
    version => "1.3.0";
  "git" : 
    version => "1.5.0";
}

user { 'gitblit_user':
  ensure     => present,
  name       => 'gitblit',
  comment    => 'gitblit user',
  home       => '/home/gitblit',
  managehome => true,
}

exec { 'get_gitblit':
  command      => "wget https://gitblit.googlecode.com/files/gitblit-1.3.2.tar.gz -O gitblit-1.3.2.tar.gz",
  path         => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
  cwd          => '/home/gitblit/',
  user         => 'gitblit',
  unless       => 'test -f gitblit-1.3.2.tar.gz'
}

exec { 'unzip_gitblit':
  command      => "tar -zxvf gitblit-1.3.2.tar.gz",
  path         => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
  cwd          => '/home/gitblit/',
  user         => 'gitblit',
  unless       => 'test -f gitblit.jar'
}

exec { 'install_service_gitblit':
  command      => "sh install-service-ubuntu.sh",
  path         => '/usr/bin:/usr/sbin:/bin',
  cwd          => '/home/gitblit/',
  user         => 'root',
  unless       => 'test -f /etc/init.d/gitblit'
}
 
editfile::config { 'set_gitblit_port':
  path   => '/home/gitblit/data/gitblit.properties',
  entry  => 'server.httpPort',
  ensure => '9090',
  quote  => false,
  require => Exec['unzip_gitblit']
}

editfile::config { 'set_gitblit_host_binding':
  path   => '/home/gitblit/data/gitblit.properties',
  entry  => 'server.httpBindInterface',
  ensure => '0.0.0.0',
  quote  => false,
  require => Exec['unzip_gitblit']
}

editfile::config { 'set_gitblit_https_port':
  path   => '/home/gitblit/data/gitblit.properties',
  entry  => 'server.httpsPort',
  ensure => '0',
  quote  => false,
  require => Exec['unzip_gitblit']
}

editfile::config { 'set_gitblit_service_path':
  path   => '/etc/init.d/gitblit',
  entry  => 'GITBLIT_PATH',
  ensure => '/home/gitblit',
  quote  => false,
  require => Exec['install_service_gitblit']
}

editfile::config { 'set_gitblit_service_data_path':
  path   => '/etc/init.d/gitblit',
  entry  => 'GITBLIT_BASE_FOLDER',
  ensure => '/home/gitblit/data',
  quote  => false,
  require => Exec['install_service_gitblit']
}

editfile::config { 'set_gitblit_service_user':
  path   => '/etc/init.d/gitblit',
  entry  => 'GITBLIT_USER',
  ensure => 'root',
  quote  => true,
  require => Exec['install_service_gitblit']
}

service { 'gitblit':
  ensure     => running,
  enable     => true,
  hasstatus  => true,
  hasrestart => true,
}

user { 'artifactory_user':
  ensure     => present,
  name       => 'artifactory',
  comment    => 'artifactory user',
  home       => '/home/artifactory',
  managehome => true,
}

exec { 'get_artifactory':
  command      => "wget http://dl.bintray.com/content/jfrog/artifactory/artifactory-3.0.3.zip -O artifactory-3.0.3.zip",
  path         => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
  cwd          => '/home/artifactory/',
  user         => 'artifactory',
  unless       => 'test -f artifactory-3.0.3.zip'
}

exec { 'unzip_artifactory':
  command      => "unzip artifactory-3.0.3.zip",
  path         => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
  cwd          => '/home/artifactory/',
  user         => 'artifactory',
  unless       => 'test -f artifactory-3.0.3/'
}

exec { 'install_service_artifactory':
  command      => "sh installService.sh",
  path         => '/usr/bin:/usr/sbin:/bin',
  cwd          => '/home/artifactory/artifactory-3.0.3/bin',
  user         => 'root',
  unless       => 'test -f /etc/init.d/artifactory'
}

service { 'artifactory':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
}

Package['openjdk-7-jdk']
 -> Exec['get_gitblit']
 -> Exec['unzip_gitblit']
 -> Exec['install_service_gitblit']
 -> Service['gitblit']
 -> Package['zip']
 -> Exec['get_artifactory']
 -> Exec['unzip_artifactory']
 -> Exec['install_service_artifactory']
 -> Service['artifactory']
