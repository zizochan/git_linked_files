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
	if [ $? -eq 0 ]; then
		echo "リモートディレクトリ作成成功: \"$remote_dir\""
	else
		echo "Error: リモートディレクトリ作成失敗: \"$remote_dir\""
		return 1
	fi
}

# ファイルのアップロード（rcloneを使用）
upload_file_to_rclone() {
	local src="$1"
	local dest="$2"

	# リモートディレクトリを作成
	local dest_dir
	dest_dir=$(dirname "$dest")
	create_remote_directory "$dest_dir"

	# バックアップ処理
	backup_file "$src"

	# ファイル単位でコピー
	rclone copyto "$src" "$dest"
	if [ $? -eq 0 ]; then
		echo "アップロード成功: \"$src\" -> \"$dest\""
	else
		echo "Error: アップロード失敗: \"$src\" -> \"$dest\""
		return 1
	fi
}

# ファイルのダウンロード（rcloneを使用）
download_file_from_rclone() {
	local src="$1"
	local dest="$2"

	# 必要なローカルディレクトリを作成
	local dest_dir
	dest_dir=$(dirname "$dest")
	ensure_directory_exists "$dest_dir"

	# バックアップ処理
	backup_file "$dest"

	# ファイル単位でコピー
	rclone copyto "$src" "$dest"
	if [ $? -eq 0 ]; then
		echo "ダウンロード成功: \"$src\" -> \"$dest\""
	else
		echo "Error: ダウンロード失敗: \"$src\" -> \"$dest\""
		return 1
	fi
}

# ファイルリストを処理する
process_file_list() {
	local action="$1" # "upload" または "sync" を指定

	if [ ! -f "$UPLOAD_LIST" ]; then
		echo "Error: アップロードリストが見つかりません: $UPLOAD_LIST"
		return 1
	fi

	# ファイルリストを読み込み
	while IFS= read -r file; do
		# 空行やコメント行をスキップ
		[[ -z "$file" || "$file" =~ ^# ]] && continue

		local src=""
		local dest=""

		if [ "$action" == "upload" ]; then
			# ソース: リポジトリ内のファイル
			src="$GIT_REPO_ROOT/$file"
			# ターゲット: rcloneのリモートにおける完全パス
			dest="$RCLONE_REPO_DIR/$file"
			echo "DEBUG: upload src=\"$src\" dest=\"$dest\""
			upload_file_to_rclone "$src" "$dest"
		elif [ "$action" == "sync" ]; then
			# ソース: rcloneのリモートにおける完全パス
			src="$RCLONE_REPO_DIR/$file"
			# ターゲット: リポジトリ内のファイル
			dest="$GIT_REPO_ROOT/$file"
			echo "DEBUG: sync src=\"$src\" dest=\"$dest\""
			download_file_from_rclone "$src" "$dest"
		else
			echo "Error: 無効なアクション指定: $action"
			return 1
		fi
	done <"$UPLOAD_LIST"
}
