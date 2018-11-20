test_name "Stop firewall" do
  skip_test 'not testing with puppetserver' unless @options['is_puppetserver']
  hosts.each do |host|
    case host['platform']
    when /debian/
      result = on(host, 'which iptables', accept_all_exit_codes: true)
      if result.exit_code == 0
        on host, 'iptables -F'
      else
        logger.notify("Unable to locate `iptables` on #{host['platform']}; not attempting to clear firewall")
      end
    when /fedora|el-7/
      on host, puppet('resource', 'service', 'firewalld', 'ensure=stopped')
    when /el-|centos/
      on host, puppet('resource', 'service', 'iptables', 'ensure=stopped')
    when /ubuntu/
      on host, puppet('resource', 'service', 'ufw', 'ensure=stopped')
    else
      logger.notify("Not sure how to clear firewall on #{host['platform']}")
    end
  end
end
