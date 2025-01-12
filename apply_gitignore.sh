#!/bin/bash

# 共通スクリプトを読み込み
source "$(dirname "$0")/common.sh"

# .gitignore のセクションの開始と終了コメント
SECTION_START="##### git_linked_files_start #####"
SECTION_END="##### git_linked_files_end #####"

# === 処理 ===
echo "開始: linked_file_list.txt の内容を .gitignore に反映"
confirm_execution

# .gitignore が存在しない場合は新規作成
if [ ! -f ".gitignore" ]; then
	echo ".gitignore ファイルが存在しません。新規作成します。"
	touch ".gitignore"
fi

# ファイルを1行ずつ読み込んで書き出す
process_file_lines() {
	local input_file="$1"
	local output_file="$2"

	while IFS= read -r upload_line || [ -n "$upload_line" ]; do
		# 空白行をスキップ
		if [ -z "$upload_line" ]; then
			continue
		fi
		# 処理を実行（例: ファイルに出力）
		echo "$upload_line" >>"$output_file"
	done <"$input_file"
}

# 一時ファイルを使用して更新後の内容を作成
temp_file=$(mktemp)

# .gitignore を読み込んで、セクションを除外した内容を一時ファイルに書き込み
inside_section=false
while IFS= read -r line; do
	if [[ "$line" == "$SECTION_START" ]]; then
		inside_section=true
		echo "$SECTION_START" >>"$temp_file"
		echo "セクション開始を検出: $SECTION_START"
		# linked_file_list.txt の内容を挿入
		process_file_lines "$UPLOAD_LIST" "$temp_file"
		continue
	elif [[ "$line" == "$SECTION_END" ]]; then
		inside_section=false
		echo "$SECTION_END" >>"$temp_file"
		echo "セクション終了を検出: $SECTION_END"
		continue
	fi

	# セクション外の行のみ保持
	if ! $inside_section; then
		echo "$line" >>"$temp_file"
	fi
done <.gitignore

# セクションが存在しない場合、新規セクションを追加
if ! grep -Fxq "$SECTION_START" .gitignore; then
	echo "セクションが見つかりません。新規セクションを追加します。"
	echo "$SECTION_START" >>"$temp_file"
	process_file_lines "$UPLOAD_LIST" "$temp_file"
	echo "$SECTION_END" >>"$temp_file"
fi

# 更新された内容を .gitignore に反映
mv "$temp_file" ".gitignore"

echo "完了: linked_file_list.txt の内容を .gitignore に反映"
