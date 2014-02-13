#
# Cookbook Name:: mailman
# Recipe:: default
#
# Copyright 2013, CyberAgent, Inc.
#
# All rights reserved - Do Not Redistribute
#

package "mailman" do
  action :install
end

template "mm_cfg.py" do
  owner "root"
  group "mailman"
  mode 0644
  source "mm_cfg.py.erb"
  path "/etc/mailman/mm_cfg.py"
  notifies :restart, 'service[mailman]'
end

template "adm.pw" do
  owner "root"
  group "mailman"
  mode 0640
  source "adm.pw.erb"
  path "/etc/mailman/adm.pw"
end

template "creator.pw" do
  owner "root"
  group "mailman"
  mode 0640
  source "creator.pw.erb"
  path "/etc/mailman/creator.pw"
end

template "sitelist.cfg" do
  owner "root"
  group "mailman"
  mode 0644
  source "sitelist.cfg.erb"
  path "/etc/mailman/sitelist.cfg"
  notifies :restart, 'service[mailman]'
end

template "mailman.conf" do
  owner "root"
  group "root"
  mode 0644
  source "mailman.conf.erb"
  path "/etc/httpd/conf.d/mailman.conf"
  notifies :restart, 'service[mailman]'
end

admin    = "#{node['mailman']['admin']}"
password = "#{node['mailman']['password']}"

bash "create default list" do
  user "root"
  cwd "/etc/mailman"
  code <<-EOC
  /usr/lib/mailman/bin/check_perms -f
  /usr/lib/mailman/bin/genaliases
  ## make default list at the initial installation
  /usr/lib/mailman/bin/list_owners mailman
  if [ $? -eq 0 ]; then
    echo "do nothing"
  else
    touch /etc/mailman/virtual_aliases
    postmap /etc/mailman/virtual_aliases
    /usr/lib/mailman/bin/newlist -q mailman #{admin} #{password}
  fi
  EOC
end

service "mailman" do
  supports :status => true, :restart => true, :stop => true
  action [ :enable, :start ]
end
