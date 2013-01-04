#
# Cookbook Name:: batch-packages
# Recipe:: default
#
# Copyright 2012, AT&T Foundry
#
# All rights reserved 

# get list of available package collections
bags = data_bag("batch-packages")

# get list of roles applied to this node
roles = node['roles'].dup
# add the 'base' role that all nodes receive
roles.insert(0, "base")

# get the intersection of roles and available package collections
needed = roles & bags
Chef::Log.info "Installing packages: #{needed}"

# install packages for each collection
needed.each do |role|
  pkglist = search("batch-packages", "id:#{role}").first
  if pkglist then
    packages = pkglist['packages'] || {}
    packages.each do |p, v|
      if v then
        Chef::Log.info "Installing package #{p}=#{v}..."
        package p do
          version v
          action :install
        end
      else
        Chef::Log.info "Installing package #{p}..."
        package p do
          action :install
        end
      end
    end
    gem_packages = pkglist['gem_packages'] || {}
    gem_packages.each do |p,v|
      Chef::Log.info "Installing ruby package #{p}..."
      if v then
        gem_package p do
          version v
          action :install
        end
      else
        gem_package p do
          action :install
        end
      end
    end
  end
end
