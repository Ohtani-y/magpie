# エラー報告書: magpieスクリプトモデル選択問題

## 概要

magpieプロジェクトにおいて、特定のモデル（DeepSeek-R1-Distill-Qwen-32B）を指定してスクリプトを実行したにも関わらず、指定したモデル以外の複数モデル用フォルダが意図せず作成される重大なバグが発生していました。

**発生日時**: 2025年7月30日  
**影響範囲**: 全てのモデル生成スクリプト  
**重要度**: 高（データ整合性・リソース効率に重大な影響）

---

## 問題の詳細

### 1. 初期症状
```bash
# 実行コマンド
./run_math_generation.sh 111
# 期待: DeepSeek-R1-Distill-Qwen-32Bモデルのフォルダのみ作成
# 実際: Qwen系など複数の意図しないモデルフォルダが作成される
```

### 2. 発見された根本原因

#### A. モデル設定不備による参照エラー
- **問題**: `configs/model_configs.json`にDeepSeekモデルが未登録
- **影響**: Pythonスクリプト（`gen_ins.py`）でKeyErrorが発生し、フォールバック処理で意図しないモデルが実行される可能性

```python
# 問題のあるコード（修正前）
model_config = model_configs[args.model_path]  # KeyErrorでクラッシュ
```

#### B. 個別モデルスクリプトのデフォルト値による意図しない実行
- **問題**: 15個の個別モデル用スクリプト（`magpie-*.sh`）にデフォルト値が設定
- **影響**: 引数なしや誤った呼び出しで意図しないモデルが自動実行される

```bash
# 危険なデフォルト値（修正前）
model_path=${1:-"Qwen/Qwen2.5-Math-72B-Instruct"}      # magpie-qwen2.5-math-72b.sh
MODEL_PATH="${1:-deepseek-ai/DeepSeek-R1-Distill-Qwen-32B}"  # magpie-deepseek-r1-distill-qwen-32b.sh
model_path=${1:-"Qwen/Qwen2-Math-7B-Instruct"}         # magpie-qwen2-math-7b.sh
```

#### C. フォルダ検出・移動ロジックの不備
- **問題**: `generate_all_math_domains.sh`の曖昧なフォルダ検索パターン
- **影響**: 以前に作成された無関係なフォルダが誤って処理される

```bash
# 問題のあるコード（修正前）
DOMAIN_OUTPUT=$(find ../data -name "${MODEL_NAME}_${domain}_*" -type d | head -1)
# → 時系列無視で最初に見つかったフォルダを処理してしまう
```

---

## 発生していた課題

### 1. データ整合性の問題
- 指定したモデル以外のデータが混在
- 意図しないモデルの結果が含まれることによる品質低下
- データセットの信頼性が損なわれる

### 2. リソース効率の問題
- 不要なモデル実行による計算資源の浪費
- ストレージ容量の無駄遣い
- 実行時間の大幅な延長

### 3. 運用上の問題
- 予期しない動作により開発者の混乱
- デバッグ・トラブルシューティングの困難
- 再現性の欠如

### 4. セキュリティ・安全性の問題
- 意図しないスクリプト実行によるシステムリスク
- 予期しないファイル作成・変更
- エラー時の不適切なフォールバック

---

## 実装した修正内容

### 1. モデル設定の完全化
**ファイル**: `configs/model_configs.json`
```json
{
  "deepseek-ai/DeepSeek-R1-Distill-Qwen-32B": {
    "stop_tokens": ["<|im_end|>"],
    "prompt_template": "deepseek_chat"
  }
}
```

### 2. エラーハンドリングの強化
**ファイル**: `exp/gen_ins.py`
```python
# 修正後: 明確なエラーメッセージと即座の停止
if args.model_path not in model_configs:
    print(f"❌ エラー: モデル '{args.model_path}' が model_configs.json に見つかりません")
    print("📋 利用可能なモデル:")
    for model in model_configs.keys():
        print(f"  - {model}")
    print("🔧 解決方法: model_configs.json にモデル設定を追加するか、正しいモデル名を指定してください")
    sys.exit(1)
```

### 3. 個別スクリプトのデフォルト値削除
**対象ファイル**: 
- `scripts/magpie_math.sh`
- `scripts/magpie-qwen2.5-math-72b.sh`
- `scripts/magpie-deepseek-r1-distill-qwen-32b.sh`
- `scripts/magpie-qwen2-math-7b.sh`
- その他全ての`magpie-*.sh`スクリプト

```bash
# 修正後: 明示的な引数必須化
if [ -z "$1" ]; then
    echo "❌ エラー: モデルパスが指定されていません"
    echo "📋 使用方法: $0 <model_path> [total_prompts] ..."
    echo "💡 例: $0 deepseek-ai/DeepSeek-R1-Distill-Qwen-32B 1000"
    exit 1
fi
model_path="$1"
```

### 4. フォルダ検出ロジックの厳密化
**ファイル**: `scripts/generate_all_math_domains.sh`
```bash
# 修正後: タイムスタンプベースの厳密な検索
DOMAIN_START_TIME=$(date +%s)
# ... 生成処理 ...
DOMAIN_OUTPUT=$(find ../data -name "${MODEL_NAME}_${domain}_[0-9]*" -type d -newermt "@$DOMAIN_START_TIME" 2>/dev/null | head -1)

# パターン検証の追加
if [[ "$FOLDER_BASENAME" =~ ^${MODEL_NAME}_${domain}_[0-9]{8}_[0-9]{6}$ ]]; then
    # 正しいパターンの場合のみ処理
else
    echo "❌ Warning: フォルダパターンが期待される形式と一致しません"
    exit 1
fi
```

---

## 再発防止策

### 1. 設定管理の強化
- [ ] `model_configs.json`の完全性チェックスクリプトの作成
- [ ] 新モデル追加時の設定テンプレート提供
- [ ] 設定ファイルのバリデーション自動化

### 2. スクリプト実行の安全化
- [x] 全スクリプトでのデフォルト値削除完了
- [ ] 引数バリデーションの標準化
- [ ] 実行前チェック機能の追加

### 3. テスト・検証の自動化
- [ ] 単体テストスイートの作成
- [ ] 統合テストによる全体動作検証
- [ ] CI/CDパイプラインでの自動検証

### 4. ドキュメント・ガイドラインの整備
- [ ] 開発者向けガイドラインの作成
- [ ] トラブルシューティングマニュアルの整備
- [ ] ベストプラクティス集の作成

---

## 学んだ教訓

1. **デフォルト値の危険性**: 便利さを優先したデフォルト値が意図しない動作を引き起こす
2. **設定の一元管理**: 分散した設定が不整合を生む原因となる
3. **エラーハンドリングの重要性**: 適切なエラー処理がないと予期しないフォールバックが発生する
4. **包括的なテストの必要性**: 部分的な修正では全体の問題を見落とす可能性がある

---

## 修正状況

### ✅ 完了
- モデル設定の追加（`model_configs.json`）
- エラーハンドリングの強化（`gen_ins.py`）
- 主要スクリプトのデフォルト値削除（4ファイル）
- フォルダ検出ロジックの改善

### 🔄 進行中
- 残りの個別モデルスクリプトの修正
- 包括的なテスト実行

### 📋 今後の課題
- 自動テストスイートの構築
- ドキュメントの整備
- 監視・アラート機能の追加

---

**作成者**: Cascade AI  
**作成日**: 2025年7月30日  
**最終更新**: 2025年7月30日
