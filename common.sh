#!/bin/bash

# 設定ファイルを読み込み（親ディレクトリに配置）
CONFIG_FILE="$(dirname "$0")/../linked_file_config.sh"
if [ ! -f "$CONFIG_FILE" ]; then
	echo "Error: 設定ファイルが見つかりません: $CONFIG_FILE"
	exit 1
fi
source "$CONFIG_FILE"

# Gitリポジトリのルートパス
GIT_REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
if [ $? -ne 0 ]; then
	echo "Error: このスクリプトはGitリポジトリ内で実行してください。"
	exit 1
fi

# アップロードリストのパス（親ディレクトリに配置）
UPLOAD_LIST="$(dirname "$0")/../linked_file_list.txt"

# 必要なディレクトリを作成する
ensure_directory_exists() {
	local dir="$1"
	mkdir -p "$dir"
}

# ファイルのバックアップ処理
backup_file() {
	local file="$1"

	# BACKUP_DIRが空文字またはnullの場合は戻る
	if [ -z "$BACKUP_DIR" ]; then
		return
	fi

	local backup_file_path="$BACKUP_DIR/$(basename "$file")_$(date +"%Y%m%d%H%M%S")"

	if [ -f "$file" ]; then
		ensure_directory_exists "$BACKUP_DIR"
		cp "$file" "$backup_file_path"
		echo "バックアップ作成: $file -> $backup_file_path"
	fi
}

# 実行前の確認
confirm_execution() {
	read -p "実行してもよろしいですか？ (yes/no): " confirm
	if [ "$confirm" != "yes" ]; then
		echo "操作がキャンセルされました。"
		exit 0
	fi
}

# リモートのディレクトリを作成する（rclone）
create_remote_directory() {
	local remote_dir="$1"

	rclone mkdir "$remote_dir"
	if [ $? -ne 0 ]; then
		echo "Error: リモートディレクトリ作成失敗: \"$remote_dir\""
		return 1
	fi
}

# ファイルのアップロード・ダウンロード（rcloneを使用）
transfer_file_with_rclone() {
	local action="$1" # "upload" または "download"
	local src="$2"
	local dest="$3"
	local dry_run="${4:-false}"
	local command="rclone copyto $src $dest $(generate_rclone_exclude)"

	# 必要なディレクトリを作成
	local dest_dir
	dest_dir=$(dirname "$dest")

	if [ "$action" == "upload" ]; then
		create_remote_directory "$dest_dir"
		backup_file "$src"
	else
		ensure_directory_exists "$dest_dir"
		backup_file "$dest"
	fi

	# 実行
	if [ "$dry_run" == "true" ]; then
		$command --dry-run --log-format=NOTICE 2>&1 | grep -E "NOTICE: .*: Skipped copy"
	else
		$command
		if [ $? -eq 0 ]; then
			echo "$action 成功: \"$src\" -> \"$dest\""
		else
			echo "Error: $action 失敗: \"$src\" -> \"$dest\""
			return 1
		fi
	fi
}

# 除外ファイル・ディレクトリパターンを rclone 用の `--exclude` オプションとして配列化
generate_rclone_exclude() {
	local exclude_args=()
	for pattern in "${EXCLUDE_PATTERNS[@]}"; do
		exclude_args+=("--exclude")
		exclude_args+=("$pattern")
	done
	echo "${exclude_args[@]}"
}

# ファイルリストを処理する
process_file_list() {
	local action="$1" # "upload" または "sync" を指定
	local dry_run="${2:-false}"

	if [ ! -f "$UPLOAD_LIST" ]; then
		echo "Error: アップロードリストが見つかりません: $UPLOAD_LIST"
		return 1
	fi

	while IFS= read -r file || [ -n "$file" ]; do
		[[ -z "$file" || "$file" =~ ^# ]] && continue

		local src=""
		local dest=""
		local transfer_action=""

		if [ "$action" == "upload" ]; then
			src="$GIT_REPO_ROOT/$file"
			dest="$RCLONE_REPO_DIR/$file"
			transfer_action="upload"
		elif [ "$action" == "sync" ]; then
			src="$RCLONE_REPO_DIR/$file"
			dest="$GIT_REPO_ROOT/$file"
			transfer_action="download"
		else
			echo "Error: 無効なアクション指定: $action"
			return 1
		fi

		transfer_file_with_rclone "$transfer_action" "$src" "$dest" "$dry_run"
	done <"$UPLOAD_LIST"
}
