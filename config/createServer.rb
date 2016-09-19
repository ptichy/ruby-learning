require 'aws-sdk'
require 'base64'

IMAGE_ID = 'ami-7172b611'
KEY_NAME = 'RubyKeyPair'
INSTANCE_NAME = 'rubyTestServer'
GROUP = 'MyRubyServers'

# User code that's executed when the instance starts
script = File.read("init.sh")
encoded_script = Base64.encode64(script)

ec2 = Aws::EC2::Resource.new(region: 'us-west-2')
 
puts 'Create security group for server...'
sg = ec2.create_security_group({
    group_name: 'SGForRubyServer',
    description: 'Security group for ruby servers'
  })

puts 'Open ports...'
sg.authorize_ingress({
  ip_permissions: [{
    ip_protocol: 'tcp',
    from_port: 22,
    to_port: 22,
    ip_ranges: [{
      cidr_ip: '0.0.0.0/0'
    }]
    },
    ip_protocol: 'tcp',
    from_port: 80,
    to_port: 80,
    ip_ranges: [{
      cidr_ip: '0.0.0.0/0'
    }]    
  ]
})
puts "Security group id: " + sg.id

puts 'Create key pair...'
key_pair = ec2.create_key_pair({key_name: KEY_NAME})

# Save it in user's home directory as RubyKeyPair.pem
filename = File.join(Dir.home, KEY_NAME + '.pem')
File.open(filename, 'w') { |file| file.write(key_pair.key_material) }

puts 'Create instance...'
instance = ec2.create_instances({
  image_id: IMAGE_ID,
  min_count: 1,
  max_count: 1,
  key_name: KEY_NAME,
  security_group_ids: [sg.id],
  user_data: encoded_script,
  instance_type: 't2.micro',
  placement: {
    availability_zone: 'us-west-2a'
  }
})

# Wait for the instance to be created, running, and passed status checks
ec2.client.wait_until(:instance_status_ok, {instance_ids: [instance[0].id]})

# Name the instance and give it the Group tag
instance.create_tags({ tags: [{ key: 'Name', value: INSTANCE_NAME }, { key: 'Group', value: GROUP }]})

puts "Instance(s):"
ec2.instances.each do |i|
  puts "ID:    #{i.id}"
  puts "State: #{i.state.name}"
  puts "IP address:  #{i.public_ip_address}"
end
