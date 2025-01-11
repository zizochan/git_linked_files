#!/bin/bash

# 共通スクリプトを読み込み
source "$(dirname "$0")/common.sh"

# === 処理 ===
echo "開始: Git リポジトリから rclone (Dropbox) へのアップロード"
echo "3秒後に開始します"
sleep 3

process_file_list "upload"

echo "完了: Git リポジトリから rclone (Dropbox) へのアップロード"
