#!/bin/bash
##修改vbr.xml文件,修改IP
##192.168.1.0网段会导致真机无法上网
##virsh start指令启动缓慢
img=/var/lib/libvirt/images/
net=/root/nsd1810/vbr.xml
node=/root/nsd1810/node.xml
dir=/etc/libvirt/qemu/

read -p "网卡：" h
h=${h:-no}
if [ $h == yes ];then
cp $net ${dir}networks/ 
virsh net-define ${dir}networks/vbr.xml
virsh net-start vbr
fi

read -p "虚拟机数量：" n
for i in `seq $n`
do 
read -p "虚拟机编号：" a
qemu-img create -b node.qcow2 -f qcow2 ${img}node${a}.img 20G
cp $node ${dir}node${a}.xml 
sed -i "s/node/node${a}/g" ${dir}node${a}.xml
virsh define ${dir}node${a}.xml
virsh start node${a}
done
