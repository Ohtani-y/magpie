# 🚀 実行ガイド：`./run_math_generation.sh 1 1.0 1`

このドキュメントでは、`./run_math_generation.sh 1 1.0 1`コマンドを実行した際の詳細な流れと出力を説明します。

## 🎯 コマンドの意味

```bash
./run_math_generation.sh 1 1.0 1
```

- **引数1**: `1` = DeepSeek-R1-Distill-Qwen-32B（推奨モデル）
- **引数2**: `1.0` = 100%の生成倍率（標準サイズ）
- **引数3**: `1` = 全ドメイン生成モード

## 📊 実行フロー詳細

### ステップ1: 初期化と引数解析

```
Running in non-interactive mode
Model: 1, Scale: 1.0, Mode: 1

Selected: DeepSeek R1 Distill Qwen 32B
生成倍率: 1.0x
```

**何が起こっているか:**
- スクリプトが非対話モードで起動
- 引数を解析してモデル設定を確定
- `deepseek-ai/DeepSeek-R1-Distill-Qwen-32B`モデルを選択

### ステップ2: 生成計画の計算

```
🚀 Starting complete dataset generation...
Model: DeepSeek R1 Distill Qwen 32B
生成倍率: 1.0x

Total problems: 44,000
Domains: Algebra (10,000), Calculus (10,000), Geometry (6,000), Statistics (6,000), Number Theory (4,000), Discrete (8,000)
```

**計算内容:**
- 代数学: 10,000 × 1.0 = 10,000問
- 微積分: 10,000 × 1.0 = 10,000問  
- 幾何学: 6,000 × 1.0 = 6,000問
- 統計学: 6,000 × 1.0 = 6,000問
- 数論: 4,000 × 1.0 = 4,000問
- 離散数学: 8,000 × 1.0 = 8,000問
- **合計: 44,000問**

### ステップ3: 一時スクリプト生成

**内部処理:**
1. `generate_all_math_domains.sh`をコピー
2. 各ドメインの問題数を計算結果で置換
3. 一時実行ファイルを作成

```bash
# 内部で実行される置換処理
sed -i 's/\["algebra"\]="10000"/["algebra"]="10000"/' $TEMP_SCRIPT
sed -i 's/\["calculus"\]="10000"/["calculus"]="10000"/' $TEMP_SCRIPT
sed -i 's/\["geometry"\]="6000"/["geometry"]="6000"/' $TEMP_SCRIPT
sed -i 's/\["statistics"\]="6000"/["statistics"]="6000"/' $TEMP_SCRIPT
sed -i 's/\["number_theory"\]="4000"/["number_theory"]="4000"/' $TEMP_SCRIPT
sed -i 's/\["discrete"\]="8000"/["discrete"]="8000"/' $TEMP_SCRIPT
```

### ステップ4: 各ドメインのデータ生成

`generate_all_math_domains.sh`により、6つのドメインが順次実行されます：

#### 4.1 代数学 (Algebra) - 10,000問
```bash
./generate_domain_dataset.sh "deepseek-ai/DeepSeek-R1-Distill-Qwen-32B" "algebra" "10000"
```

**内部で実行されるスクリプト:**
1. `exp/gen_ins.py` - 問題生成
2. `exp/gen_res.py` - 解答生成  
3. `exp/gen_po_multi_res.py` - 5候補解答生成
4. `exp/gen_po_rewards.py` - 品質評価・ランキング

**出力ファイル:**
- `data/DeepSeek-R1-Distill-Qwen-32B_algebra_ins.json` (問題のみ)
- `data/DeepSeek-R1-Distill-Qwen-32B_algebra_ins_res.json` (SFTデータ)
- `data/DeepSeek-R1-Distill-Qwen-32B_algebra_ins_5res.json` (5候補)
- `data/DeepSeek-R1-Distill-Qwen-32B_algebra_ins_5res_armorm.json` (嗜好データ)

#### 4.2 微積分 (Calculus) - 10,000問
同様の処理が微積分ドメインで実行

#### 4.3 幾何学 (Geometry) - 6,000問
同様の処理が幾何学ドメインで実行

#### 4.4 統計学 (Statistics) - 6,000問
同様の処理が統計学ドメインで実行

#### 4.5 数論 (Number Theory) - 4,000問
同様の処理が数論ドメインで実行

#### 4.6 離散数学 (Discrete Mathematics) - 8,000問
同様の処理が離散数学ドメインで実行

## 📁 最終的な出力構造

実行完了後、`data/`ディレクトリに以下の構造でファイルが生成されます：

```
data/
├── DeepSeek-R1-Distill-Qwen-32B_algebra_ins.json                 (10,000問)
├── DeepSeek-R1-Distill-Qwen-32B_algebra_ins_res.json            (SFTデータ)
├── DeepSeek-R1-Distill-Qwen-32B_algebra_ins_5res.json           (5候補)
├── DeepSeek-R1-Distill-Qwen-32B_algebra_ins_5res_armorm.json    (嗜好データ)
├── DeepSeek-R1-Distill-Qwen-32B_calculus_ins.json               (10,000問)
├── DeepSeek-R1-Distill-Qwen-32B_calculus_ins_res.json           (SFTデータ)
├── DeepSeek-R1-Distill-Qwen-32B_calculus_ins_5res.json          (5候補)
├── DeepSeek-R1-Distill-Qwen-32B_calculus_ins_5res_armorm.json   (嗜好データ)
├── DeepSeek-R1-Distill-Qwen-32B_geometry_ins.json               (6,000問)
├── DeepSeek-R1-Distill-Qwen-32B_geometry_ins_res.json           (SFTデータ)
├── DeepSeek-R1-Distill-Qwen-32B_geometry_ins_5res.json          (5候補)
├── DeepSeek-R1-Distill-Qwen-32B_geometry_ins_5res_armorm.json   (嗜好データ)
├── DeepSeek-R1-Distill-Qwen-32B_statistics_ins.json             (6,000問)
├── DeepSeek-R1-Distill-Qwen-32B_statistics_ins_res.json         (SFTデータ)
├── DeepSeek-R1-Distill-Qwen-32B_statistics_ins_5res.json        (5候補)
├── DeepSeek-R1-Distill-Qwen-32B_statistics_ins_5res_armorm.json (嗜好データ)
├── DeepSeek-R1_Distill-Qwen-32B_number_theory_ins.json          (4,000問)
├── DeepSeek-R1-Distill-Qwen-32B_number_theory_ins_res.json      (SFTデータ)
├── DeepSeek-R1-Distill-Qwen-32B_number_theory_ins_5res.json     (5候補)
├── DeepSeek-R1-Distill-Qwen-32B_number_theory_ins_5res_armorm.json (嗜好データ)
├── DeepSeek-R1-Distill-Qwen-32B_discrete_ins.json               (8,000問)
├── DeepSeek-R1-Distill-Qwen-32B_discrete_ins_res.json           (SFTデータ)
├── DeepSeek-R1-Distill-Qwen-32B_discrete_ins_5res.json          (5候補)
└── DeepSeek-R1-Distill-Qwen-32B_discrete_ins_5res_armorm.json   (嗜好データ)
```

## 📊 データ形式詳細

### 1. `*_ins.json` - 問題のみ
```json
[
  {
    "instruction": "Solve for x: 2x + 3 = 7",
    "id": "algebra_001"
  }
]
```

### 2. `*_ins_res.json` - SFTデータ（問題+解答）
```json
[
  {
    "instruction": "Solve for x: 2x + 3 = 7",
    "response": "To solve for x:\n2x + 3 = 7\n2x = 7 - 3\n2x = 4\nx = 2",
    "id": "algebra_001"
  }
]
```

### 3. `*_ins_5res.json` - 5候補解答
```json
[
  {
    "instruction": "Solve for x: 2x + 3 = 7",
    "responses": [
      "Method 1: Direct solving...",
      "Method 2: Graphical approach...",
      "Method 3: Substitution...",
      "Method 4: Using properties...",
      "Method 5: Alternative method..."
    ],
    "id": "algebra_001"
  }
]
```

### 4. `*_ins_5res_armorm.json` - 嗜好データ（評価済み）
```json
[
  {
    "instruction": "Solve for x: 2x + 3 = 7",
    "chosen": "To solve for x:\n2x + 3 = 7\n2x = 7 - 3\n2x = 4\nx = 2",
    "rejected": "x = 2 (without steps)",
    "score_chosen": 0.95,
    "score_rejected": 0.65,
    "id": "algebra_001"
  }
]
```

## ⏱️ 実行時間の目安

**GPU要件別の推定実行時間（44,000問生成）:**

| GPU | 推定時間 | メモリ使用量 |
|-----|----------|-------------|
| RTX 4090 (24GB) | 6-8時間 | ~20GB |
| V100 (32GB) | 4-6時間 | ~28GB |
| A100 (80GB) | 2-4時間 | ~35GB |

## 🔧 実行中のモニタリング

### GPU使用率確認
```bash
nvidia-smi -l 1
```

### 進捗確認
```bash
# 生成済みファイル数を確認
ls data/ | grep DeepSeek-R1-Distill-Qwen-32B | wc -l

# 各ドメインの進捗確認
tail -f logs/generation.log  # ログファイルがある場合
```

### ディスク使用量
```bash
du -sh data/
```

**推定ファイルサイズ:**
- 合計: ~15-20GB（44,000問）
- ドメインあたり: ~2-4GB

## 🔚 完了メッセージ

```
🎉 Generation complete!
Check the data/ directory for generated datasets.
```

実行が成功すると、上記メッセージが表示され、すべてのファイルが`data/`ディレクトリに保存されます。

## 🚨 よくあるエラーと対処法

### GPU メモリ不足
```
OutOfMemoryError: CUDA out of memory
```
**対処法:** 生成倍率を下げる（`0.5`や`0.1`を使用）

### モデルアクセスエラー
```
HuggingFace Hub error: Repository not found
```
**対処法:** Hugging Face認証を確認

### ディスク容量不足
```
No space left on device
```
**対処法:** 十分な空き容量（30GB以上推奨）を確保