#!/bin/bash
if [ -f "$1" ]
	then
		echo "文件存在,开始处理"
		for count in ERROR WARN INFO
		do
		echo "$count: $(grep -c "$count" "$1")"
		done
	else
		echo "文件不存在"
fi
