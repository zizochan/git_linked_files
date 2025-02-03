#!/bin/bash

# 共通スクリプトを読み込み
source "$(dirname "$0")/common.sh"

# dry-run オプションのチェック
DRY_RUN=false
if [[ "$1" == "--dry-run" ]]; then
	DRY_RUN=true
	echo "[DRY RUN] Git リポジトリから rclone (Dropbox) へのアップロードをシミュレーション"
fi

# === 処理 ===
echo "開始: Git リポジトリから rclone (Dropbox) へのアップロード"
confirm_execution

process_file_list "upload" "$DRY_RUN"

echo "完了: Git リポジトリから rclone (Dropbox) へのアップロード"
