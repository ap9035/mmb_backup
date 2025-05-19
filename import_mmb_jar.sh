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
  # 若不存在，則建立備份清單檔案
  touch "$BACKUP_LIST"
  echo "已建立新的備份清單檔案: $BACKUP_LIST"
fi

# 檢查輸入的檔案路徑
if [ -z "$1" ]; then
  echo "用法: $0 <備份檔案路徑>"
  exit 1
fi

IMPORT_FILE="$1"

if [ ! -f "$IMPORT_FILE" ]; then
  echo "檔案不存在: $IMPORT_FILE"
  exit 1
fi

# 檢查是否為 tar.gz 檔案
if [[ "$IMPORT_FILE" != *.tar.gz ]]; then
  echo "檔案必須是 tar.gz 格式: $IMPORT_FILE"
  exit 1
fi

# 檢查備份檔案的有效性
echo "正在檢查備份檔案的完整性..."
if ! tar -tzf "$IMPORT_FILE" &> /dev/null; then
  echo "備份檔案已損壞或格式不正確"
  exit 1
fi

# 請求使用者輸入備份註解
read -p "請輸入備份註解: " COMMENT

# 建立新的檔名
TIMESTAMP=$(date +"%Y-%m-%d_%H:%M:%S")
HOSTNAME=$(hostname)
BACKUP_FILE="${HOSTNAME}-${TIMESTAMP}.tar.gz"
BACKUP_PATH="${ARCHIVED_HOME}/${BACKUP_FILE}"

# 複製檔案到備份目錄
echo "正在匯入備份檔案..."
cp "$IMPORT_FILE" "$BACKUP_PATH"

if [ $? -ne 0 ]; then
  echo "匯入備份檔案失敗"
  exit 1
fi

# 計算新匯入檔案的 MD5 值
MD5=$(md5sum "$BACKUP_PATH" | cut -d' ' -f1)
ID=${MD5:0:5}

# 更新備份清單
echo "$ID $BACKUP_PATH $TIMESTAMP \"$COMMENT\"" >> "$BACKUP_LIST"

echo "備份檔案已成功匯入系統"
echo "備份 ID: $ID"
echo "備份檔案位置: $BACKUP_PATH"
echo "備份註解: $COMMENT"

# 詢問是否要安裝這個版本
read -p "是否要立即安裝這個版本? (y/n): " INSTALL
if [ "$INSTALL" = "y" ] || [ "$INSTALL" = "Y" ]; then
  # 使用臨時目錄解壓檔案
  TEMP_DIR=$(mktemp -d)
  trap 'rm -rf "$TEMP_DIR"' EXIT
  
  echo "正在解壓備份檔案..."
  tar -xzf "$BACKUP_PATH" -C "$TEMP_DIR"
  
  echo "正在安裝 JAR 檔案..."
  # 確保目標目錄存在
  find "$TEMP_DIR" -name "*.jar" | while read -r jar_file; do
    rel_path=${jar_file#$TEMP_DIR/}
    target_dir=$(dirname "$MMB_DEPLOY_HOME/$rel_path")
    mkdir -p "$target_dir"
    cp "$jar_file" "$target_dir/"
    echo "安裝: $rel_path"
  done
  
  echo "安裝完成。"
else
  echo "備份已匯入但未安裝。使用 install_mmb_jar.sh $ID 進行安裝。"
fi