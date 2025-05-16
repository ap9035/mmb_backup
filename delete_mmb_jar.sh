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
  echo "備份檔案不存在: $BACKUP_FILE，但仍將移除紀錄"
fi

# 確認刪除操作
echo "將要刪除以下備份:"
echo "ID: $ID"
echo "檔案: $BACKUP_FILE"
COMMENT=$(grep "^$ID " "$BACKUP_LIST" | cut -d'"' -f2)
echo "註解: $COMMENT"
read -p "確定要刪除嗎? (y/n): " CONFIRM

if [ "$CONFIRM" != "y" ]; then
  echo "刪除操作已取消"
  exit 0
fi

# 刪除備份檔案
if [ -f "$BACKUP_FILE" ]; then
  rm -f "$BACKUP_FILE"
  echo "已刪除備份檔案: $BACKUP_FILE"
else
  echo "備份檔案不存在，無需刪除檔案"
fi

# 移除清單中的記錄
TEMP_FILE=$(mktemp)
grep -v "^$ID " "$BACKUP_LIST" > "$TEMP_FILE"
mv "$TEMP_FILE" "$BACKUP_LIST"
echo "已從備份清單中移除 ID 為 $ID 的記錄"

echo "刪除操作完成"