#!/bin/bash
read -p "
1.创建虚拟机
2.分配密钥
3.删除虚拟机
输入数字:" a

read -p "虚拟机数量：" num
if [ $a -eq 1 ];then

read -p "虚拟机编号：" snum
read -p "IP地址：" ip 
 st=$snum
 si=$snum    #配置不同编号的网卡
 host=${ip##*.} #ip的主机位
 net=${ip%.*}   #ip的网络位默认的24
  for i in `seq $num`
  do
expect << EOF
 spawn clone-vm7
 expect "number:" {send "${st}\r"}
 expect "#" 	 {send "echo haha\r"}
EOF
  
 virsh start rh7_node${st}
 let st++
  done
 echo "正在开启虚拟机..."
 sleep 12

 for i in `seq $num` ##循环配置网卡
 do
expect << EOF
 spawn virsh console rh7_node${si}
 expect " "     		{send "\r"}
 expect "login:"         {send "root\r"}
 expect "："		{send "123456\r"}
 expect "#"              {send "nmcli connection modify eth0 ipv4.method manual ipv4.addresses ${net}.${host}/24 connection.autoconnect yes \r"}
 expect "#"		{send "nmcli connection up eth0\r"}
 expect "#"		{send "hostnamectl set-hostname mysql${si}\r"}
 expect "#"		{send "yum-config-manager --add http://${net}.254/rhel7/ \r"}
 expect "#"		{send "echo gpgcheck=0 >> /etc/yum.repos.d/${net}.254_rhel7_.repo \r"}
 expect "#"		{send "\035"}
 expect "#" 	 	 {send "exit\r"}
EOF
 let si++
 let host++
 done
 
elif [ $a -eq 2 ];then
 #rm -rf /root/.ssh/id_rsa
 #ssh-keygen -f /root/.ssh/id_rsa -N ''
 read -p "IP地址：" ip 
 host=${ip##*.}
 net=${ip%.*}
 for i in `seq $num`
 do
expect << EOF 
 spawn ssh-copy-id ${net}.${host}
 expect "(yes/no)?"   {send "yes\r"}
 expect "password:" {send "123456\r"}
 expect "#" {send "\r"}
EOF
 scp /root/mysql-5.7.17.tar ${net}.${host}:/root/
 
let host++

  done

elif [ $a -eq 3 ];then
 read -p "虚拟机编号：" mm
  for i in `seq $num`
  do
  virsh destroy  rh7_node$mm
  virsh undefine rh7_node$mm
  rm -rf /var/lib/libvirt/images/rh7_node${mm}*
  let mm++
  done
else
  echo "1/2/3"
fi
