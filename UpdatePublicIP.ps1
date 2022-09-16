$publicIP = Invoke-RestMethod -Uri http://ifconfig.co -UserAgent "curl"
Write-Host 'Current Public IP: '$publicIP

# Write-Host 'Current Security Group Config: '
# Write-Host ($currentSecurityGroupInfo | Format-List | Out-String)
# Write-Host ($currentSecurityGroupInfo.IpPermissions | Format-List | Out-String)
# Write-Host ($currentSecurityGroupInfo.IpPermissions.Ipv4Ranges | Format-List | Out-String)

# $rule = [Amazon.EC2.Model.SecurityGroupRuleUpdate]::new()
# $rule.SecurityGroupRuleId = $currentSecurityGroupInfo.GroupId
# $rule.SecurityGroupRule = [Amazon.EC2.Model.SecurityGroupRuleRequest]::new()
# $rule.SecurityGroupRule.CidrIpv4 = $publicIP.Trim()

# $rule.SecurityGroupRule
$myFilter = [Amazon.EC2.Model.Filter]::new("tag:UpdatePublicIP", "true")

$TaggedRulesForUpdate = Get-EC2SecurityGroupRule -Region us-east-1 -Filter $myFilter
# Write-Host ($TaggedRulesForUpdate | Format-List | Out-String)

foreach ($rule in $TaggedRulesForUpdate) {
    # write-host ("{0} {1}" -f $rule.SecurityGroupRuleId, $rule.CidrIpv4)
    $UpdateRule = [Amazon.EC2.Model.SecurityGroupRuleUpdate]::new()
    $UpdateRule.SecurityGroupRuleId = $rule.SecurityGroupRuleId
    $UpdateRule.SecurityGroupRule = [Amazon.EC2.Model.SecurityGroupRuleRequest]::new()
    $UpdateRule.SecurityGroupRule.Description = $rule.Description
    $UpdateRule.SecurityGroupRule.CidrIpv4 = $publicIP.Trim()+'/32'
    $UpdateRule.SecurityGroupRule.FromPort = -1
    $UpdateRule.SecurityGroupRule.ToPort = -1
    $UpdateRule.SecurityGroupRule.IpProtocol = -1
    # write-host ($UpdateRule.SecurityGroupRuleId)
    # write-host ($UpdateRule.SecurityGroupRule| Format-List | Out-String)
    # write-host ($UpdateRule.SecurityGroupRule.CidrIpv4)
    $var = Edit-EC2SecurityGroupRule -Region us-east-1 -GroupId $rule.GroupId -SecurityGroupRule $UpdateRule
    Write-Host ("Updated Security Rule: "+$rule.SecurityGroupRuleId)
    Write-Host ("New Rule: ")
    Write-Host ($UpdateRule.SecurityGroupRule | Format-List | Out-String)
    Write-Host ("==============================================================")
}