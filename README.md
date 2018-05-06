# Deploy OpenStack with kickstart and ansible

本文根据OpenStack[官方指南][1]，使用[ansible](https://www.ansible.com/)自动化安装部署Openstack环境。所有Openstack的节点均在虚拟机上部署。

本文部署的OpenStack环境如下：

eth0: management interface
eth1: provider interface (No IP address assigned to it)
eth2: overlay interface

## Prepare environment

部署静态文件webserver，以及初始化

    ./init.sh

安装虚拟机，以下步骤可以开多个窗口并行处理

    ./boot.sh controller
    ./boot.sh compute0
    ./boot.sh compute1
    ./boot.sh network

所有节点安装公共rpm包，这一步可能会执行很长一段时间，因为要进行yum update

    source devstack.rc
    ansible-playbook common/packages.yml

### Controller

    source devstack.rc
    cd controller
    ansible-playbook site.yml

### Compute

    source devstack.rc
    cd compute
    ansible-playbook site.yml


### Network

    source devstack.rc
    cd network
    ansible-playbook site.yml


[1](https://docs.openstack.org/install-guide)
