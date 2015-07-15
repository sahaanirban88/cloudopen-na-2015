register:
  module.run:
    - name: boto_elb.deregister_instances
    - m_name: mywebapp
    - instances:
      - {{ grains['ec2']['instance_id'] }}
