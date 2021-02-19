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