#!/bin/bash

while getopts ":h" opt
do
	case "$opt" in
		h)
			echo "用法: ./log_analyze.sh <日志文件>"
			echo "示例: ./log_analyze.sh /home/baigei/ops-project/logs/server_check.log"
			exit 0
			;;
		?)
			echo "未知参数"
			exit 1
			;;
	esac
done


shift $((OPTIND - 1))


if [ "$#" -ne 1 ]
then
	echo "参数必须有且只有一个"
	echo "用法: ./log_analyze.sh <日志文件>"
	echo "示例: ./log_analyze.sh /home/baigei/ops-project/logs/server_check.log"
	exit 1
fi

LOG_FILE="$1"
if [ ! -f "$LOG_FILE" ]
then
	echo "文件不存在"
	exit 1
fi

echo "===== 日志分析开始 ====="
echo "分析时间 $(date)"
echo ""

disk_high="$(grep -c "过高" "$LOG_FILE")"
service_missing="$(grep -c "不存在" "$LOG_FILE")"
service_failed="$(grep -c "服务启动失败" "$LOG_FILE")"
total=$((disk_high + service_missing + service_failed))

echo "磁盘使用率过高: ${disk_high}次"
echo "服务不存在: ${service_missing}次"
echo "服务启动失败: ${service_failed}次"
echo "总异常次数为: ${total}次"
if [ $total -gt 3 ]
then
	echo "检查结果: 异常较多"
elif [ $total -eq 0 ]
then	
	echo "检查结果: 正常"
else
	echo "检查结果: 存在少量异常"
fi
echo ""
echo "===== 日志分析结束 ====="
