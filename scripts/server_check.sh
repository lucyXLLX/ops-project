#!/bin/bash

LOG_FILE="$HOME/ops-project/logs/server_check.log"
exec > >(tee -a "$LOG_FILE") 2>&1
disk_THRESHOLD=80

echo "======== $(date) 检查开始 ========"

host_check() {
	echo "[主机名]"
	hostname
	echo "[用户名]"
	whoami
	echo "[检查时间]"
	date
}

disk_check() {
	echo "[磁盘检查]"
	sum=$(df -h / | awk 'NR==2 {print $5}' | tr -d "%")
	echo "磁盘已用 ${sum}%"
	if [ "$sum" -ge "$disk_THRESHOLD" ]
	then
		echo "磁盘使用率过高"
		echo "当前阈值为: ${disk_THRESHOLD}%"
		return 1
	else
		echo "磁盘使用率正常"
		return 0
	fi
}

memory_check() {
	echo "[内存检查]"
	free -h	
}

service_check() {
	 if systemctl list-unit-files | grep -q "$1"
	 then
		 echo "$1 服务存在"
		 if systemctl is-active -q "$1"
		 then
			 echo "$1 服务正在运行"
			 return 0
		 else
			 echo "$1 服务没有运行,尝试重新启动服务"
			 sudo systemctl start "$1"
			 if systemctl is-active -q "$1"
			 then
			        echo "$1 服务启动成功"
				return 0
			 else
				echo "$1 服务启动失败" 
			 return 1
			 fi
		 fi
	 else
		 echo "$1 服务不存在"
		 return 1
	 fi
}


result=0


while getopts ":t:h" opt
do
	case "$opt" in
		t)
			if ! [[ "$OPTARG" =~ ^[0-9]+$ ]]
			then
				echo "阈值必须为纯数字"
				exit 1
			fi
			disk_THRESHOLD="$OPTARG"
			;;
		h)
			echo "用法:"
		     	echo "./server_check.sh [选项] [服务] [服务]"
			echo ""
			echo "选项:"
			echo "-t NUM      设置磁盘使用率阈值"
			echo "-h          显示帮助信息"
			echo ""
			echo "示例:"
			echo "./server_check.sh -t 80 nginx sshd"
			echo "./server_check.sh -h"
			exit 0
			;;		
		:)
			echo "选项 $OPTARG 后必须要有参数"
			exit 1
			;;
		?)
			echo "$OPTARG 未知参数"
			exit 1
			;;
	esac
done

shift $((OPTIND - 1))

host_check
memory_check
disk_check || result=1

echo "[服务检查]"
for service in "$@"
do
	service_check "$service" || result=1
done

echo "======== $(date) 检查结束 ========"
exit "$result"
