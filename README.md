Deploy OpenStack with kickstart and ansible
===========================================

本文根据OpenStack[官方指南](1)，使用[ansible](https://www.ansible.com/)自动化安装部署Openstack环境。所有Openstack的节点均在虚拟机上部署，在物理机上应存在以下网络（接口）：

1. virbr10用于management network，如果所有Openstack节点都在同一台物理机上，可通过脚本通过[create-virbr10.sh](scripts/create-virbr10.sh)创建物理机上的dummy接口和网桥

2. br0，用于provider network

3. br-vxlan用于overlay network，可通过[create-vxlan.sh](scripts/create-vxlan.sh)创建物理机上的vxlan接口和网桥

以上三种网络分别对应Openstack虚拟机节点eth0, eth1, eth2

Prepare environment
===================

## 准备 Controller/Compute/Network VMs

部署静态文件webserver，以及初始化

    ./init.sh

安装虚拟机，以下步骤可以开多个窗口并行处理，如果需要重新安装操作系统，加`-d`选项: e.g. `./boot.sh -d controller`，也可以恢复到`init`快照, `./reset controller`

    ./boot.sh controller
    ./boot.sh compute0
    ./boot.sh compute1
    ./boot.sh network

    # 将Openstack RC文档拷入controller
    scp -i config/devstack config/adminrc config/demorc root@controller:~/


## 安装部署 Controller/Compute/Network VMs

所有节点安装公共rpm包，这一步可能会执行很长一段时间，因为要进行yum update

    source devstack.rc
    ansible-playbook common/packages.yml

分别进入到controller, compute，network目录，运行ansible play文件`site.yml`自动化部署所有VM，如下

    source devstack.rc #设置环境变量
    cd controller
    ansible-playbook site.yml

验证安装结果
============

(1) 在controller节点，执行以下命令

```
# source adminrc
# openstack network agent list
+--------------------------------------+--------------------+----------+-------------------+-------+-------+---------------------------+
| ID                                   | Agent Type         | Host     | Availability Zone | Alive | State | Binary                    |
+--------------------------------------+--------------------+----------+-------------------+-------+-------+---------------------------+
| 30b4f064-cc2b-4438-a084-6106e17327c2 | Metadata agent     | compute0 | None              | :-)   | UP    | neutron-metadata-agent    |
| 4cea125c-4299-4b51-b0cc-792b3d98ffd0 | DHCP agent         | compute1 | nova              | :-)   | UP    | neutron-dhcp-agent        |
| 5c59b9b5-7eee-4b84-a161-732636289a44 | Open vSwitch agent | compute0 | None              | :-)   | UP    | neutron-openvswitch-agent |
| 80117680-9a7b-496b-ba60-051086097fc6 | Metadata agent     | compute1 | None              | :-)   | UP    | neutron-metadata-agent    |
| 8a88c390-2909-47cc-a8d9-b18dcd09cf60 | L3 agent           | network  | nova              | :-)   | UP    | neutron-l3-agent          |
| c0feb8ee-a002-4064-96fa-a3e118269675 | Open vSwitch agent | network  | None              | :-)   | UP    | neutron-openvswitch-agent |
| daa482ff-8756-4cff-a918-a46558ccfcc9 | Open vSwitch agent | compute1 | None              | :-)   | UP    | neutron-openvswitch-agent |
| fe425712-dc93-4e2d-9cb7-068c832e025e | DHCP agent         | compute0 | nova              | :-)   | UP    | neutron-dhcp-agent        |
+--------------------------------------+--------------------+----------+-------------------+-------+-------+---------------------------+
```

(2) 访问Dashboard

在物理机上设置DNAT，假设物理机的地址为`10.95.30.13`其中Openstack Dashboard部署在controller节点192.168.100.10上，如下

    iptables -t nat -A PREROUTING -d 10.95.30.13/32 -p tcp -m tcp --syn -m multiport --dports 80,6080 -j DNAT --to-destination 192.168.100.10

在浏览器中访问 http://10.95.30.13/dashboard


初始化Openstack
===============

以上验证如果没问题，说明一个干净的OpenStack安装成功，但此问题没有任何网络，镜像等资源，因此资源的进行初始化

    # 进到netboot根目录，执行devstack.rc文件
    source devstack.rc
    ansible-playbook devstack_init.yml


创建虚拟机
----------

可以在dashboard创建


REFERENCE
=========

[1](https://docs.openstack.org/install-guide)
