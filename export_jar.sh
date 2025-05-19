#!/bin/bash

# 引入環境變數配置文件
source "$(dirname "$0")/mmb_config.env"

# 檢查是否設定必要的環境變數
if [ -z "$MMB_DEPLOY_HOME" ]; then
  echo "請設定 MMB_DEPLOY_HOME 環境變數"
  exit 1
fi

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

# 檢查是否提供備份 ID
if [ -z "$1" ]; then
  echo "用法: $0 <備份ID>"
  exit 1
fi

ID=$1

# 從備份清單中查找對應的備份檔案
BACKUP_FILE=$(grep "^$ID " "$BACKUP_LIST" | awk '{print $2}')

if [ -z "$BACKUP_FILE" ]; then
  echo "找不到 ID 為 $ID 的備份"
  exit 1
fi

if [ ! -f "$BACKUP_FILE" ]; then
  echo "備份檔案不存在: $BACKUP_FILE"
  exit 1
fi

# 顯示備份資訊
BACKUP_FILENAME=$(basename "$BACKUP_FILE")
BACKUP_COMMENT=$(grep "^$ID " "$BACKUP_LIST" | cut -d'"' -f2)

echo "備份 ID: $ID"
echo "原始備份檔案: $BACKUP_FILENAME"
echo "備份註解: $BACKUP_COMMENT"

# 提示使用者輸入輸出檔名
read -p "請輸入輸出檔名 (預設: $BACKUP_FILENAME): " OUTPUT_FILENAME
OUTPUT_FILENAME=${OUTPUT_FILENAME:-$BACKUP_FILENAME}

# 檢查檔案是否已存在
if [ -f "$OUTPUT_FILENAME" ]; then
  read -p "檔案 $OUTPUT_FILENAME 已存在，是否覆蓋? (y/n): " OVERWRITE
  if [ "$OVERWRITE" != "y" ] && [ "$OVERWRITE" != "Y" ]; then
    echo "匯出已取消"
    exit 1
  fi
fi

# 複製備份檔案到當前目錄
echo "正在匯出備份檔案..."
cp "$BACKUP_FILE" "$OUTPUT_FILENAME"

if [ $? -eq 0 ]; then
  echo "備份檔案已成功匯出至: $OUTPUT_FILENAME"
else
  echo "匯出失敗"
  exit 1
fi