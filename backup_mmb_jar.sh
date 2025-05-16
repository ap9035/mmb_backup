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

# 確保備份目錄存在
mkdir -p "$ARCHIVED_HOME"

# 取得當前時間戳記
TIMESTAMP=$(date +"%Y-%m-%d_%H:%M:%S")
HOSTNAME=$(hostname)
BACKUP_FILE="${HOSTNAME}-${TIMESTAMP}.tar.gz"
BACKUP_PATH="${ARCHIVED_HOME}/${BACKUP_FILE}"

# 請求使用者輸入備份註解
read -p "請輸入備份註解: " COMMENT

# 建立備份
echo "正在備份 $MMB_DEPLOY_HOME 下的 JAR 檔案..."
# 建立臨時目錄進行備份整理
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

# 複製目錄結構和 JAR 檔案到臨時目錄
find "$MMB_DEPLOY_HOME" -mindepth 2 -maxdepth 2 -name "*.jar" | while read -r jar_file; do
  rel_path=${jar_file#$MMB_DEPLOY_HOME/}
  dir_name=$(dirname "$rel_path")
  mkdir -p "$TEMP_DIR/$dir_name"
  cp "$jar_file" "$TEMP_DIR/$dir_name/"
done

# 從臨時目錄建立tar檔案
tar -czf "$BACKUP_PATH" -C "$TEMP_DIR" .

# 計算 MD5 值
MD5=$(md5sum "$BACKUP_PATH" | cut -d' ' -f1)
ID=${MD5:0:5}

# 更新備份清單
echo "$ID $BACKUP_PATH $TIMESTAMP \"$COMMENT\"" >> "$ARCHIVED_HOME/backup_list.txt"

echo "備份完成: $BACKUP_PATH"
echo "備份 ID: $ID"