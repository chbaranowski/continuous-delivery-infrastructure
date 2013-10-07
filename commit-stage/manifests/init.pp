package { 'git':
  ensure => installed,
  name => 'git',
}

package { 'jdk':
  ensure => installed,
  name => 'openjdk-7-jdk',
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