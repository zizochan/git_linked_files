#!/bin/bash

# 共通スクリプトを読み込み
source "$(dirname "$0")/common.sh"

# dry-run オプションのチェック
DRY_RUN=false
if [[ "$1" == "--dry-run" ]]; then
	DRY_RUN=true
	echo "[DRY RUN] rclone (Dropbox) から Git リポジトリへの同期をシミュレーション"
fi

# === 処理 ===
echo "開始: rclone (Dropbox) から Git リポジトリへの同期"
if [ "$DRY_RUN" = false ]; then
	confirm_execution
fi

process_file_list "sync" "$DRY_RUN"

echo "完了: rclone (Dropbox) から Git リポジトリへの同期"
