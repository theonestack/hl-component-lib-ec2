require 'cfndsl'
require 'json'
require_relative '../ext/cfndsl/security_group'

context 'Allow for public 80 and 443 access' do
  include CfnDsl::Functions
  
  before(:each) do
    rules = [
      {
        'from' => 80,
        'ip' => '0.0.0.0/0',
        'desc' => 'Public HTTP access'
      },
      {
        'from' => 443,
        'ip' => '0.0.0.0/0',
        'desc' => 'Public HTTP access'
      }
    ]
    @compiled = generate_security_group_rules(rules,{})
  end
  
  it 'returns an array of rules' do
    expect(@compiled).to be_an_instance_of(Array)
  end
  
  it 'returns ToPort 80' do
    expect(@compiled[0][:ToPort]).to eq(80)
  end
  
  it 'returns FromPort 80' do
    expect(@compiled[0][:FromPort]).to eq(80)
  end
  
  it 'wraps the CidrIp in a Fn::Sub' do
    @compiled.each do |rule|
      expect(rule[:CidrIp].to_json).to eq({'Fn::Sub': '0.0.0.0/0'}.to_json)
    end
  end
  
  it 'wraps the Description in a Fn::Sub' do
    @compiled.each do |rule|
      expect(rule[:Description].to_json).to eq({'Fn::Sub'=>'Public HTTP access'}.to_json)
    end
  end
  
end