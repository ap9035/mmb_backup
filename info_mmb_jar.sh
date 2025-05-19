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
  echo "用法: $0 <備份ID|current>"
  exit 1
fi

ID=$1

# 如果是current選項，顯示當前JAR檔案資訊
if [ "$ID" = "current" ]; then
  # 使用column命令格式化表格輸出
  (
    # 輸出表頭
    echo -e "檔案路徑\tMD5SUM\t修改時間"
    echo -e "-----------------------------------------------------\t--------------------------------\t--------------------"

    # 找出所有當前的 JAR 檔案並顯示其 MD5SUM 和修改時間
    find "$MMB_DEPLOY_HOME" -name "*.jar" | sort | while read -r jar_file; do
      rel_path=${jar_file#$MMB_DEPLOY_HOME/}
      rel_path="MMBService/$rel_path"
      md5=$(md5sum "$jar_file" | cut -d' ' -f1)
      mtime=$(ls -al "$jar_file" | awk '{print $6" "$7" "$8}')
      echo -e "$rel_path\t$md5\t$mtime"
    done
  ) | column -t -s $'\t' | sed 's/^/  /'

  echo ""
  echo "當前系統中的JAR檔案 (來自 $MMB_DEPLOY_HOME)"
  exit 0
fi

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

# 建立臨時目錄
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

# 解壓縮備份檔案到臨時目錄
echo "正在分析備份檔案: $BACKUP_FILE"
tar -xzf "$BACKUP_FILE" -C "$TEMP_DIR"

# 使用column命令格式化表格輸出
(
  # 輸出表頭
  echo -e "檔案路徑\tMD5SUM\t修改時間"
  echo -e "-----------------------------------------------------\t--------------------------------\t--------------------"

  # 找出所有 JAR 檔案並顯示其 MD5SUM 和修改時間
  find "$TEMP_DIR" -name "*.jar" | sort | while read -r jar_file; do
    rel_path=${jar_file#$TEMP_DIR/}
    md5=$(md5sum "$jar_file" | cut -d' ' -f1)
    mtime=$(ls -al "$jar_file" | awk '{print $6" "$7" "$8}')
    echo -e "$rel_path\t$md5\t$mtime"
  done
) | column -t -s $'\t' | sed 's/^/  /'

# 顯示備份資訊
echo ""
echo "備份 ID: $ID"
echo "備份檔案: $(basename "$BACKUP_FILE")"
echo "備份註解: $(grep "^$ID " "$BACKUP_LIST" | cut -d'"' -f2)"
