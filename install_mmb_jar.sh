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

# 確認還原操作
echo "將要從以下備份還原 JAR 檔案:"
echo "檔案: $BACKUP_FILE"
read -p "確定要繼續嗎? (y/n): " CONFIRM

if [ "$CONFIRM" != "y" ]; then
  echo "還原操作已取消"
  exit 0
fi

# 執行還原
echo "正在還原 JAR 檔案..."
# 建立臨時目錄
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

# 先解壓到臨時目錄
tar -xzf "$BACKUP_FILE" -C "$TEMP_DIR"

# 複製 JAR 檔案到目標位置
find "$TEMP_DIR" -name "*.jar" | while read -r jar_file; do
  dir_name=$(dirname "${jar_file#$TEMP_DIR/}")
  mkdir -p "$MMB_DEPLOY_HOME/$dir_name"
  echo "安裝 $jar_file 到 $MMB_DEPLOY_HOME/$dir_name/"
  cp "$jar_file" "$MMB_DEPLOY_HOME/$dir_name/"
done

echo "還原完成"