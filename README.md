# Deploy OpenStack with kickstart and ansible

本文根据OpenStack[官方指南][1]，使用[ansible](https://www.ansible.com/)自动化安装部署Openstack环境。所有Openstack的节点均在虚拟机上部署。

本文部署的OpenStack环境如下：

eth0: management interface
eth1: provider interface (No IP address assigned to it)
eth2: overlay interface

## Prepare environment

部署静态文件webserver，以及初始化

    ./init.sh

安装虚拟机，以下步骤可以开多个窗口并行处理，如果需要重新安装操作系统，加`-d`选项: e.g. `./boot.sh -d controller`，也可以恢复到`init`快照, `./reset controller`

    ./boot.sh controller
    ./boot.sh compute0
    ./boot.sh compute1
    ./boot.sh network

所有节点安装公共rpm包，这一步可能会执行很长一段时间，因为要进行yum update

    source devstack.rc
    ansible-playbook common/packages.yml

## 部署 Controller/Compute/Network Node

设置环境变量，分别进入到controller, compute，network目录，运行`site.yml`，如下

    source devstack.rc && cd controller
    ansible-playbook site.yml


Verify
======

在controller节点，执行以下命令

```
# source adminrc
# openstack network agent list
+--------------------------------------+--------------------+------------+-------------------+-------+-------+---------------------------+
| ID                                   | Agent Type         | Host       | Availability Zone | Alive | State | Binary                    |
+--------------------------------------+--------------------+------------+-------------------+-------+-------+---------------------------+
| 1d87ee7d-128e-4450-9a24-d308833663c3 | Open vSwitch agent | network    | None              | :-)   | UP    | neutron-openvswitch-agent |
| 41d63c9b-b409-45ce-930f-dc3c6520aae1 | L3 agent           | network    | nova              | :-)   | UP    | neutron-l3-agent          |
| 44664ec2-336b-4f59-a2a5-eadbda906b5f | Open vSwitch agent | compute0   | None              | :-)   | UP    | neutron-openvswitch-agent |
| 44bd9e7d-8e63-45a6-bea2-b47a32e7762d | Open vSwitch agent | controller | None              | :-)   | UP    | neutron-openvswitch-agent |
| 48f4cec5-3225-4a8b-9ece-100ae963dc4f | Open vSwitch agent | compute1   | None              | :-)   | UP    | neutron-openvswitch-agent |
| 6df4f349-cfac-4845-854b-a9d35dfa181b | Metadata agent     | compute1   | None              | :-)   | UP    | neutron-metadata-agent    |
| 7b2308c4-a672-49cd-8f02-8d4987d0c6d3 | DHCP agent         | compute0   | nova              | :-)   | UP    | neutron-dhcp-agent        |
| bba1604e-997a-49a8-b8b4-6cf897626282 | Metadata agent     | compute0   | None              | :-)   | UP    | neutron-metadata-agent    |
| d9e814de-7b67-4ef7-bed0-7637c2cfe898 | DHCP agent         | compute1   | nova              | :-)   | UP    | neutron-dhcp-agent        |
+--------------------------------------+--------------------+------------+-------------------+-------+-------+---------------------------+
```

[1](https://docs.openstack.org/install-guide)
