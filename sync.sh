#!/bin/bash

# dry-run オプションのチェック
DRY_RUN=false
if [[ "$1" == "--dry-run" ]]; then
	DRY_RUN=true
	echo "[DRY RUN] ストレージから Git リポジトリへの同期をシミュレーション"
fi

# 共通スクリプトの読み込み
source "$(dirname "$0")/common.sh"

echo "開始: rclone ($CLOUD_PROVIDER) から Git リポジトリへの同期"
if [ "$DRY_RUN" = false ]; then
	confirm_execution
fi

process_file_list "sync" "$DRY_RUN"

echo "完了: rclone ($CLOUD_PROVIDER) から Git リポジトリへの同期"
