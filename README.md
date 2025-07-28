# 🧮 Magpie Reasoning - HLE数学対策特化版

[![Magpie](figs/magpie_logo.png)](https://magpie-align.github.io/)

[![arXiv](https://img.shields.io/badge/arXiv-paper-b31b1b.svg)](https://arxiv.org/abs/2406.08464) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT) [![Data License](https://img.shields.io/badge/Data%20License-CC%20By%20NC%204.0-red.svg)](https://huggingface.co/Magpie-Align)

HLE（高等レベル試験）数学対策に特化したreasoning（推論）データセット生成システム。DeepSeek R1モデルを使用して、高品質な数学推論データを生成します。

## 🚀 クイックスタート

### 🌟 Google Colab版（推奨）

[![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/Ohtani-y/magpie/blob/main/generate_colab.ipynb)

**ワンクリックで始める最も簡単な方法！**
- 🎯 **対話式インターフェース**: ボタンクリックで全設定完了
- ⚡ **GPU自動設定**: T4/V100/A100で自動最適化
- 📊 **リアルタイム進捗**: 生成過程を視覚的に確認
- 📦 **ワンクリックダウンロード**: 生成データを即座にダウンロード

### 🖥️ ローカル環境版

```bash
# インストール
git clone https://github.com/Ohtani-y/magpie.git
cd magpie
pip install -r requirements.txt

# 対話式メニューで簡単生成（推奨）
cd scripts
./run_math_generation.sh

# または個別実行
./magpie-deepseek-r1.sh deepseek-ai/DeepSeek-R1 1000
```

## 🎯 特徴

- **🏆 最高難易度数学問題**: IMO、Putnam、PhD級の最難関レベル問題生成
- **🧠 超深層推論**: 10-20ステップの詳細な証明・解析チェーン（4096トークン）
- **6分野数学特化**: 代数・微積分・幾何・統計・数論・離散数学の研究レベル問題
- **6モデル対応**: DeepSeek R1 Distill、Gemma 3、Qwen2.5シリーズに最適化
- **研究レベルプロンプト**: 各分野で最先端の数学理論を要求するシステムプロンプト
- **対話式生成**: 簡単操作で最大44,000問の最高品質データセット
- **拡張Chain-of-Thought**: 大学院レベルの段階的思考プロセス（4096トークン）
- **高度な嗜好データ**: 5-7候補応答による精密な品質評価システム

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

## 🛠️ 対応モデル（HLE数学特化版）

### 限定6モデル対応

|モデル | GPU要件 | 推奨用途 | 実行スクリプト |
|-------|:-----:|:--------|:------------|
| **DeepSeek R1 Distill Qwen 32B** | V100 32GB+ | バランス型（推奨） | `./magpie-deepseek-r1-distill-qwen-32b.sh` |
| **DeepSeek R1 Distill Llama 70B** | A100 80GB | 高性能型 | `./magpie-deepseek-r1-distill-llama-70b.sh` |
| **DeepSeek R1 0528 FP4** | RTX 4090+ | メモリ効率型 | `./magpie-deepseek-r1-fp4.sh` |
| **Gemma 3 27B-it** | V100 32GB+ | Google最新モデル | `./magpie-gemma3-27b.sh` |
| **Qwen2.5-Math 72B** | A100 80GB | 数学特化モデル | `./magpie-qwen2.5-math-72b.sh` |
| **Qwen2.5-Coder 32B** | V100 32GB+ | 計算数学特化 | `./magpie-qwen25-coder-32b.sh` |

## 📊 分野別数学データセット

|数学分野 | データセット | 問題数 | 特徴 |
|-------------|:-------|:-------|:-------|
| **代数学 (Algebra)** | Magpie-Algebra-HLE-10K | 10,000 | 二次方程式、不等式、関数、数列、行列 |
| **微積分学 (Calculus)** | Magpie-Calculus-HLE-10K | 10,000 | 極限、微分、積分、応用問題、微分方程式 |
| **幾何学 (Geometry)** | Magpie-Geometry-HLE-6K | 6,000 | 平面・立体幾何、三角法、証明・作図 |
| **統計学 (Statistics)** | Magpie-Statistics-HLE-6K | 6,000 | 確率、統計的推論、回帰、データ分析 |
| **数論 (Number Theory)** | Magpie-NumberTheory-HLE-4K | 4,000 | 素数論、合同式、ディオファントス方程式 |
| **離散数学 (Discrete Math)** | Magpie-Discrete-HLE-8K | 8,000 | グラフ理論、組合せ論、論理、アルゴリズム |

### 🎯 生成方法

```bash
# 1. 対話式メニュー（最も簡単）
./run_math_generation.sh

# 2. 個別分野生成
./generate_domain_dataset.sh <model> <domain> <count>

# 3. 全分野一括生成（44K問題）
./generate_all_math_domains.sh <model>

# 例：代数学10,000問生成
./generate_domain_dataset.sh deepseek-ai/DeepSeek-R1-Distill-Qwen-32B algebra 10000
```

## 🎯 GPU要件

- **推奨**: NVIDIA A100 (80GB)
- **最小**: NVIDIA V100 (32GB) または RTX 4090 (24GB)

## 📁 アーキテクチャ図

```mermaid
graph TB
    subgraph "入力層"
        U[👤 ユーザー]
        M[run_math_generation.sh<br/>🎯 対話式メニュー]
    end
    
    subgraph "設定層"
        A[configs/model_configs.json<br/>📋 6モデル設定<br/>5分野テンプレート]
        B[scripts/<br/>🚀 専用実行スクリプト]
    end
    
    subgraph "分野別制御層"
        D1[generate_domain_dataset.sh<br/>📐 個別分野生成]
        D2[generate_all_math_domains.sh<br/>📊 全分野一括生成]
    end
    
    subgraph "モデル実行層"
        M1[DeepSeek R1 Distill Qwen 32B<br/>💚 バランス型]
        M2[DeepSeek R1 Distill Llama 70B<br/>💙 高性能型]
        M3[DeepSeek R1 FP4<br/>💛 メモリ効率型]
        M4[Gemma 3 27B-it<br/>🧡 Google最新]
        M5[Qwen2.5-Math 72B<br/>💜 数学特化]
        M6[Qwen2.5-Coder 32B<br/>❤️ 計算数学]
    end
    
    subgraph "生成エンジン層"
        C[exp/gen_ins.py<br/>📝 問題生成<br/>--domain対応]
        D[exp/gen_res.py<br/>🧠 CoT解答生成]
        E[exp/gen_po_multi_res.py<br/>🔀 5候補生成]
        F[exp/gen_po_rewards.py<br/>⭐ 品質評価]
    end
    
    subgraph "数学分野層"
        F1[代数学<br/>Algebra 10K]
        F2[微積分学<br/>Calculus 10K]
        F3[幾何学<br/>Geometry 6K]
        F4[統計学<br/>Statistics 6K]
        F5[数論<br/>Number Theory 4K]
        F6[離散数学<br/>Discrete 8K]
    end
    
    subgraph "データ出力層"
        G[data/<br/>📊 分野別保存]
        H[data_sft/<br/>🎓 SFTデータ]
        I[data_po/<br/>🎯 嗜好データ]
    end
    
    U --> M
    M --> D1
    M --> D2
    D1 --> M1
    D1 --> M2
    D1 --> M3
    D1 --> M4
    D1 --> M5
    D1 --> M6
    D2 --> M1
    D2 --> M2
    D2 --> M3
    D2 --> M4
    D2 --> M5
    D2 --> M6
    
    M1 --> C
    M2 --> C
    M3 --> C
    M4 --> C
    M5 --> C
    M6 --> C
    
    A --> C
    B --> C
    
    C --> F1
    C --> F2
    C --> F3
    C --> F4
    C --> F5
    C --> F6
    
    F1 --> D
    F2 --> D
    F3 --> D
    F4 --> D
    F5 --> D
    F6 --> D
    
    D --> E
    E --> F
    
    D --> G
    F --> G
    G --> H
    G --> I
    
    style U fill:#f0f8ff
    style M fill:#e8f5e9
    style A fill:#e1f5fe
    style C fill:#f3e5f5
    style D fill:#f3e5f5
    style E fill:#fff3e0
    style F fill:#fff3e0
    style G fill:#e8f5e8
    style H fill:#e8f5e8
    style I fill:#e8f5e8
    style M1 fill:#c8e6c9
    style M2 fill:#bbdefb
    style M3 fill:#fff9c4
    style M4 fill:#ffe0b2
    style M5 fill:#e1bee7
    style M6 fill:#ffcdd2
    style F1 fill:#d1c4e9
    style F2 fill:#d1c4e9
    style F3 fill:#d1c4e9
    style F4 fill:#d1c4e9
    style F5 fill:#d1c4e9
    style F6 fill:#d1c4e9
```

## 📂 詳細フォルダ構成

```
magpie/
├── 📋 configs/
│   └── model_configs.json      # 20+モデルの設定・テンプレート
├── 🚀 scripts/
│   ├── run_math_generation.sh       # 対話式メニュー（推奨）
│   ├── generate_domain_dataset.sh   # 個別分野生成
│   ├── generate_all_math_domains.sh # 全分野一括生成
│   ├── magpie-deepseek-r1-distill-qwen-32b.sh  # DeepSeek R1 Distill Qwen
│   ├── magpie-deepseek-r1-distill-llama-70b.sh # DeepSeek R1 Distill Llama
│   ├── magpie-deepseek-r1-fp4.sh    # DeepSeek R1 FP4量子化版
│   ├── magpie-gemma3-27b.sh         # Gemma 3 27B
│   ├── magpie-qwen2.5-math-72b.sh   # Qwen2.5-Math 72B
│   └── magpie-qwen25-coder-32b.sh   # Qwen2.5-Coder 32B
├── 🔧 exp/                    # コア生成エンジン
│   ├── gen_ins.py             # 数学問題生成（制御タスク対応）
│   ├── gen_res.py             # Chain-of-Thought解答生成
│   ├── gen_po_multi_res.py    # 複数候補解答生成
│   ├── gen_po_rewards.py      # 品質評価システム
│   └── utils.py               # 共通ユーティリティ
├── 📊 data/                   # 生成データ保存場所
│   ├── DeepSeek-R1-Distill-Qwen-32B_*/ # DeepSeek R1 Distillデータ
│   ├── Qwen2.5-Math-72B_*/     # Qwen2.5-Math生成データ
│   ├── Gemma-3-27B_*/          # Gemma 3生成データ
│   └── [model]_[domain]_[timestamp]/ # ドメイン別データ
├── 🎓 data_sft/              # SFT用データ処理
│   ├── *.jsonl               # ShareGPT形式データ
│   ├── data_concatenation.ipynb  # データ結合処理
│   └── data_filter.ipynb         # データフィルタリング
├── 🎯 data_po/               # 嗜好データ処理
│   ├── example_*_7res.json   # 複数候補解答データ（ドメイン生成）
│   ├── *_armorm.json         # 品質評価結果
│   └── process_po.ipynb      # 嗜好データ処理
├── 🖥️ demo_production.ipynb  # 本番環境用ノートブック
├── 🌟 generate_colab.ipynb   # Google Colab対話式ノートブック（推奨）
└── 📄 README.md              # プロジェクトドキュメント
```

## 🔄 数学分野別生成プロセス

### 分野別データ生成フロー
```mermaid
graph LR
    subgraph "🎯 入力選択"
        U[ユーザー]
        M[対話式メニュー<br/>./run_math_generation.sh]
    end
    
    subgraph "📐 代数学 (Algebra) - 10,000問"
        A1[二次方程式・不等式]
        A2[関数・数列]
        A3[行列演算]
        A_TEMP[temp: 1.2<br/>創造的問題生成]
    end
    
    subgraph "🔢 微積分学 (Calculus) - 10,000問"
        C1[極限・連続性]
        C2[微分・積分]
        C3[微分方程式]
        C_TEMP[temp: 1.1<br/>厳密な論理]
    end
    
    subgraph "📏 幾何学 (Geometry) - 6,000問"
        G1[平面幾何]
        G2[立体幾何]
        G3[三角法]
        G_TEMP[temp: 1.2<br/>視覚的推論]
    end
    
    subgraph "📊 統計学 (Statistics) - 6,000問"
        S1[確率論]
        S2[統計的推論]
        S3[回帰分析]
        S_TEMP[temp: 1.0<br/>正確性重視]
    end
    
    subgraph "🔢 数論 (Number Theory) - 4,000問"
        N1[素数・約数]
        N2[合同式]
        N3[暗号応用]
        N_TEMP[temp: 1.1<br/>深い洞察]
    end
    
    subgraph "🔲 離散数学 (Discrete Mathematics) - 8,000問"
        D1[グラフ理論]
        D2[組合せ論]
        D3[論理・アルゴリズム]
        D_TEMP[temp: 1.1<br/>アルゴリズム思考]
    end
    
    U --> M
    M --> A1 & A2 & A3
    M --> C1 & C2 & C3
    M --> G1 & G2 & G3
    M --> S1 & S2 & S3
    M --> N1 & N2 & N3
    M --> D1 & D2 & D3
    
    style A_TEMP fill:#ffe0e0
    style C_TEMP fill:#e0e0ff
    style G_TEMP fill:#e0ffe0
    style S_TEMP fill:#ffffe0
    style N_TEMP fill:#ffe0ff
    style D_TEMP fill:#e0ffff
```

### 生成プロセス詳細
```mermaid
sequenceDiagram
    participant U as ユーザー
    participant M as run_math_generation.sh
    participant G as generate_domain_dataset.sh
    participant C as configs/model_configs.json
    participant I as gen_ins.py
    participant R as gen_res.py
    participant P as gen_po_multi_res.py
    participant E as gen_po_rewards.py
    participant D as data/
    
    U->>M: 対話式メニュー起動
    M->>U: モデル選択 (6種)
    M->>U: 分野選択 (5分野)
    
    alt 代数学選択
        M->>G: algebra, 10000問
        G->>C: pre_query_template_algebra読込
        Note over G,C: 戦略的思考を促すプロンプト
    else 微積分学選択
        M->>G: calculus, 10000問
        G->>C: pre_query_template_calculus読込
        Note over G,C: 概念理解重視のプロンプト
    else 幾何学選択
        M->>G: geometry, 6000問
        G->>C: pre_query_template_geometry読込
        Note over G,C: 視覚的推論を促すプロンプト
    else 統計学選択
        M->>G: statistics, 6000問
        G->>C: pre_query_template_statistics読込
        Note over G,C: 実世界応用を重視
    else 数論選択
        M->>G: number_theory, 4000問
        G->>C: pre_query_template_number_theory読込
        Note over G,C: 深い数学的洞察を要求
    else 離散数学選択
        M->>G: discrete, 8000問
        G->>C: pre_query_template_discrete読込
        Note over G,C: アルゴリズム思考を促進
    end
    
    G->>I: 分野別問題生成 (--domain指定)
    I->>D: {domain}_ins.json保存
    
    G->>R: Chain-of-Thought解答生成
    Note over R: 分野別最適温度設定
    R->>D: {domain}_ins_res.json保存
    
    G->>P: 5候補解答生成
    P->>D: {domain}_ins_5res.json保存
    
    G->>E: 品質評価・ランキング
    E->>D: {domain}_ins_5res_armorm.json保存
    
    D->>U: 生成完了通知
```

### データ形式の変遷
1. **Raw Generation**: `*_ins.json` (問題のみ)
2. **With Responses**: `*_ins_res.json` (問題+解答)  
3. **Quality Assessed**: `*_quality.json` (品質評価付き)
4. **Multi-Response**: `*_5res.json` (複数候補解答)
5. **Preference Data**: `*_armorm.json` (嗜好ランキング)

## 💡 詳細な使用方法

### 🎯 分野特化生成の特徴

各数学分野には専用のシステムプロンプトが適用され、深い数学的思考を促進します：

#### 📐 代数学 (Algebra)
- **対象範囲**: 線形・二次方程式、連立方程式、不等式、関数、数列・級数、行列演算
- **専門性**: 機械的計算ではなく戦略的思考を重視
- **出力例**: 複素数を含む多項式の因数分解、関数の性質分析

#### 🔢 微積分学 (Calculus)  
- **対象範囲**: 極限・連続性、微分・積分技法、応用問題、微分方程式、多変数解析
- **専門性**: 概念理解を重視し、グラフィカル解釈を含む
- **出力例**: 最適化問題、関連する変化率、Taylor級数展開

#### 📏 幾何学 (Geometry)
- **対象範囲**: ユークリッド幾何、座標幾何、ベクトル、三角法、立体幾何
- **専門性**: 視覚的思考と空間的推論を促進
- **出力例**: 図形証明、座標変換、幾何不等式

#### 📊 統計学 (Statistics)
- **対象範囲**: 確率論、統計的推論、回帰分析、ベイズ統計、データ分析
- **専門性**: 実世界の文脈と結果の解釈を重視
- **出力例**: 仮説検定、信頼区間、統計モデリング

#### 🔢 数論 (Number Theory)
- **対象範囲**: 素数・約数、合同式、ディオファントス方程式、暗号への応用
- **専門性**: 深い数学的洞察と証明技法を要求
- **出力例**: 素数判定アルゴリズム、暗号理論の数学的基礎

#### 🔲 離散数学 (Discrete Mathematics)
- **対象範囲**: グラフ理論、組合せ論、論理学、集合論、再帰関係、アルゴリズム理論
- **専門性**: アルゴリズム思考と構造的推論を重視、帰納法・対偶証明を多用
- **出力例**: グラフの最短経路問題、組合せ最適化、論理回路設計、計算量解析
- **応用分野**: コンピュータサイエンス、情報工学、暗号学、ネットワーク理論

### 🏆 モデル別推奨設定

| モデル | 代数学 | 微積分学 | 幾何学 | 統計学 | 数論 | 離散数学 |
|--------|:-----:|:-------:|:-----:|:-----:|:---:|:-------:|
| **DeepSeek R1 Distill Qwen 32B** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **DeepSeek R1 Distill Llama 70B** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Qwen2.5-Math 72B** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| **Qwen2.5-Coder 32B** | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Gemma 3 27B-it** | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ |
| **DeepSeek R1 FP4** | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ |

### 📈 パフォーマンス指標 (2025年1月時点)

- **DeepSeek R1シリーズ**: AIME 2024で79.8%、MATH-500で97.3%の最高性能
- **Qwen2.5-Math 72B**: MATH benchmarkで80%+、128Kトークン対応
- **Gemma 3 27B**: Google最新モデル、バランス型性能
- **量子化版**: FP4量子化により70%のメモリ削減を実現

## 🌟 Google Colab詳細ガイド

### 🎯 Colab版の特徴

**⚡ 即座に開始**:
- 環境構築不要でブラウザから直接実行
- T4/V100/A100 GPU自動検出・最適化
- 依存関係の自動インストール

**🎮 直感的操作**:
```python
# 対話式ウィジェットでモデル選択
model_selector = widgets.Dropdown(
    options=[
        "1: DeepSeek R1 Distill Qwen 32B - バランス型（推奨）",
        "2: DeepSeek R1 Distill Llama 70B - 高性能型", 
        "3: DeepSeek R1 FP4 - メモリ効率型",
        "4: Gemma 3 27B - Google最新モデル",
        "5: Qwen2.5-Math 72B - 数学特化モデル",
        "6: Qwen2.5-Coder 32B - 計算数学特化"
    ]
)
```

**📊 リアルタイム監視**:
- GPU使用率・メモリ監視
- 生成進捗のリアルタイム表示
- サンプルデータの即座プレビュー

**📦 簡単ダウンロード**:
- ワンクリックでZIP圧縮・ダウンロード
- 全データセット（JSON、メタデータ）を一括取得
- Google Drive連携も可能

### 🚀 Colab実行手順

1. **ノートブック起動**: [![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/Ohtani-y/magpie/blob/main/generate_colab.ipynb)

2. **GPU設定**: `ランタイム` → `ランタイムの変更` → `T4 GPU`を選択

3. **セットアップ実行**: 最初のセルを実行して環境構築

4. **対話式生成**: ウィジェットでモデル・分野を選択し生成開始

5. **結果確認**: 生成データをプレビュー・ダウンロード

### 💡 Colab使用のヒント

- **長時間実行**: Pro版推奨（12時間連続実行可能）
- **メモリ管理**: 大きなモデルは段階的に実行
- **データ保存**: 定期的にGoogle Driveに保存
- **エラー対処**: ランタイム再起動で多くの問題が解決

## 📖 詳細ドキュメント

- **論文**: [Magpie: Alignment Data Synthesis from Scratch](https://arxiv.org/abs/2406.08464)
- **元プロジェクト**: [Magpie-Align](https://magpie-align.github.io/)
- **モデルページ**: [DeepSeek R1](https://huggingface.co/deepseek-ai/DeepSeek-R1)

## 📄 ライセンス

このプロジェクトはMITライセンスの下で公開されています。

## 🙏 謝辞

このプロジェクトは、元のMagpieプロジェクトをベースに、HLE数学対策に特化した改良を加えたものです。元の研究チームに深く感謝いたします。