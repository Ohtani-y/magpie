# Magpie Math Dataset Generation - Code Analysis Report

## 調査概要

`./run_math_generation.sh 1 2` コマンドの実行フローとデータ生成プロセスを詳細に調査した結果をまとめる。

## 実行フロー詳細分析

### 1. コマンド引数解析

**実行コマンド**: `./run_math_generation.sh 1 2`

**引数マッピング** (`run_math_generation.sh:114-117`):
```bash
model_choice=$1    # 1 = deepseek-ai/DeepSeek-R1-Distill-Qwen-32B
mode_choice=$2     # 2 = All Domains (全ドメイン生成モード)
domain_choice=$3   # 未指定 (モード2では不要)
custom_count=$4    # 未指定 (モード2では固定カウント使用)
```

**モデル選択結果** (`run_math_generation.sh:155-169`):
- 選択: `deepseek-ai/DeepSeek-R1-Distill-Qwen-32B`
- 説明: "DeepSeek R1 Distill Qwen 32B (Recommended - Balanced performance)"

### 2. 全ドメイン生成モード実行

**モード2処理** (`run_math_generation.sh:226-235`):
```bash
echo "🚀 Starting complete dataset generation..."
echo "Model: DeepSeek R1 Distill Qwen 32B"
echo "Total problems: 44,000"
echo "Domains: Algebra (10K), Calculus (10K), Geometry (6K), Statistics (6K), Number Theory (4K), Discrete (8K)"

./generate_all_math_domains.sh "$MODEL"
```

### 3. 全ドメイン生成スクリプト詳細

**スクリプト**: `generate_all_math_domains.sh`

**ドメイン構成** (`generate_all_math_domains.sh:37-44`):
```bash
declare -A DOMAINS=(
    ["algebra"]="10000"      # 代数学
    ["calculus"]="10000"     # 微積分学
    ["geometry"]="6000"      # 幾何学
    ["statistics"]="6000"    # 統計学
    ["number_theory"]="4000" # 数論
    ["discrete"]="8000"      # 離散数学
)
```

**出力ディレクトリ構造** (`generate_all_math_domains.sh:56-58`):
```bash
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
MODEL_NAME=$(basename "$MODEL_PATH")  # DeepSeek-R1-Distill-Qwen-32B
BASE_OUTPUT_DIR="../data/${MODEL_NAME}_AllDomains_${TIMESTAMP}"
```

**例**: `../data/DeepSeek-R1-Distill-Qwen-32B_AllDomains_20240129_143052/`

### 4. 各ドメイン生成プロセス

**ドメイン処理ループ** (`generate_all_math_domains.sh:73-89`):

各ドメインに対して以下を実行:
1. `./generate_domain_dataset.sh "$MODEL_PATH" "$domain" "$count"`
2. 生成されたディレクトリを統合ディレクトリに移動

### 5. ドメイン別データセット生成詳細

**スクリプト**: `generate_domain_dataset.sh`

#### 5.1 ドメイン別パラメータ設定

**代数学** (`generate_domain_dataset.sh:66-72`):
```bash
INS_TEMP=1.3           # 高創造性（複雑問題生成用）
RES_TEMP=0.05          # 低温度（厳密解答用）
MAX_TOKENS_INS=1024    # 問題文最大トークン
MAX_TOKENS_RES=4096    # 解答最大トークン（15-20ステップ推論用）
DESCRIPTION="ADVANCED ALGEBRA - Abstract algebra, Galois theory, field extensions, matrix theory"
```

**微積分学** (`generate_domain_dataset.sh:74-78`):
```bash
INS_TEMP=1.2
RES_TEMP=0.0           # ゼロ温度（厳密分析証明用）
MAX_TOKENS_INS=1024
MAX_TOKENS_RES=4096
DESCRIPTION="ADVANCED CALCULUS - Real/complex analysis, measure theory, functional analysis"
```

**幾何学** (`generate_domain_dataset.sh:80-85`):
```bash
INS_TEMP=1.35          # 最高創造性（複雑幾何構成用）
RES_TEMP=0.05
MAX_TOKENS_INS=1024
MAX_TOKENS_RES=4096
DESCRIPTION="ADVANCED GEOMETRY - Projective geometry, differential geometry, algebraic geometry"
```

#### 5.2 4段階データ生成プロセス

**Step 1: 問題生成** (`generate_domain_dataset.sh:115-127`):
```bash
python ../exp/gen_ins.py \
    --model_path "$MODEL_PATH" \
    --save_path "$OUTPUT_DIR/${DOMAIN}_ins.json" \
    --total_prompts $PROBLEM_COUNT \
    --temperature $INS_TEMP \
    --control_tasks math \
    --domain "$DOMAIN" \
    --max_tokens $MAX_TOKENS_INS
```

**Step 2: 解答生成** (`generate_domain_dataset.sh:129-140`):
```bash
python ../exp/gen_res.py \
    --model_path "$MODEL_PATH" \
    --ins_data_path "$OUTPUT_DIR/${DOMAIN}_ins.json" \
    --save_path "$OUTPUT_DIR/${DOMAIN}_ins_res.json" \
    --temperature $RES_TEMP \
    --max_tokens $MAX_TOKENS_RES \
    --batch_size 4
```

**Step 3: 複数解答生成** (`generate_domain_dataset.sh:142-154`):
```bash
python ../exp/gen_po_multi_res.py \
    --model_path "$MODEL_PATH" \
    --ins_data_path "$OUTPUT_DIR/${DOMAIN}_ins.json" \
    --save_path "$OUTPUT_DIR/${DOMAIN}_ins_7res.json" \
    --temperature 0.8 \
    --num_responses 7 \
    --batch_size 2
```

**Step 4: 品質評価** (`generate_domain_dataset.sh:156-163`):
```bash
python ../exp/gen_po_rewards.py \
    --model_name_or_path "RLHFlow/ArmoRM-Llama3-8B-v0.1" \
    --ins_data_path "$OUTPUT_DIR/${DOMAIN}_ins_7res.json" \
    --save_path "$OUTPUT_DIR/${DOMAIN}_ins_7res_armorm.json"
```

### 6. 最終出力構造

#### 6.1 ディレクトリ構造
```
data/DeepSeek-R1-Distill-Qwen-32B_AllDomains_[TIMESTAMP]/
├── algebra/                           # 代数学ドメイン
│   ├── algebra_ins.json              # 問題のみ (10,000問題)
│   ├── algebra_ins_res.json          # SFT用: 問題+解答
│   ├── algebra_ins_7res_armorm.json  # 整列用: ランク付き7解答
│   └── dataset_info.json             # ドメイン固有メタデータ
├── calculus/                          # 微積分学ドメイン (10,000問題)
│   └── [同様構造]
├── geometry/                          # 幾何学ドメイン (6,000問題)
│   └── [同様構造]
├── statistics/                        # 統計学ドメイン (6,000問題)
│   └── [同様構造]
├── number_theory/                     # 数論ドメイン (4,000問題)
│   └── [同様構造]
├── discrete/                          # 離散数学ドメイン (8,000問題)
│   └── [同様構造]
├── combined_dataset_info.json         # 全体統合メタデータ
└── README.md                          # 使用ガイドドキュメント
```

#### 6.2 生成ファイル種類と用途

**問題ファイル** (`*_ins.json`):
- 内容: 数学問題のみ
- 用途: 指示生成、問題分析
- 形式: `{"instruction": "問題文"}`

**SFT訓練ファイル** (`*_ins_res.json`):
- 内容: 問題 + 単一解答
- 用途: Supervised Fine-Tuning
- 形式: `{"instruction": "問題文", "response": "詳細解答"}`

**整列訓練ファイル** (`*_ins_7res_armorm.json`):
- 内容: 問題 + ランク付き7解答
- 用途: DPO/RLHF整列訓練
- 形式: `{"instruction": "問題文", "responses": [...], "scores": [...]}`

#### 6.3 統合メタデータ

**combined_dataset_info.json** (`generate_all_math_domains.sh:94-139`):
```json
{
  "dataset_name": "Magpie-Math-Complete-HLE-44K",
  "model": "deepseek-ai/DeepSeek-R1-Distill-Qwen-32B",
  "total_problems": 44000,
  "generation_date": "[ISO timestamp]",
  "domains": {
    "algebra": {"problems": 10000, "description": "...", "directory": "algebra"},
    "calculus": {"problems": 10000, "description": "...", "directory": "calculus"},
    "geometry": {"problems": 6000, "description": "...", "directory": "geometry"},
    "statistics": {"problems": 6000, "description": "...", "directory": "statistics"},
    "number_theory": {"problems": 4000, "description": "...", "directory": "number_theory"},
    "discrete": {"problems": 8000, "description": "...", "directory": "discrete"}
  },
  "files_per_domain": {
    "instructions": "<domain>_ins.json",
    "sft_data": "<domain>_ins_res.json",
    "preference_data": "<domain>_ins_5res_armorm.json",
    "info": "dataset_info.json"
  }
}
```

### 7. 技術仕様詳細

#### 7.1 生成パラメータ最適化

**問題生成パラメータ**:
- 温度: 1.1-1.35 (ドメイン別最適化)
- Top-p: 1.0 (最大多様性)
- 最大トークン: 1024 (複雑問題対応)

**解答生成パラメータ**:
- 温度: 0.0-0.05 (厳密性重視)
- Top-p: 1.0
- 最大トークン: 4096 (詳細推論対応)

**複数解答生成パラメータ**:
- 温度: 0.8 (多様性確保)
- Top-p: 0.95
- 解答数: 7個 (品質選択用)

#### 7.2 品質保証システム

**評価モデル**: `RLHFlow/ArmoRM-Llama3-8B-v0.1`
- 機能: 解答品質ランキング
- 出力: スコア付き解答ペア
- 用途: 整列訓練データ作成

#### 7.3 最大難易度設定

**MAXIMUM DIFFICULTY MODE**:
- 研究レベル問題生成
- 10-20ステップ推論チェーン
- 4096トークン拡張解答
- 高度数学トピック対応

### 8. 実行時間とリソース要件

**推定実行時間**:
- 代数/微積分: 各~3-4時間 (10K問題)
- 幾何/統計: 各~2-3時間 (6K問題)
- 数論: ~1.5-2時間 (4K問題)
- 離散数学: ~2.5-3時間 (8K問題)
- **総実行時間**: 約15-20時間

**リソース要件**:
- GPU: A100 80GB推奨 (32GB最小)
- メモリ使用率: 95%
- 並列化: tensor_parallel_size=1
- バッチサイズ: 2-8 (ステップ別最適化)

### 9. データ品質特徴

**高難易度数学問題**:
- 抽象代数、ガロア理論、体拡張
- 実/複素解析、測度論、関数解析
- 射影幾何、微分幾何、代数幾何
- 測度論的確率、高等推論、マルチンゲール
- 解析的数論、代数的数論、L関数
- 極値グラフ理論、代数的組合せ論

**Chain-of-Thought特徴**:
- 15-20ステップ詳細推論
- 4096トークン拡張解答
- 厳密数学証明スタイル
- 多段階問題解決アプローチ

## 結論

`./run_math_generation.sh 1 2`の実行により、DeepSeek-R1-Distill-Qwen-32Bモデルを使用して44,000問題の包括的HLE数学データセットが生成される。6つの数学ドメインにわたり、SFT用とDPO/RLHF整列用の両方のデータ形式が提供され、研究レベルの高難易度問題と詳細推論チェーンが特徴となっている。