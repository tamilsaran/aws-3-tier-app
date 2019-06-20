ec2_vpc_subnet { 'puppet-private1-subnet':
  ensure => present,
  region            => 'us-east-1',
  vpc               => 'puppet-vpc',
  cidr_block        => '10.0.2.0/24',
  availability_zone => 'us-east-1c',
  route_table       => 'puppet-private1-routes',
}

ec2_vpc_routetable { 'puppet-private1-routes':
  ensure => present,
  region => 'us-east-1',
  vpc    => 'puppet-vpc',
  routes => [
    {
      destination_cidr_block => '10.0.2.0/24',
      gateway                => 'puppet-private1-subnet'
    },{
      destination_cidr_block => '0.0.0.0/0',
      gateway                => 'nat gateway',

    },
  ],
}


ec2_securitygroup { 'rds-mysql-group':
  ensure           => present,
  region           => 'us-east-1',
  vpc              => 'puppet-vpc',
  description      => 'Group for Allowing access to mysql (Port 3306)',
  ingress          => [{
    security_group => 'rds-mysql-group',
  },{
    protocol => 'tcp',
    port     => 3306,
    cidr     => '0.0.0.0/0',
  }]
}

rds_db_securitygroup { 'rds-mysql-db_securitygroup':
  ensure      => present,
  region      => 'us-east-1',
  description => 'An RDS Security group to allow mysql',
}
rds_db_subnet_group { 'rdssubnetgroup':
  name        => 'rdssubnetgroup',
  ensure      => present,
  region      => 'us-east-1',
  vpc         => 'puppet-vpc',
  subnets     => [ 'puppet-public-subnet', 'puppet-private1-subnet', ],
  description => 'An RDS Security group to allow mysql',

}

rds_instance { 'puppetlabs-aws-mysql':
  ensure                       => present,
  allocated_storage            => '20',
  db_instance_class            => 'db.t2.micro',
  db_name                      => 'java',
  engine                       => 'mysql',
  license_model                => 'general-public-license',
  vpc_security_groups          => 'rds-mysql-group',
  db_subnet                    => 'rdssubnetgroup',
  master_username              => 'root',
  master_user_password         => 'zippyops345',
  region                       => 'us-east-1',
  skip_final_snapshot          => 'true',
  storage_type                 => 'gp2',
}

