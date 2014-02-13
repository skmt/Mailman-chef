#
# Cookbook Name:: mailman
# Recipe:: default
#
# Copyright 2013, CyberAgent, Inc.
#
# All rights reserved - Do Not Redistribute
#

package "git" do
  action :install
end

template "mlbackup" do
  owner "root"
  group "root"
  mode 0755
  source "mlbackup.erb"
  path "/etc/cron.daily/mlbackup"
end

directory "/var/lib/mailman/backup" do
  owner "root"
  group "mailman"
  mode 0755
  action :create
end

##
## for git config and operation
##

directory "/root/.ssh" do
  owner "root"
  group "root"
  mode 0700
  action :create
end

cookbook_file "deploy_id_rsa" do
  action :create_if_missing
  source "deploy_id_rsa"
  owner "root"
  mode 0400
  path "/root/.ssh/deploy_id_rsa"
end

cookbook_file "ssh_wrapper.sh" do
  action :create_if_missing
  source "ssh_wrapper.sh"
  owner "root"
  mode 0700
  path "/root/.ssh/ssh_wrapper.sh"
end

git "mailman" do
  repository "#{node['mailman']['git_server']}:#{node['mailman']['git_repository']}"
  reference "master"
  user "root"
  destination "/var/lib/mailman/backup"
  action :sync
  ssh_wrapper "/root/.ssh/ssh_wrapper.sh"
end

bash "restore list" do
  user "root"
  cwd "/var/lib/mailman/backup"
  code <<-EOC
  ls -1 | while read list
  do
    if [ ${list} = "mailman" ]; then
      continue
    fi
    if [ -d /var/lib/mailman/lists/${list} ]; then
      continue
    fi
    /usr/lib/mailman/bin/newlist -q ${list} "`cat /var/lib/mailman/backup/${list}/${list}.owner | head -1`" password
    /usr/lib/mailman/bin/config_list -i /var/lib/mailman/backup/${list}/${list}.pck ${list}
    /usr/lib/mailman/bin/add_members -r /var/lib/mailman/backup/${list}/${list} ${list}
  done
  EOC
end
