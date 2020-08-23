# 安装步骤

仅作记录

## 安装whmcs拓展
把SolusVM-NAT文件夹放在/modules/addons中

编辑solusvm_nat模块中的version.php

将文件中的网址改为您的网址，不加“http://”或者“https://”

保存后就可以到后台看下过授权步骤了

## 主控扩展安装

获得扩展 API 文件

该文件在 solusvm-nat/scripts/extend_api.php

请复制该文件到您的solusvm主控 /usr/local/solusvm/www 下

最好推荐在该目录新建目录存放该扩展 API 文件

生成通讯密钥

登陆主控，切换到扩展 API 文件所在文件夹,

执行命令：`php extend_api.php`


测试是否安装成功

使用浏览器访问扩展 API 文件 (/usr/local/solusvm/www 为网站根目录), 如果成功将出现以下内容

    {"result":"error","error":"key error"}

## 安装solusvm被控

自己先做好授权

创建网桥 natbr0：`brctl addbr natbr0`

然后 `vi /etc/sysconfig/network-scripts/ifcfg-natbr0`

写入下面内容

    DEVICE=natbr0
    TYPE=Bridge
    BOOTPROTO=static
    IPADDR=10.111.111.1（可以改成其他的内网段）
    NETMASK=255.255.255.0
    ONBOOT=yes

保存 重启网络

查看是否开启包转发：`sysctl net.ipv4.ip_forward`

输出1就是代表有，一般安装solusvm会自动开的

开启端口转发

    iptables -t nat -A POSTROUTING -s '10.111.111.0/24' -o 拥有公网IP的网卡名 -j MASQUERADE
    service iptables save
    service iptables restart

把solusvm面板里节点的KVM桥改成natbr0

把nat_check.php放到被控任意目录

新建个config.ini

    RPC_URL="https://xxxxx/modules/addons/solusvm_nat/rpc/node.php" 
    NIC="拥有公网IP的网卡名"
    SEGMENT="10.111.111.0/24"

测试配置是否正常

执行以下命令，查看命令回应是否如预期所示

`php nat_check.php`

命令预期回应

    Public interface: br0 (10.100.100.174)
    Intranet segment: 10.111.111.0/24
 
    !!! No nat forward rule found, clean all nat rules !!!
 
    Rules counter:
    New: 0
    Delete: 0
    Exist(s): 0



创建任务`crontab -e`

每一分钟php运行下nat_check.php

    */5 * * * * rm -f /usr/local/solusvm/data/.hosts
    */1 * * * * php -q /root/nat_check.php

## Solusvm 配置 noVNC

首先，修改solusvm中添加的节点的hostname为一个域名，并准备好这个域名的SSL证书

然后我们将SSL证书合并为PEM文件，在线合并工具https://www.myssl.cn/tools/merge-pem-cert.html

到主控（安装solusvm主控端的机器），添加一些东西具体操作如下：

`vi /usr/local/solusvm/data/config.ini`

添加以下内容

    [NOVNC]
    use_remote_hostname = true
    socket_dest_public = false

到被控修改hostname为你准备好的域名

`vi /usr/local/solusvm/includes/nvnc/cert.pem`

将你准备好的pem文件内容复制到这里即可

在被控上重启一下websocket

    sh /scripts/websocket-stop
    php /usr/local/solusvm/includes/wsocket.php

其实不用重启也可以，导入以后自动开启