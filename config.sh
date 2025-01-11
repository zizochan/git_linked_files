#!/bin/bash

# rcloneのリモート名とディレクトリ
RCLONE_REMOTE="dropbox:git_linked_files"

# Gitリポジトリの名前
REPO_NAME="unity_1week_game_jam_202412"

# rclone上のリモートディレクトリ
RCLONE_REPO_DIR="$RCLONE_REMOTE/$REPO_NAME"

# バックアップの保存先ディレクトリ
BACKUP_DIR="$HOME/Downloads/git_file_backups"
