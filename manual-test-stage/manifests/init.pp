package { 'jdk':
  ensure => installed,
  name => 'openjdk-7-jdk',
}

package { 'tomcat':
  ensure => installed,
  name => 'tomcat7',
}

package { 'git':
  ensure => installed,
  name => 'git',
}

file { '/home/vagrant/.gitconfig':
  ensure  => present,
  owner   => 'vagrant',
  group   => 'vagrant',
  mode    => '0644',
  content => '[user]
               email = vagrant@seitenbau.com
               name = vagrant',
}

class { 'mysql::server':
  config_hash => { 
    'root_password' => 'blog',
    'bind_address'  => '0.0.0.0',
  }
}

mysql::db { 'simpleblog':
  user     => 'simpleblog-usr',
  password => 'simpleblog-pwd',
  host     => '%',
  grant    => ['all'],
}

editfile::config { 'Java Heap 512MB Tomcat':
  path   => '/etc/default/tomcat7',
  entry  => 'JAVA_OPTS',
  ensure => '-Djava.awt.headless=true -Xmx512m -XX:+UseConcMarkSweepGC',
  quote  => true,
}

file { '/etc/hostname':
  ensure  => present,
  owner   => 'root',
  group   => 'root',
  mode    => '0644',
  content => 'simpleblog-ast01',
}