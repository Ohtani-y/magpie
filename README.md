# 🧮 Magpie Reasoning - HLE数学対策特化版

[![Magpie](figs/magpie_logo.png)](https://magpie-align.github.io/)

[![arXiv](https://img.shields.io/badge/arXiv-paper-b31b1b.svg)](https://arxiv.org/abs/2406.08464) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT) [![Data License](https://img.shields.io/badge/Data%20License-CC%20By%20NC%204.0-red.svg)](https://huggingface.co/Magpie-Align)

このリポジトリは、HLE（高等レベル試験）数学対策に特化したreasoning（推論）データセット生成システムです。DeepSeek R1モデルを使用して、高品質な数学推論データを生成します。

## 🎯 特徴

- **HLE数学対策特化**: 高等レベル試験に必要な数学問題に焦点
- **DeepSeek R1統合**: 最新のDeepSeek R1モデルによる高品質推論
- **英語データセット生成**: 英語LLMとの互換性を保持
- **数学推論テンプレート**: 代数、微積分、幾何学等の専門テンプレート
- **Chain-of-Thought対応**: 段階的思考プロセスを含む推論データ

## 📚 SFTとAlignの違いについて

このシステムでは、2つの異なるタイプのデータセットを生成できます：

### 🎓 SFT（Supervised Fine-Tuning）データ
- **目的**: モデルに基本的な数学問題解決能力を教える
- **構造**: 問題（instruction）と正解（response）のペア
- **用途**: モデルの基礎的な数学推論能力を向上させる
- **特徴**: 
  - 1つの問題に対して1つの高品質な解答
  - 正確性と完全性を重視
  - 基本的なファインチューニングに使用

### 🎯 Align（嗜好データ）
- **目的**: モデルの解答品質と人間の嗜好を一致させる
- **構造**: 問題に対する複数の候補解答とその品質評価
- **用途**: モデルの出力を人間の期待により近づける
- **特徴**:
  - 1つの問題に対して複数の候補解答を生成
  - preferred（好ましい）とrejected（好ましくない）のペア
  - 解答の品質差を学習させる
  - DPO（Direct Preference Optimization）やRLHF（Reinforcement Learning from Human Feedback）に使用

### 🔄 使い分けの指針

1. **SFTデータを先に使用**: まずモデルに基本的な数学解答能力を教える
2. **Alignデータで調整**: その後、解答の品質と嗜好を調整する
3. **反復的改善**: 必要に応じてSFTとAlignを交互に適用

### 📊 本番用ノートブックでの実装

`demo_production.ipynb`では、以下の流れで両タイプのデータを生成できます：

1. **Step 1-2**: 基本的なSFTデータ生成（問題と解答）
2. **Step 3**: データセット品質分析とフィルタリング
3. **Step 4**: Alignデータ生成（複数候補と嗜好ペア）
4. **Step 5**: 統合レポートと次のステップ

この2段階アプローチにより、HLE数学対策に最適化された高品質なデータセットを効率的に生成できます。

## 🚀 対応モデル

- **DeepSeek R1** (685B parameters, 37B activated) - 推奨
- **Qwen2.5-Math** シリーズ
- **Llama 3.x** シリーズ（数学テンプレート使用時）

## 📰 更新情報
- [2025/01/24] DeepSeek R1対応版リリース！HLE数学対策に特化したreasoning特化版
- [2025/01/09] Magpie Reasoning V2データセット公開！[250K](https://huggingface.co/collections/Magpie-Align/magpie-reasoning-datasets-67790a13b91035bc42693885) CoT推論に焦点 🤯
- [2024/07/14] 推論能力強化版リリース！[reasoning booster dataset](https://huggingface.co/datasets/Magpie-Align/Magpie-Reasoning-150K)による性能向上

## 🤖 対応モデル

HLE数学対策に特化したreasoning特化版では、数学推論に優れたモデルのみをサポートしています。

|モデルファミリー | 対応状況 | スクリプト | 推奨用途 |
|-------------|:------:|:-------|:-------|
| [DeepSeek R1](https://huggingface.co/deepseek-ai/DeepSeek-R1) | ✅ 推奨 | [R1](scripts/magpie-deepseek-r1.sh) | HLE数学推論データ生成 |
| [Qwen2.5-Math](https://huggingface.co/Qwen/Qwen2.5-Math-72B-Instruct) | ✅ | [Math 72B](scripts/magpie-qwen2.5-math-72b.sh) | 数学特化データセット |
| [Qwen2-Math](https://huggingface.co/Qwen/Qwen2-Math-7B-Instruct) | ✅ | [Math 7B](scripts/magpie-qwen2-math-7b.sh) | 軽量数学データ生成 |
| [Llama 3.x](https://huggingface.co/collections/meta-llama/llama-31-669fc079a0c406a149a5738f) | ✅ | [Math Template](scripts/magpie_math.sh) | 汎用数学推論 |

- ✅: 完全対応・推奨
- ⭕️: 基本対応
- ❌: 非対応
- ❓: 未テスト

利用可能なreasoning特化データセットの詳細は[こちら](navigation.md)をご覧ください。

## 📖 概要
<details><summary>詳細を表示</summary>
このHLE数学対策特化版は、高等レベル試験（HLE）に必要な数学推論能力を向上させるための高品質データセット生成に特化しています。DeepSeek R1の強力な推論能力を活用し、段階的思考プロセス（Chain-of-Thought）を含む数学問題とその解答を自動生成します。

従来の汎用的なデータ生成手法とは異なり、本システムは：
- **数学特化テンプレート**: 代数、微積分、幾何学、統計学等の専門分野に最適化
- **HLE対策フォーカス**: 高等レベル試験で求められる思考プロセスを重視
- **英語データセット**: 英語LLMとの互換性を保持しつつ高品質な推論データを生成
- **DeepSeek R1統合**: 最新の推論特化モデルによる高度な数学問題生成

生成されるデータセットは、数学的推論能力の向上、問題解決スキルの習得、HLE試験対策に最適化されています。
</details>

## 🏗️ インストール

**環境構築**
```bash
git clone https://github.com/Ohtani-y/magpie.git
cd magpie
conda create -n magpie-reasoning python=3.10 -y
conda activate magpie-reasoning
pip install -r requirements.txt
```

**DeepSeek R1モデルへのアクセス設定**

DeepSeek R1モデルを使用するには、Hugging Faceにログインが必要です：
```bash
huggingface-cli login
```
"hf_"で始まるHugging Face APIキーを入力してください。

**GPU要件**
- DeepSeek R1 (685B): 4×A100 80GB以上推奨
- Qwen2.5-Math (72B): 2×A100 80GB以上
- Qwen2-Math (7B): 1×RTX 4090 24GB以上

## 🚀 クイックスタート

**DeepSeek R1による数学データ生成**

HLE数学対策データを生成するには：
```bash
cd scripts
bash magpie-deepseek-r1.sh
```

**数学特化テンプレートの使用**

既存のLlamaモデルで数学特化データを生成：
```bash
cd scripts
bash magpie_math.sh "meta-llama/Meta-Llama-3-70B-Instruct" 1000
```

**生成パラメータの調整**

- `total_prompts`: 生成する問題数（デフォルト: 1000）
- `ins_temp`: 問題生成の創造性（デフォルト: 1.0）
- `res_temp`: 解答生成の一貫性（デフォルト: 0.0）

生成されたデータは`data/`フォルダに保存されます。RTX 4090 24GBでテスト済みです。メモリが不足する場合は[量子化](https://docs.vllm.ai/en/latest/quantization/fp8.html)の実装を検討してください。

## 📊 データセット処理

### 1. 品質タグ付け
生成された数学問題にメタデータを付与：
```bash
cd scripts
bash unitag.sh ***_ins_res.json all
```
このスクリプトは品質、難易度、問題カテゴリ、安全性、報酬、言語を自動生成します。

### 2. データ重複除去
ShareGPT形式に変換後、重複問題を除去：
```bash
cd exp
python gen_dis.py --input_file ***_sharegpt.jsonl
```
FAISSインデックスを構築し、最小近傍距離を計算して重複を検出します。

### 3. HLE特化フィルタリング
数学問題の難易度と品質に基づくフィルタリングが可能です。詳細は`data_sft/data_filter.ipynb`を参照してください。

### 4. 数学分野別分類
生成されたデータセットは以下の分野に自動分類されます：
- 代数学（Algebra）
- 微積分学（Calculus）
- 幾何学（Geometry）
- 統計学（Statistics）
- 数論（Number Theory）

## 🎯 HLE対策特化機能

### 数学推論テンプレート
HLE試験に特化した数学問題テンプレートを提供：

```python
# 代数問題テンプレート例
"次の二次方程式を解き、解の過程を段階的に説明してください: ax² + bx + c = 0"

# 微積分問題テンプレート例  
"関数f(x)の極値を求め、グラフの概形を描くための手順を説明してください"

# 幾何問題テンプレート例
"三角形の面積を求める複数の方法を比較し、最適な手法を選択する理由を述べてください"
```

### Chain-of-Thought推論
DeepSeek R1の強力な推論能力を活用し、段階的思考プロセスを含む解答を生成：

1. **問題理解**: 与えられた条件の整理
2. **解法選択**: 最適なアプローチの決定
3. **計算実行**: 段階的な計算過程
4. **結果検証**: 解の妥当性確認
5. **一般化**: 類似問題への応用

## 📚 使用例とベストプラクティス

### HLE数学データセット生成の推奨設定

```bash
# 高品質な数学推論データ生成
bash magpie-deepseek-r1.sh "deepseek-ai/DeepSeek-R1" 5000 1.0 1.2 1.0 0.1

# パラメータ説明:
# - モデル: DeepSeek R1 (推奨)
# - 問題数: 5000問
# - 問題生成温度: 1.0 (多様性)
# - 問題生成top_p: 1.2 (創造性)
# - 解答生成top_p: 1.0 (バランス)
# - 解答生成温度: 0.1 (一貫性)
```

### データ品質向上のコツ

1. **適切な温度設定**: 問題生成は高め（1.0-1.2）、解答生成は低め（0.0-0.2）
2. **バッチサイズ調整**: GPU メモリに応じて最適化
3. **フィルタリング**: 生成後の品質チェックを必ず実行
4. **分野バランス**: 各数学分野が均等に含まれるよう調整

## 🙏 謝辞

本プロジェクトは元のMagpieプロジェクトをベースに、HLE数学対策に特化して開発されました。

元論文の引用:
```
@article{xu2024magpie,
  title={Magpie: Alignment Data Synthesis from Scratch by Prompting Aligned LLMs with Nothing},
  author={Zhangchen Xu and Fengqing Jiang and Luyao Niu and Yuntian Deng and Radha Poovendran and Yejin Choi and Bill Yuchen Lin},
  journal={ArXiv},
  year={2024},
  volume={abs/2406.08464}
}
```
