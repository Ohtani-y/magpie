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

## 🚀 Google Colab で始める

[![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/Ohtani-y/magpie/blob/main/demo_colab.ipynb)

Google Colabで簡単にHLE数学データ生成を体験できます：

- **ワンクリック実行**: 上記のバッジをクリックしてColabで直接開始
- **GPU環境**: A100 GPU推奨（無料版でも動作可能）
- **完全ワークフロー**: 問題生成からAlign データまで一貫して実行
- **ダウンロード機能**: 生成されたデータセットを直接ダウンロード

### 📋 Colab実行要件

- **GPU**: A100推奨（T4でも動作するが処理時間が長くなります）
- **メモリ**: 高RAM設定推奨
- **実行時間**: 小規模データセット（50問）で約15-30分

## 📁 フォルダー構成と機能

このリポジトリは、HLE数学対策に特化した効率的なデータ生成パイプラインを提供します。各ディレクトリの役割と主要ファイルについて説明します。

### 🔧 configs/ - モデル設定とテンプレート定義

```
configs/
└── model_configs.json    # モデル設定とプロンプトテンプレート
```

- **model_configs.json**: DeepSeek R1を含む各種モデルの設定ファイル
  - `pre_query_template_math`: HLE数学特化のシステムプロンプト
  - `stop_tokens`: 各モデルの停止トークン設定
  - `stop_token_ids`: トークンID指定による停止制御

### 🚀 scripts/ - データ生成スクリプト集

```
scripts/
├── magpie-deepseek-r1.sh      # DeepSeek R1用HLE数学データ生成
├── magpie_math.sh             # 汎用数学データ生成
├── magpie-qwen2-math-7b.sh    # Qwen2 Math 7B用スクリプト
└── magpie-qwen2.5-math-72b.sh # Qwen2.5 Math 72B用スクリプト
```

- **magpie-deepseek-r1.sh**: 推奨メインスクリプト
  - HLE対策に最適化されたパラメータ設定
  - 大型モデル対応のメモリ管理
  - 日本語ログ出力による進捗確認
  - バッチ処理による効率的な生成

### ⚙️ exp/ - コア生成エンジン

```
exp/
├── gen_ins.py           # 数学問題生成エンジン
├── gen_res.py           # 解答生成エンジン
├── gen_po_multi_res.py  # 複数候補解答生成
├── gen_po_rewards.py    # 解答品質評価
├── utils.py             # 共通ユーティリティ
└── str_utils.py         # 文字列処理ユーティリティ
```

- **gen_ins.py**: 問題生成の中核
  - `--control_tasks math`: 数学問題に特化
  - DeepSeek R1のChain-of-Thought活用
  - バッチ処理とチェックポイント機能

- **gen_res.py**: 解答生成の中核
  - 低温度設定による安定した解答生成
  - 複数エンジン対応（vLLM, HuggingFace, API）
  - 自動品質フィルタリング

### 📊 data_sft/ - SFTデータ処理

```
data_sft/
├── data_filter.ipynb        # データ品質フィルタリング
└── data_concatenation.ipynb # 複数データセットの統合
```

- **data_filter.ipynb**: 生成データの品質管理
  - 数学キーワード検出
  - 解答長による自動フィルタリング
  - 推論指標の分析

### 🎯 data_po/ - 嗜好データ処理

```
data_po/
├── process_po.ipynb                    # 嗜好データ処理パイプライン
├── example_instructions.jsonl         # サンプル問題集
├── example_instructions_5res.json     # 5候補解答サンプル
└── example_instructions_5res_armorm.json # ArmorM評価付きサンプル
```

- **process_po.ipynb**: Alignデータ生成の中核
  - Preferred/Rejected ペア作成
  - 複数候補解答の品質評価
  - DPO/RLHF用データ形式への変換

### 📚 recipes/ - レシピ設定

```
recipes/
├── Llama-3-8B-Magpie-Align-SFT-v0.1/   # Llama3 8B SFT設定
├── Llama-3-8B-Magpie-Align-v0.1/       # Llama3 8B Align設定
├── Llama-3.1-8B-Magpie-Align-v0.1/     # Llama3.1 8B設定
└── README.md                            # レシピ使用方法
```

- 各レシピディレクトリには以下が含まれます：
  - トレーニング設定ファイル
  - データセット構成
  - 評価メトリクス設定

### 🖼️ figs/ - ドキュメント画像

```
figs/
├── magpie_logo.png    # Magpieロゴ
└── overview.png       # システム概要図
```

### 📓 ノートブック類

```
./
├── demo.ipynb            # 基本デモノートブック
├── demo_production.ipynb # 本番用統合ノートブック
├── demo_colab.ipynb      # Google Colab対応版
└── create_notebook.py    # ノートブック生成スクリプト
```

- **demo_production.ipynb**: 本番環境用の完全版
  - ユーザー設定変数の一元管理
  - SFTからAlignまでの完全ワークフロー
  - 品質分析とレポート生成

- **demo_colab.ipynb**: Google Colab特化版
  - Colab環境での最適化
  - ファイルダウンロード機能
  - GPU設定の自動化

## 🔄 データ生成ワークフロー

### 1. 基本的な使用方法

```bash
# DeepSeek R1を使用したHLE数学データ生成
cd scripts
./magpie-deepseek-r1.sh deepseek-ai/DeepSeek-R1 1000 1.0 1.2 1.0 0.1
```

### 2. パラメータの説明

- `model_path`: 使用するモデル（DeepSeek R1推奨）
- `total_prompts`: 生成する問題数
- `ins_topp`, `ins_temp`: 問題生成時のtop_pと温度
- `res_topp`, `res_temp`: 解答生成時のtop_pと温度

### 3. 出力ファイル

生成されるファイルは `data/` ディレクトリに保存されます：

- `*_ins.json`: 生成された数学問題
- `*_res.json`: 対応する解答
- `*_filtered.json`: 品質フィルタリング済みデータ
- `*_align.json`: 嗜好データ（preferred/rejected ペア）

## 🚀 対応モデル

- **DeepSeek R1** (685B parameters, 37B activated) - 推奨
  - HLE数学問題に最適化されたChain-of-Thought推論
  - 高品質な段階的解答生成
  - 数学的厳密性と教育的価値の両立

## 🛠️ インストール

### ローカル環境

```bash
git clone https://github.com/Ohtani-y/magpie.git
cd magpie
pip install -r requirements.txt
```

### Google Colab

[![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/Ohtani-y/magpie/blob/main/demo_colab.ipynb)

Colabでは上記のリンクをクリックするだけで、環境構築から実行まで自動で行われます。

## 🚀 クイックスタート

### Google Colabで始める（推奨）

[![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/Ohtani-y/magpie/blob/main/demo_colab.ipynb)

1. 上記のバッジをクリック
2. GPU設定をA100に変更（推奨）
3. セルを順番に実行
4. 生成されたデータセットをダウンロード

### ローカル環境での基本的なデータ生成

```bash
cd scripts
./magpie-deepseek-r1.sh deepseek-ai/DeepSeek-R1 1000
```

### 本番用ノートブック

- **ローカル**: `demo_production.ipynb` 
- **Google Colab**: `demo_colab.ipynb`

どちらもステップバイステップでデータ生成を実行できます。

## 📈 生成データの特徴

- **高品質な数学推論**: Chain-of-Thought形式の詳細な解答
- **HLE対策特化**: 高等レベル試験に必要な数学分野をカバー
- **段階的思考プロセス**: 問題解決の各ステップを明確に記述
- **教育的価値**: 学習者の理解を深める解説付き解答
- **2種類のデータ形式**: SFT用とAlign用の両方に対応
- **品質保証**: 自動フィルタリングによる高品質データの確保

## 💡 使用例とベストプラクティス

### 小規模テスト（推奨開始方法）

```bash
# 50問の小規模テスト
./magpie-deepseek-r1.sh deepseek-ai/DeepSeek-R1 50 1.0 1.2 1.0 0.1
```

### 本格的なデータセット生成

```bash
# 1000問の本格的なデータセット
./magpie-deepseek-r1.sh deepseek-ai/DeepSeek-R1 1000 1.0 1.2 1.0 0.1
```

### パラメータ調整のガイドライン

- **問題生成温度**: 1.2（創造性と一貫性のバランス）
- **解答生成温度**: 0.1（安定した高品質解答）
- **バッチサイズ**: 50（メモリ効率と処理速度の最適化）

## 🎯 GPU要件

- **推奨**: NVIDIA A100 (80GB)
- **最小**: NVIDIA V100 (32GB) または RTX 4090 (24GB)
- **メモリ**: 最低16GB VRAM（DeepSeek R1の場合）
- **Google Colab**: A100推奨（T4でも動作可能だが処理時間が長くなります）

## 📊 生成例

### 問題例
```
微積分学において、関数 f(x) = x³ - 3x² + 2x - 1 の極値を求め、
その性質について詳しく説明してください。
```

### 解答例（Chain-of-Thought）
```
この問題を段階的に解決していきます。

**ステップ1: 導関数の計算**
f'(x) = 3x² - 6x + 2

**ステップ2: 極値候補の特定**
f'(x) = 0 となる点を求めます...
[詳細な解答が続く]
```

## 🔗 関連リンク

- **論文**: [Magpie: Alignment Data Synthesis from Scratch by Prompting Language Models with Nothing](https://arxiv.org/abs/2406.08464)
- **DeepSeek R1**: [Hugging Face Model Page](https://huggingface.co/deepseek-ai/DeepSeek-R1)
- **Google Colab デモ**: [![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/Ohtani-y/magpie/blob/main/demo_colab.ipynb)

## 🤝 貢献とサポート

このプロジェクトへの貢献を歓迎します：

1. **Issue報告**: バグや改善提案をGitHub Issuesで報告
2. **プルリクエスト**: 新機能や修正のプルリクエストを送信
3. **ドキュメント改善**: 使用方法やベストプラクティスの追加

## 📄 ライセンス

このプロジェクトはMITライセンスの下で公開されています。詳細は[LICENSE](LICENSE)ファイルをご覧ください。

## 🙏 謝辞

このプロジェクトは、元のMagpieプロジェクト（[Magpie-Align](https://magpie-align.github.io/)）をベースに、HLE数学対策に特化した改良を加えたものです。元の研究チームに深く感謝いたします。
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
