#!/bin/bash

# 共通スクリプトの読み込み
source "$(dirname "$0")/common.sh"

# dry-run オプションのチェック
DRY_RUN=false
if [[ "$1" == "--dry-run" ]]; then
	DRY_RUN=true
	echo "[DRY RUN] Git リポジトリから rclone ($CLOUD_PROVIDER) へのアップロードをシミュレーション"
fi

echo "開始: Git リポジトリから rclone ($CLOUD_PROVIDER) へのアップロード"
if [ "$DRY_RUN" = false ]; then
	confirm_execution
fi

process_file_list "upload" "$DRY_RUN"

echo "完了: Git リポジトリから rclone ($CLOUD_PROVIDER) へのアップロード"
