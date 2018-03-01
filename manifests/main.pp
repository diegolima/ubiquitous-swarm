Exec {
  path => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/opt/puppetlabs/bin',
}

class { 'docker':
  version => 'latest',
  require => File['/etc/resolv.conf'],
}

package { 'git':
  ensure => 'present'
  require => File['/etc/resolv.conf'],
}

user { 'root':
  ensure         => present,
  purge_ssh_keys => true,
  home           => '/root',
}
ssh_authorized_key { 'diego':
  ensure         => 'present',
  user           => 'root',
  type           => 'ssh-rsa',
  key            => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQC+ZFrqFnZ7b8aMc8qpvVtSpLkvZrvm4bS29gAKoeVn2OKHD/z1OmmQIW+1m5VvB+Sdi5iTPsv8nOsr9BRufWuRUO28RAClqHuMDWBm4yX5sYhtAU1uzfKJPb0OwQAxnMkXrdcZJaxhA552r+fEJivMHxDJU852rxBL98grPMLceOtnuy6CKMXp9HfEClDCE6JNgJXO70pvekLRmgcl2XEHC/whugF158UHL21peinUmbOSSeR1u7PggzOP4EIuWLjcAavEXPCkKVgRtAASQlwevHSvgEoMzXYMcYr22nXZihwK2dl/lpAkeXpLeIkNEZHDDYWPWIIc2goPtqDwA9c5',
}
ssh_authorized_key { 'services':
  ensure         => 'present',
  user           => 'root',
  type           => 'ssh-rsa',
  key            => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQDJNjSyLMpm+i3XIaQRKIOW14UiM8fJQe+Q4BX54K+EQpfRLZWD8ksa6GC+DBQ8WxbBzzwAk3bInb7Fy4+T+RatY9kpcBdyF57X7rkBYapg8M9yNehnTKLQZX/KvIyr5D1z6gkyno+DjRM5/iXK+Y+oG1/welKAhf9Er4GSbCPSu83XkfE9jer6Zoi489+7hsb+UcY4xZFPN9ZSorPvcvO7PtE9TRzNixn2UGzuvcwoQ9fP2nMPllm/npETPe1R9iQrguArxLKSc5S/cC8qoFXLSxlbshUPXX1NlfSmj7kMg92fHdpCnm+toKgG5Dlx0dxtgQNoOdlkN8fTmOlTuGNx',
}

file { '/etc/resolv.conf':
  ensure  => 'file',
  owner   => 'root',
  group   => 'root',
  mode    => '0644',
  content => 'search diegolima.org
nameserver 8.8.8.8
nameserver 8.8.4.4',
}

docker::swarm {'cluster_worker':
  join       => true,
  manager_ip => '35.226.110.84:2377',
  token      => 'SWMTKN-1-3pazf5uxpcubwizdx9j0b1rvuvqjam8gfelwrwegzoyym4izob-79rvi04pqx4xjdjqkn75j1kjs'
}

exec { 'create jenkins volume':
  command => 'docker volume create --driver local --opt type=nfs  --opt o=addr=vpn.diegolima.org,rw --opt device=:/srv/nfs/jenkins --name jenkins',
  unless  => 'docker volume ls|grep jenkins',
  require => Class['docker'],
}

exec { 'create nginx volume':
  command => 'docker volume create --driver local --opt type=nfs  --opt o=addr=vpn.diegolima.org,rw --opt device=:/srv/nfs/nginx --name nginx',
  unless  => 'docker volume ls|grep nginx',
  require => Class['docker'],
}
