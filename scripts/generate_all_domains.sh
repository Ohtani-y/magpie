#!/bin/bash

# DeepSeek R1による6ドメイン数学データセット一括生成スクリプト

echo "🚀 DeepSeek R1による6ドメイン数学データセット生成を開始します..."

model_path="deepseek-ai/DeepSeek-R1"
problems_per_domain=100

# 6つの数学ドメイン
domains=("algebra" "applied-mathematics" "calculus" "discrete-mathematics" "geometry" "number-theory")

echo "📊 設定:"
echo "  - モデル: $model_path"
echo "  - 各ドメイン問題数: $problems_per_domain"
echo "  - 総問題数: $((${#domains[@]} * $problems_per_domain))"
echo ""

# 各ドメインでデータ生成
for domain in "${domains[@]}"; do
    echo "🔄 ドメイン: $domain の生成を開始..."
    ./magpie-deepseek-r1-domains.sh "$domain" "$model_path" "$problems_per_domain"
    
    if [ $? -eq 0 ]; then
        echo "✅ ドメイン: $domain の生成が完了しました"
    else
        echo "❌ ドメイン: $domain の生成でエラーが発生しました"
        exit 1
    fi
    echo ""
done

echo "🎉 全6ドメインのデータ生成が完了しました！"
echo "📁 生成されたデータは data/ フォルダに保存されています"