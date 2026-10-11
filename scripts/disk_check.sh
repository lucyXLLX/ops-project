#!/bin/bash

result=0

if [ -z "$1" ]
then
	echo "未输入阈值,请添加后重新运行"
	echo "$(date) 用户未输入阈值,脚本未执行" >> "$HOME/ops-project/logs/disk_check.log"
	result=1
else
	
	echo "用户输入的阈值为 $1" >> "$HOME/ops-project/logs/disk_check.log"
	if !  [[ "$1" =~ ^[0-9]+$ ]]
	then
		echo "输入的阈值非纯数字,请修改后重新运行"
		echo "用户输入的阈值为 $1 非纯数字,脚本未运行" >> "$HOME/ops-project/logs/disk_check.log"
		result=1
	else
		usage=$(df -h / | awk 'NR==2 {print $5}' | tr -d '%')

		echo "========磁盘检查开始========"

		echo "========$(date) 磁盘检查开始========" >> "$HOME/ops-project/logs/disk_check.log"

		echo "当前磁盘使用率为: ${usage}%"

		echo "$(date) 当前磁盘使用率为: ${usage}%" >> "$HOME/ops-project/logs/disk_check.log"

		if [ "$usage" -ge "$1" ]

		then 
			echo "磁盘使用率过高!"
			echo "$(date) 磁盘使用率过高!" >> "$HOME/ops-project/logs/disk_check.log"
			result=1
		else 	
	
			echo "磁盘使用率正常"
			echo "$(date) 磁盘使用率正常" >> "$HOME/ops-project/logs/disk_check.log"
	
		fi
	fi
	echo "========磁盘检查结束========"
	
	echo "========$(date) 磁盘检查结束========" >> "$HOME/ops-project/logs/disk_check.log"
fi
exit "$result"
