#!/bin/bash

# linked_file_config.sh または linked_file_list.txt が既に存在するか確認
CONFIG_PATH="../linked_file_config.sh"
FILE_LIST_PATH="../linked_file_list.txt"

# 実行確認をユーザーに求める
echo "このスクリプトは .linked_file_config.sh.sample を ../linked_file_config.sh に、.linked_file_list.txt.sample を ../linked_file_list.txt にコピーします。"
read -p "実行してもよろしいですか？ (yes/no): " confirm

if [[ "$confirm" != "yes" ]]; then
	echo "操作がキャンセルされました。"
	exit 0
fi

# ファイルが既に存在する場合はエラーを出力
if [[ -f "$CONFIG_PATH" ]]; then
	echo "エラー: $CONFIG_PATH は既に存在します。このスクリプトを実行する前に削除または名前を変更してください。"
	exit 1
fi

if [[ -f "$FILE_LIST_PATH" ]]; then
	echo "エラー: $FILE_LIST_PATH は既に存在します。このスクリプトを実行する前に削除または名前を変更してください。"
	exit 1
fi

# サンプルファイルをコピー
cp .linked_file_config.sh.sample "$CONFIG_PATH"
if [[ $? -ne 0 ]]; then
	echo "エラー: .linked_file_config.sh.sample を $CONFIG_PATH にコピーできませんでした。"
	exit 1
fi

cp .linked_file_list.txt.sample "$FILE_LIST_PATH"
if [[ $? -ne 0 ]]; then
	echo "エラー: .linked_file_list.txt.sample を $FILE_LIST_PATH にコピーできませんでした。"
	exit 1
fi

echo "セットアップが正常に完了しました！"
