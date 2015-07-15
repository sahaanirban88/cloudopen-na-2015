register:
  module.run:
    - name: boto_elb.register_instances
    - m_name: mywebapp
    - instances:
      - {{ grains['ec2']['instance_id'] }}
