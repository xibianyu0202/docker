#!/bin/bash -xv
while :
do
clear
read -p "
a.安装Nginx
b.配置Nginx
c.数据监控
d.安全监测
e.带进度条的复制
f.结束
:" A


##执行选项a
##安装Nginx
if [ $A == a ];then  

##检查YUM是否正常
yum clean all &>/dev/null
YUM=`yum repolist | awk '/repolist/{print $2}' | sed 's/,//'`
if [ $YUM -eq 0 ];then
	echo Yum检查失败
	exit
else
	echo Yum检查成功


##安装Nginx需要依赖包
echo 安装依赖包中
yum -y install gcc openssl-devel pcre-devel &>/dev/null
 if [ `echo $?` -ne 0 ];then
	rpm -q gcc openssl-devel pcre-devel
 	exit
 else
	rpm -q gcc openssl-devel pcre-devel
 fi
echo Nginx依赖包安装完成
sleep 2


##编译并安装Nginx
echo 安装Nginx中
tar -xf $PWD/nginx-1.12.2.tar.gz &>/dev/null
[ `echo $?` -ne 0 ]&&echo -e"解压错误,当前目录下无安装包\n"&&ls $PWD&&exit
cd nginx-1.12.2 
./configure &>/dev/null
make &>/dev/null
make install &>/dev/null
ls /usr/local/nginx/ &>/dev/null
[ `echo $?` -ne 0 ]&&echo 安装失败&&exit
echo Nginx安装成功
fi

echo


elif [ $A == b ];then  


##执行选项b
##Nginx的控制
while :
do
clear
read -p "Nginx服务选项
1.启动
2.关闭
3.重启
4.查看
5.结束

:" Ng


##根据用户的选择给出回应
if [ $Ng -eq 1 ];then
 echo 启动服务
 /usr/local/nginx/sbin/nginx
 [ `echo $?` -ne 0 ]&&echo 启动失败
 sleep 0.1

elif [ $Ng -eq 2 ];then
 echo 关闭服务
 /usr/local/nginx/sbin/nginx -s stop
 [ `echo $?` -ne 0 ]&&echo 关闭失败
 sleep 0.1

elif [ $Ng -eq 3 ];then
 echo 重启服务
 /usr/local/nginx/sbin/nginx -s stop
 /usr/local/nginx/sbin/nginx 
 [ `echo $?` -ne 0 ]&&echo 重启失败
 sleep 0.1

elif [ $Ng -eq 4 ];then
 #查看运行列表中是否存在nginx
 netstat -tunlp | grep -q nginx 
 if [ `echo $?` -eq 0 ];then
	echo 服务已启动
 	sleep 0.1
 else
	echo 服务未启动
 	sleep 0.1
 fi
 
 [ `echo $?` -ne 0 ]&&echo 查看失败

elif [ $Ng -eq 5 ];then
	break

else
 echo "请输入数字[1-4]"
 sleep 0.1
 
fi
echo
sleep 1.5
done


##执行选项c
##数据监控

elif [ $A == c ];then  
while :
do
clear
read -p '
1.查看CPU负载
2.查看网卡流量
3.查看内存信息
4.查看磁盘空间
5.查看计算机账户数量
6.查看登录账户数量
7.查看已安装软件包数量
8.查看已启动进程数
9.查看当前计算机时间
0.退出
:' B
if [ $B -eq 1 ];then
cpu=`uptime | awk '{print $9}' | sed 's/,//'`
echo "CPU每分钟负载为：$cpu"

elif [ $B -eq 2 ];then
eth0=`ifconfig eth0 | awk '/TX p|RX p/{print $5}'`
echo "出入站流量分别为：$eth0"

elif [ $B -eq 3 ];then
Mem=`free -h | awk '/Mem/{print $4}'`
echo "剩余可用内存：" $Mem

elif [ $B -eq 4 ];then
df=`df -h / | awk '/\//{print $4}'`
echo "剩余可用磁盘：" $df

elif [ $B -eq 5 ];then
user=`cat /etc/passwd | wc -l`
echo "计算机账户数量为：" $user 位

elif [ $B -eq 6 ];then
who=`who | wc -l`
echo "登录用户数量：" $who

elif [ $B -eq 7 ];then
bc=`rpm -qa | wc -l`
echo "已安装软件包数量：" $bc

elif [ $B -eq 8 ];then
ps=`ps aux | wc -l`
echo "已启动进程数为：" $ps

elif [ $B -eq 9 ];then
date=`date +%c`
echo "当前时间为：" $date

elif [ $B -eq 0 ];then
break

else
echo "请输入[0-9]进行选择"
fi
echo
echo
sleep 1
done

##执行选项d
##安全监测脚本
elif [ $A == d ];then  
echo "账户名登录失败：
" `awk '/Invalid user/{print $10}' /var/log/secure`
echo

echo "密码登录失败：
" `awk '/Failed/{ps[$11]++}END{for(i in ps){print i,"失败次数",ps[i]}}' /var/log/secure`
echo
echo

##统计错误超过3次的IP
cw=`awk '/Failed/{ps[$11]++}END{for(i in ps){print i,"失败次数",ps[i]}}' /var/log/secure | awk '$3>3{print $1}'`

echo "登录错误超过3次的有：
" $cw
read -p "是否禁止登录" IPB
[ -z $IPB ]&&echo '请输入(Yes/No)'&&break
if [ $IPB == yes ];then
for bk in $cw
do
firewall-cmd --permanent --zone=block --add-source=$bk
done
fi


##执行选项f
##带进度条的复制
elif [ $A == e ];then  
read -p "需要复制文件：" HH
read -p "复制到那？" HZ
jbdu(){
while :
do
echo -ne "\033[45m  \033[0m"
	sleep 0.05
done
}
if [ -n $HH ]&&[ -n $HZ ];then
jbdu &
cp -r $HH $HZ
echo 
echo "复制完成" 
kill $!

else 
	echo "请输入正确路径"
fi

elif [ $A == f ];then
exit

else
echo "请输入指定的字母"

fi
done
