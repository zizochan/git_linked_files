#!/bin/bash

# 共通スクリプトを読み込み
source "$(dirname "$0")/common.sh"

# === 処理 ===
echo "開始: rclone (Dropbox) から Git リポジトリへの同期"
confirm_execution

process_file_list "sync"

echo "完了: rclone (Dropbox) から Git リポジトリへの同期"
