#!/bin/bash

# 引入環境變數配置文件
source "$(dirname "$0")/mmb_config.env"

# 檢查是否設定必要的環境變數
if [ -z "$ARCHIVED_HOME" ]; then
  echo "請設定 ARCHIVED_HOME 環境變數"
  exit 1
fi

# 檢查備份清單是否存在
BACKUP_LIST="$ARCHIVED_HOME/backup_list.txt"
if [ ! -f "$BACKUP_LIST" ]; then
  echo "找不到備份清單: $BACKUP_LIST"
  exit 1
fi

# 使用column命令格式化表格輸出
(
  # 輸出表頭
  echo -e "ID\t備份檔案\t時間戳記\t註解"
  echo -e "-----\t------------------------------------------------------------\t--------------------\t--------------------"
  
  # 輸出資料行
  while IFS=' ' read -r id path timestamp comment; do
    filename=$(basename "$path")
    echo -e "$id\t$filename\t$timestamp\t$comment"
  done <"$BACKUP_LIST"
) | column -t -s $'\t' | sed 's/^/  /'