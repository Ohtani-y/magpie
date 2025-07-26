# 🧮 Magpie Reasoning - HLE数学対策特化版

[![Magpie](figs/magpie_logo.png)](https://magpie-align.github.io/)

[![arXiv](https://img.shields.io/badge/arXiv-paper-b31b1b.svg)](https://arxiv.org/abs/2406.08464) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT) [![Data License](https://img.shields.io/badge/Data%20License-CC%20By%20NC%204.0-red.svg)](https://huggingface.co/Magpie-Align)

HLE（高等レベル試験）数学対策に特化したreasoning（推論）データセット生成システム。DeepSeek R1モデルを使用して、高品質な数学推論データを生成します。

## 🚀 クイックスタート

### Google Colabで始める（推奨）

[![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/Ohtani-y/magpie/blob/main/demo_colab.ipynb)

1. 上記のバッジをクリック
2. GPU設定をA100に変更（推奨、T4でも動作可）
3. セルを順番に実行
4. 生成されたデータセットをダウンロード

### ローカル環境での実行

```bash
# インストール
git clone https://github.com/Ohtani-y/magpie.git
cd magpie
pip install -r requirements.txt

# DeepSeek R1でデータ生成
cd scripts
./magpie-deepseek-r1.sh deepseek-ai/DeepSeek-R1 1000
```

## 🎯 特徴

- **HLE数学対策特化**: 高等レベル試験に必要な数学問題に焦点
- **DeepSeek R1統合**: 最新のDeepSeek R1モデルによる高品質推論
- **2種類のデータ形式**: SFT（教師あり学習）とAlign（嗜好データ）の両方に対応
- **Chain-of-Thought対応**: 段階的思考プロセスを含む推論データ
- **自動品質フィルタリング**: 高品質データの確保

## 📚 SFTとAlignデータの違い

### 🎓 SFT（Supervised Fine-Tuning）データ
- **目的**: モデルに基本的な数学問題解決能力を教える
- **構造**: 問題（instruction）と正解（response）のペア
- **用途**: 基礎的な数学推論能力の向上

### 🎯 Align（嗜好データ）
- **目的**: モデルの解答品質と人間の嗜好を一致させる
- **構造**: 問題に対する複数の候補解答とその品質評価
- **用途**: DPOやRLHFによる出力品質の向上

## 📊 生成データの例

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

## 🛠️ 対応モデル

### Magpie対応モデル

|モデルファミリー | 対応状況 | 推奨用途 |
|-------------|:------:|:-------|
| [DeepSeek R1](https://huggingface.co/deepseek-ai/DeepSeek-R1) | ✅ 推奨 | HLE数学推論データ生成 |
| [Qwen2.5-Math](https://huggingface.co/Qwen/Qwen2.5-Math-72B-Instruct) | ✅ | 数学特化データセット |
| [Qwen2-Math](https://huggingface.co/Qwen/Qwen2-Math-7B-Instruct) | ✅ | 軽量数学データ生成 |
| [Llama 3.x](https://huggingface.co/collections/meta-llama/llama-31-669fc079a0c406a149a5738f) | ✅ | 汎用数学推論 |

### 📐 数学特化モデル（2024-2025）

#### DeepSeek数学モデル
- **DeepSeekMath 7B**: MATH benchmark 51.7%達成、競技レベル数学対応
- **DeepSeek-R1 (2025)**: AIME 2024で79.8%、MATH-500で97.3%の最高性能

#### Qwen数学モデル
- **Qwen2.5-Math (72B)**: MATH 80%+の高性能、128Kトークン対応
- **Qwen2-Math (7B)**: 軽量版数学特化モデル

#### その他の数学特化モデル
- **InternLM2.5-Math**: 1.8B～8x22Bまでの多様なサイズ展開
- **NuminaMath 1.5**: 90万問の競技レベル数学問題データセット
- **Mathstral 7B**: Mistral-7Bベースの数学特化モデル

## 🎯 GPU要件

- **推奨**: NVIDIA A100 (80GB)
- **最小**: NVIDIA V100 (32GB) または RTX 4090 (24GB)
- **Google Colab**: A100推奨（T4でも動作可能）

## 📁 プロジェクト構成

```
magpie/
├── configs/          # モデル設定とテンプレート
├── scripts/          # データ生成スクリプト集
├── exp/              # コア生成エンジン
├── data_sft/         # SFTデータ処理
├── data_po/          # 嗜好データ処理
├── demo_production.ipynb  # 本番用ノートブック
├── demo_colab.ipynb       # Google Colab版
└── README.md              # このファイル
```

## 💡 使用方法

### パラメータ説明
- `model_path`: 使用するモデル（DeepSeek R1推奨）
- `total_prompts`: 生成する問題数
- `ins_temp`: 問題生成の創造性（推奨: 1.0-1.2）
- `res_temp`: 解答生成の一貫性（推奨: 0.0-0.2）

### 推奨設定例
```bash
# 高品質な数学推論データ生成
./magpie-deepseek-r1.sh deepseek-ai/DeepSeek-R1 1000 1.0 1.2 1.0 0.1
```

## 📖 詳細ドキュメント

- **論文**: [Magpie: Alignment Data Synthesis from Scratch](https://arxiv.org/abs/2406.08464)
- **元プロジェクト**: [Magpie-Align](https://magpie-align.github.io/)
- **モデルページ**: [DeepSeek R1](https://huggingface.co/deepseek-ai/DeepSeek-R1)

## 📄 ライセンス

このプロジェクトはMITライセンスの下で公開されています。

## 🙏 謝辞

このプロジェクトは、元のMagpieプロジェクトをベースに、HLE数学対策に特化した改良を加えたものです。元の研究チームに深く感謝いたします。