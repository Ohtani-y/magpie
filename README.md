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

## 📁 アーキテクチャ図

```mermaid
graph TB
    subgraph "入力設定"
        A[configs/model_configs.json<br/>📋 モデル設定・テンプレート]
        B[scripts/<br/>🚀 実行スクリプト群]
    end
    
    subgraph "コア生成エンジン"
        C[exp/gen_ins.py<br/>📝 数学問題生成]
        D[exp/gen_res.py<br/>🧠 Chain-of-Thought解答生成]
        E[exp/gen_po_multi_res.py<br/>🔀 複数候補解答生成]
        F[exp/gen_po_rewards.py<br/>⭐ 品質評価・ランキング]
    end
    
    subgraph "データ出力"
        G[data/<br/>📊 生成データ保存]
        H[data_sft/<br/>🎓 教師あり学習用データ]
        I[data_po/<br/>🎯 嗜好学習用データ]
    end
    
    subgraph "ユーザーインターフェース"
        J[demo_production.ipynb<br/>🖥️ 本番環境用]
        K[demo_colab.ipynb<br/>☁️ Google Colab用]
    end
    
    A --> C
    B --> C
    C --> G
    C --> D
    D --> G
    D --> E
    E --> F
    F --> G
    G --> H
    G --> I
    J --> B
    K --> B
    
    style A fill:#e1f5fe
    style C fill:#f3e5f5
    style D fill:#f3e5f5
    style E fill:#fff3e0
    style F fill:#fff3e0
    style G fill:#e8f5e8
    style H fill:#e8f5e8
    style I fill:#e8f5e8
```

## 📂 詳細フォルダ構成

```
magpie/
├── 📋 configs/
│   └── model_configs.json      # 20+モデルの設定・テンプレート
├── 🚀 scripts/
│   ├── magpie-deepseek-r1.sh   # DeepSeek R1専用（推奨）
│   ├── magpie-qwen2.5-math-72b.sh  # Qwen数学モデル用
│   ├── magpie-qwen2-math-7b.sh     # 軽量Qwen数学用
│   └── magpie_math.sh              # 汎用数学生成
├── 🔧 exp/                    # コア生成エンジン
│   ├── gen_ins.py             # 数学問題生成（制御タスク対応）
│   ├── gen_res.py             # Chain-of-Thought解答生成
│   ├── gen_po_multi_res.py    # 複数候補解答生成
│   ├── gen_po_rewards.py      # 品質評価システム
│   └── utils.py               # 共通ユーティリティ
├── 📊 data/                   # 生成データ保存場所
│   ├── DeepSeek-R1_*/         # DeepSeek R1生成データ
│   ├── Qwen2.5-3B-Instruct_*/ # Qwen生成データ
│   └── [model]_[timestamp]_*/ # その他モデルデータ
├── 🎓 data_sft/              # SFT用データ処理
│   ├── *.jsonl               # ShareGPT形式データ
│   ├── data_concatenation.ipynb  # データ結合処理
│   └── data_filter.ipynb         # データフィルタリング
├── 🎯 data_po/               # 嗜好データ処理
│   ├── example_*_5res.json   # 複数候補解答データ
│   ├── *_armorm.json         # 品質評価結果
│   └── process_po.ipynb      # 嗜好データ処理
├── 🖥️ demo_production.ipynb  # 本番環境用ノートブック
├── ☁️ demo_colab.ipynb       # Google Colab専用版
└── 📄 README.md              # プロジェクトドキュメント
```

## 🔄 データフロー

### 生成プロセス
```mermaid
sequenceDiagram
    participant U as User/Script
    participant C as configs/
    participant G1 as gen_ins.py
    participant G2 as gen_res.py
    participant G3 as gen_po_*
    participant D as data/
    participant DS as data_sft/
    participant DP as data_po/
    
    U->>C: モデル設定読み込み
    U->>G1: 数学問題生成実行
    G1->>D: *_ins.json保存
    
    G1->>G2: 問題ファイル渡し
    G2->>D: *_ins_res.json保存
    
    opt 嗜好データ生成時
        G2->>G3: 複数候補生成
        G3->>D: *_5res.json保存
        G3->>G3: 品質評価実行
        G3->>D: *_armorm.json保存
    end
    
    D->>DS: SFT用データ変換
    D->>DP: 嗜好データ変換
```

### データ形式の変遷
1. **Raw Generation**: `*_ins.json` (問題のみ)
2. **With Responses**: `*_ins_res.json` (問題+解答)  
3. **Quality Assessed**: `*_quality.json` (品質評価付き)
4. **Multi-Response**: `*_5res.json` (複数候補解答)
5. **Preference Data**: `*_armorm.json` (嗜好ランキング)

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

# パラメータ詳細:
# - deepseek-ai/DeepSeek-R1: モデルパス
# - 1000: 生成問題数
# - 1.0: instruction top_p
# - 1.2: instruction temperature  
# - 1.0: response top_p
# - 0.1: response temperature
```

## 🔄 6ドメインデータセット生成・統合機能

### **新機能: ドメイン別データ生成**

```bash
# 🚀 対話型実行 (推奨)
python scripts/run_example.py

# 🌟 Google Colab実行
# https://colab.research.google.com/github/your-repo/magpie/blob/main/colab_6domains.ipynb

# 手動実行
cd scripts
chmod +x *.sh
./generate_all_domains.sh

# 個別ドメイン生成
./magpie-deepseek-r1-domains.sh algebra deepseek-ai/DeepSeek-R1 100
./magpie-deepseek-r1-domains.sh calculus deepseek-ai/DeepSeek-R1 100
```

### **新機能: データ統合・シャッフル**

```bash
# 6ドメインデータを自動統合
python scripts/merge_domains.py --data_dir data --output_dir data

# 出力例:
# - DeepSeek-R1-Math-Combined-600_20250127_143022.json
# - DeepSeek-R1-Math-Combined-600_20250127_143022_sharegpt.jsonl
```

### **対応ドメイン**
1. **Algebra** (代数学): 方程式、多項式、関数
2. **Applied Mathematics** (応用数学): 微分方程式、最適化
3. **Calculus** (微積分学): 微積分、極限、級数
4. **Discrete Mathematics** (離散数学): 組合せ、グラフ理論
5. **Geometry** (幾何学): 解析幾何、空間図形
6. **Number Theory** (数論): 素数、合同式、暗号応用

## 📝 変更点詳細

### **追加ファイル（オリジナル変更なし）**
- `scripts/magpie-deepseek-r1-domains.sh`: ドメイン特化生成スクリプト
- `scripts/generate_all_domains.sh`: 6ドメイン一括生成
- `scripts/merge_domains.py`: データ統合・シャッフルツール
- `scripts/run_example.py`: 対話型実行スクリプト（推奨）
- `colab_6domains.ipynb`: **Google Colab完全対応版**
- `SETUP.md`: 詳細セットアップガイド
- `COLAB_GUIDE.md`: **Google Colab実行ガイド**

### **データ形式の変更点**
オリジナルデータに**最小限のメタデータのみ追加**:
```json
{
  "id": 0,
  "instruction": "元の問題文",
  "response": "元の解答",
  "domain": "algebra",          // 新規追加
  "source": "deepseek-r1",      // 新規追加
  "dataset_version": "1.0",     // 新規追加
  // 他の元フィールドはそのまま保持
}
```

### **機能的変更点**
1. **ドメイン自動検出**: DeepSeek R1生成ファイルを自動認識
2. **バランス保持**: 各ドメイン均等にシャッフル
3. **ShareGPT互換**: 機械学習フレームワーク対応
4. **メタデータ保持**: 生成設定情報を完全保持
5. **実行可能化**: gen_ins.py にドメインパラメータ追加
6. **エラーハンドリング**: 生成スクリプトに堅牢なエラー処理追加

### **保持される元情報**
- 全ての`gen_input_configs`
- 全ての`gen_response_configs`
- `pre_query_template`
- `created`タイムスタンプ
- DeepSeek R1特有の設定

## 📖 詳細ドキュメント

- **論文**: [Magpie: Alignment Data Synthesis from Scratch](https://arxiv.org/abs/2406.08464)
- **元プロジェクト**: [Magpie-Align](https://magpie-align.github.io/)
- **モデルページ**: [DeepSeek R1](https://huggingface.co/deepseek-ai/DeepSeek-R1)

## 📄 ライセンス

このプロジェクトはMITライセンスの下で公開されています。

## 🙏 謝辞

このプロジェクトは、元のMagpieプロジェクトをベースに、HLE数学対策に特化した改良を加えたものです。元の研究チームに深く感謝いたします。