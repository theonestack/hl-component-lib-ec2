# security-group-rules CfHighlander Library

## Methods

```ruby
generate_security_group_rules(security_group_rules,ip_blocks)
```

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
```