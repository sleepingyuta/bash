#!/bin/bash

# スクリプト名: tree_display.sh
# 
# このスクリプトは、指定されたディレクトリのツリー構造を表示する。
# 指定した階層数までのディレクトリ階層を整形して表示し、それ以降の階層はファイルのみを表示する。
# 階層の接頭辞はオプショナルで、デフォルトは'|--'です。
# 
# 使用法:
#   bash tree_display.sh ルートディレクトリ レベル [接頭辞]
# 
# 引数:
#   ルートディレクトリ: ツリーを表示したいディレクトリのパス
#   レベル: 表示する最大階層の深さを指定（整数で指定）
#   接頭辞 (オプション): 階層の接頭辞を指定。省略した場合、デフォルトの'|--'を使用する。
# 
# 使用例:
#   bash tree_display.sh /path/to/directory 2 ">>>"

# 引数の数をチェックして、足りない場合は使用法を表示して終了
if [ $# -lt 2 ]; then
    echo "Error: Insufficient arguments. Usage: $0 root_dir level [prefix]"
    exit 1
fi

# スクリプトに渡された引数を変数に代入
root_dir="$1"
max_depth="$2"
prefix="${3:-|--}"  # 省略した場合、デフォルト値を設定

function print_tree() {
    local dir=$1
    local depth=$2
    local max_depth=$3
    local prefix=$4

    # ディレクトリ内のファイルを取得
    local files=$(find "$dir" -maxdepth 1 -type f -printf "%f\n" | sort)

    # ファイルを表示
    for file in $files; do
        for ((i = 1; i < $depth; i++)); do
            printf "  "
        done
        echo "$prefix $file"
    done

    # 指定したレベルまで表示
    if [ $depth -lt $max_depth ]; then
        local subdirs=$(find "$dir" -mindepth 1 -maxdepth 1 -type d -printf "%f\n" | sort)
        for subdir in $subdirs; do
            for ((i = 1; i < $depth; i++)); do
                printf "  "
            done
            echo "$prefix $subdir"
            # 再帰的にサブディレクトリを表示
            print_tree "$dir/$subdir" $((depth + 1)) $max_depth "$prefix"
        done
    else
        # 指定した階層以降はファイルのみを表示
        local all_files=$(find "$dir" -type f -printf "%P\n" | sort)
        for file in $all_files; do
            for ((i = 1; i < $depth; i++)); do
                printf "  "
            done
            echo "$prefix $file"
        done
    fi
}

# ルートディレクトリを表示して、print_tree関数を呼び出す
echo "$root_dir"
print_tree "$root_dir" 1 "$max_depth" "$prefix"
