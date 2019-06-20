ec2_vpc { 'puppet-vpc':
  ensure       => present,
  region       => 'us-east-1',
  cidr_block   => '10.0.0.0/16',
}


ec2_securitygroup { 'puppet-sg':
  ensure      => present,
  region      => 'us-east-1',
  vpc         => 'puppet-vpc',
  description => 'Security group for VPC',
  ingress     => [{
    security_group => 'puppet-sg',
  },{
    protocol => 'tcp',
    port     => 22,
    cidr     => '0.0.0.0/0'
  },{
    protocol => 'tcp',
    port     => 80,
    cidr     => '0.0.0.0/0'
  },{
    protocol => 'tcp',
    port     => 8080,
    cidr     => '0.0.0.0/0'
  },{
    protocol => 'tcp',
    port     => 443,
    cidr     => '0.0.0.0/0'
}]
}
ec2_vpc_subnet { 'puppet-public-subnet':
  ensure                  => present,
  region                  => 'us-east-1',
  vpc                     => 'puppet-vpc',
  cidr_block              => '10.0.0.0/24',
  availability_zone       => 'us-east-1a',
  map_public_ip_on_launch => true,
  route_table             => 'puppet-public-routes',
}

ec2_vpc_internet_gateway { 'puppet-igw':
  ensure => present,
  region => 'us-east-1',
  vpc    => 'puppet-vpc',
}

ec2_vpc_routetable { 'puppet-public-routes':
  ensure => present,
  region => 'us-east-1',
  vpc    => 'puppet-vpc',
  routes => [
    {
      destination_cidr_block => '10.0.0.0/24',
      gateway                => 'puppet-public-subnet'
    },{
      destination_cidr_block => '0.0.0.0/0',
      gateway                => 'puppet-igw'
    },
  ],
}
ec2_instance { 'pubilc-instance':
  ensure            => running,
  region            => 'us-east-1',
  availability_zone => 'us-east-1a',
  image_id          => 'ami-0015b9ef68c77328d',
  instance_type     => 't2.micro',
  key_name          => 'puppet',
  subnet            => 'puppet-public-subnet',
  security_groups   => ['puppet-sg'],
  user_data         => template('/etc/puppetlabs/code/environments/production/modules/newaws/templates/webserver.erb'),
  tags              => {
    tag_name => 'puppet',
  },
}


