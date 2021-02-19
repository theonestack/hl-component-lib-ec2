# security-group-rules CfHighlander Library

## Methods

### Security Group Rules

**Code**

```rb
generate_security_group_rules(security_group_rules,ip_blocks,ingress)
```

common way to set genertate security group rules on a security group resource 

```ruby
EC2_SecurityGroup(:SecurityGroup) do
  GroupDescription "my security group for ip whitelisting"
  VpcId Ref(:VPCId)
  SecurityGroupIngress generate_security_group_rules(security_group_rules['ingress'], ip_blocks, true)
  SecurityGroupEgress generate_security_group_rules(security_group_rules['egress'], ip_blocks, false)
end
```

**Configuration**

`ip_blocks` - Hash of ip cidrs, referenced by key in security group rules

```yaml
ip_blocks:
  local:
    - 127.0.0.1/32
    - 127.0.0.2/32
  public:
    - 0.0.0.0/0
```

descriptions can be placed on individal ips in an ip block by using the following syntax. 
The description provided in the ip block will override any description placed on the security group rule.

```yaml
ip_blocks:
  local:
    - ip: 127.0.0.1/32
      desc: localhost access
  public:
    - ip: 0.0.0.0/0
      desc: public access
```

`security_group_rules` - list of rules from config

```yaml
security_group_rules:
  ingress:
    -
      from: 80
      ip: 0.0.0.0/0
      desc: Public HTTP access
    -
      from: 30000
      to: 65535
      ip_blocks:
        - local
      desc: ECS ephemeral dynamic port mappings
    -
      from: 443
      ip_blocks:
        - public
      desc: Public HTTPS access
    -
      from: 22
      protocol: tcp
      security_group_id: sg-fqerekjrhr
      desc: ssh access from another security group
    -
      from: 3389
      protocol: tcp
      prefix_list: pl-123456789
      desc: rdp access from a prefix list
  egress:
    - 
      from: '-1'
      protocol: '-1'
      ip: 0.0.0.0/0
      desc: allow all egress traffic
```