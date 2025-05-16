# MMB Backup 工具集

這是一套用於管理、備份和還原 MMB JAR 檔案的工具集。

## 功能特色

- 備份當前的 JAR 檔案
- 列出所有可用的備份
- 檢視備份詳細資訊
- 從備份還原 JAR 檔案
- 刪除不需要的備份

## 環境設定

使用前需要設定環境變數，這些變數在 `mmb_config.env` 檔案中定義：

- `MMB_DEPLOY_HOME`: JAR 檔案的部署目錄
- `ARCHIVED_HOME`: 備份檔案的儲存目錄

## 使用方法

### 備份 JAR 檔案

```
./backup_mmb_jar.sh
```

執行此命令後，系統會建立一個備份，並產生唯一的備份 ID。

### 列出所有備份

```
./list_mmb_jar.sh
```

顯示所有可用的備份清單，包含 ID、檔案名稱、時間戳記和備份註解。

### 檢視備份詳細資訊

```
./info_mmb_jar.sh <備份ID>
```

顯示指定備份的詳細資訊，包含備份中的 JAR 檔案清單、MD5 檢查碼和修改時間。

也可以檢視當前系統中的 JAR 檔案：

```
./info_mmb_jar.sh current
```

### 從備份還原 JAR 檔案

```
./install_mmb_jar.sh <備份ID>
```

從指定的備份還原 JAR 檔案到部署目錄。

### 刪除備份

```
./delete_mmb_jar.sh <備份ID>
```

刪除指定的備份檔案及其在備份清單中的記錄。

## 檔案說明

- `backup_mmb_jar.sh`: 備份 JAR 檔案
- `list_mmb_jar.sh`: 列出所有可用備份
- `info_mmb_jar.sh`: 檢視備份詳細資訊
- `install_mmb_jar.sh`: 從備份還原 JAR 檔案
- `delete_mmb_jar.sh`: 刪除不需要的備份
- `mmb_config.env`: 環境變數配置檔案

## 備註

- 備份檔案儲存為 .tar.gz 格式
- 每個備份都有唯一的 ID，基於檔案的 MD5 值生成
- 備份清單儲存在 `$ARCHIVED_HOME/backup_list.txt` 中