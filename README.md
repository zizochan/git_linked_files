# git_linked_files
Gitで管理できない大きなファイルやバイナリを、ストレージを介して管理するためのスクリプト群。
今のところDropboxのみ対応。

## セットアップ手順

### rcloneの導入
ストレージに対するファイル操作は、rcloneを介して行います。
rcloneをインストールして、Dropboxと関連づけして下さい。

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

**1階層上のフォルダ**に`linked_file_config.sh`と`linked_file_list.txt`が生成されます。
この2ファイルを適切に編集して、親リポジトリ側でコミットして下さい。

## 使用方法

### 管理対象ファイルの更新
`linked_file_list.txt`に管理対象のファイル名を記載して下さい。
ファイル名にスペースが含まれる場合も、そのまま記載してOKです。

### ストレージへのアップロード
```
git_linked_files/upload_to_dropbox.sh
```

### ストレージからの取得
```
git_linked_files/sync_from_dropbox.sh
```

### .gitignoreへの反映
```
git_linked_files/apply_gitignore.sh
```

## 備考

### バックアップについて
ファイル更新コマンドを実行するたびに、`BACKUP_DIR`にバックアップが作られます。
不要なバックアップは手動で消して下さい。

### Formatterについて
シェルスクリプトのフォーマッタには`shfmt`を使用しています。
ソースコードの更新前に、shfmtを通して下さい。

```
brew install shfmt
shfmt -w *.sh
```

