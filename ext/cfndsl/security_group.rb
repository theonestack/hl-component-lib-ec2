def generate_security_group_rules(security_group_rules,ip_blocks={},ingress=true)
  rules = []
  security_group_rules.each do |rule|
    ips = []

    if rule.has_key?('ip_blocks')
      rule['ip_blocks'].each { |block| (ips.concat(ip_blocks[block])).uniq }
    elsif rule.has_key?('ip')
      ips.push(rule['ip'])  
    end

    sg_rule = {}
    sg_rule[:FromPort] = rule['from']
    sg_rule[:IpProtocol] = (rule.has_key?('protocol') ? rule['protocol'] : 'TCP')
    sg_rule[:ToPort] = (rule.has_key?('to') ? rule['to'] : rule['from'])
    sg_rule[:Description] = FnSub(rule['desc']) if rule.has_key?('desc')

    if ips.any?
      ips.each do |ip|
        ip_sg_rule = sg_rule.clone

        if ip.is_a?(Hash) && ip.has_key?('ip')
          ip_sg_rule[:CidrIp] = FnSub("#{ip['ip']}")
          ip_sg_rule[:Description] = FnSub(ip['desc']) if ip.has_key?('desc')
        elsif ip.is_a?(String)
          ip_sg_rule[:CidrIp] = FnSub("#{ip}")
        else
          puts "Cannot attach ip to security group, incorrect format #{ip.is_a?(Hash)}"
          next
        end

        rules.push(ip_sg_rule)
      end
    end
    
    if rule.has_key?('security_group_id')
      id_sg_rule = sg_rule.clone
      if ingress
        id_sg_rule[:SourceSecurityGroupId] = FnSub(rule['security_group_id'])
      else
        id_sg_rule[:DestinationSecurityGroupId] = FnSub(rule['security_group_id'])
      end
      rules.push(id_sg_rule)
    end

    if rule.has_key?('prefix_list')
      id_sg_rule = sg_rule.clone
      if ingress
        id_sg_rule[:SourcePrefixListId] = rule['prefix_list']
      else
        id_sg_rule[:DestinationPrefixListId] = rule['prefix_list']
      end
      rules.push(id_sg_rule)
    end
    
  end

  return rules
end

def create_security_group(name, vpc_id, description,ingress_rules=[], export_name=nil)
  EC2_SecurityGroup(name) do
    VpcId vpc_id
    GroupDescription description
    Metadata({
      cfn_nag: {
        rules_to_suppress: [
          { id: 'F1000', reason: 'ignore egress for now' }
        ]
      }
    })
  end
  Output(name) do
    Value(Ref(name))
    Export FnSub(export_name) unless export_name.nil?
  end
  ingress_rules.each_with_index do |ingress_rule, i|
    EC2_SecurityGroupIngress("#{name}IngressRule#{i+1}") do
      Description ingress_rule['desc'] if ingress_rule.has_key?('desc')
      if ingress_rule.has_key?('cidr')
        CidrIp ingress_rule['cidr']
      else
        SourceSecurityGroupId ingress_rule.has_key?('source_sg') ? ingress_rule['source_sg'] :  Ref(name)
      end
      GroupId ingress_rule.has_key?('dest_sg') ? ingress_rule['dest_sg'] : Ref(name)
      IpProtocol ingress_rule.has_key?('protocol') ? ingress_rule['protocol'] : 'tcp'
      FromPort ingress_rule['from']
      ToPort ingress_rule.has_key?('to') ? ingress_rule['to'] : ingress_rule['from']
    end
  end
end