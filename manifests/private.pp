ec2_vpc_subnet { 'puppet-private-subnet':
  ensure => present,
  region            => 'us-east-1',
  vpc               => 'puppet-vpc',
  cidr_block        => '10.0.1.0/24',
  availability_zone => 'us-east-1b',
 # map_public_ip_on_launch => true,
  route_table       => 'puppet-private-routes',
}

ec2_vpc_routetable { 'puppet-private-routes':
  ensure => present,
  region => 'us-east-1',
  vpc    => 'puppet-vpc',
  routes => [
    {
      destination_cidr_block => '10.0.1.0/24',
      gateway                => 'puppet-private-subnet'
    },{
      destination_cidr_block => '0.0.0.0/0',
      gateway                => 'nat gateway',
      
    },
  ],
}
ec2_instance { 'private-instance':
  ensure                    => running,
  private_ip_address        => '10.0.1.10',
  region                    => 'us-east-1',
  availability_zone         => 'us-east-1b',
  image_id                  => 'ami-0015b9ef68c77328d',
  instance_type             => 't2.micro',
  key_name                  => 'puppet',
  subnet                    => 'puppet-private-subnet',
  security_groups           => ['puppet-sg'],
  user_data                 => template('/etc/puppetlabs/code/environments/production/modules/newaws/templates/application.erb'),
  tags              => {
    tag_name => 'puppet',
  },
}


