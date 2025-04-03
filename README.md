# git_linked_files

Gitで管理できない大きなファイルやバイナリを、クラウドストレージを介して管理するためのスクリプト群。

## 対応クラウド
- Google Drive
- Dropbox

## セットアップ手順

### rcloneの導入

ストレージに対するファイル操作は `rclone` を使用します。
rcloneをインストールし、以下いずれかのクラウドと関連づけてください。

### submoduleとしてインストール
使用するリポジトリで、git submoduleとしてインストールして下さい。

```
git submodule add git@github.com:zizochan/git_linked_files.git git_linked_files
git submodule init
git submodule update
```

### configファイル生成
以下のコマンドを実行して下さい。

```
cd git_linked_files
./setup.sh
```

**1階層上のフォルダ**に `linked_file_config.sh` と `linked_file_list.txt` が生成されます。
この2ファイルを編集して、親リポジトリ側でコミットしてください。

## 使用方法

### 管理対象ファイルの更新

`linked_file_list.txt` に管理対象のファイルパスを記載してください。
ファイル名にスペースが含まれていてもそのままでOKです。

### ストレージとの連携

事前に `linked_file_config.sh` にてクラウドを指定してください：

```bash
CLOUD_PROVIDER="gdrive" # または "dropbox"
REPO_NAME="your_repo_name"
```

#### アップロード

```bash
git_linked_files/upload.sh
```

#### ストレージからの取得

```bash
git_linked_files/sync.sh
```

#### dry-run オプション（実行内容の確認のみ）

```bash
git_linked_files/sync.sh --dry-run
git_linked_files/upload.sh --dry-run
```

### .gitignoreへの反映

```bash
git_linked_files/apply_gitignore.sh
```

## 備考

### バックアップについて

アップロード・同期実行時に、`BACKUP_DIR` を指定していればバックアップが保存されます。
不要な場合はコメントアウトしてください。

### Formatterについて

このリポジトリでは `shfmt` による整形を推奨しています。

```bash
brew install shfmt
shfmt -w *.sh
```
