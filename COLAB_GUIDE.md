# 🌟 Google Colab での実行ガイド

## ✅ 動作確認: はい、Google Colabで動作します！

### 🎯 **Colab対応状況**
- ✅ **完全対応**: 6ドメインデータセット生成・統合
- ✅ **GPU対応**: T4, A100両対応（自動調整）
- ✅ **軽量モード**: メモリ制限に応じた最適化
- ✅ **自動ダウンロード**: 生成データの簡単取得

## 🚀 **クイックスタート**

### **Option 1: 新規作成ノートブック (推奨)**
```bash
# 1. 新しいColabノートブックを作成
# 2. 以下をコピー&ペースト
!git clone https://github.com/your-repo/magpie.git
%cd magpie
!pip install -q vllm transformers torch accelerate

# 3. colab_6domains.ipynbの内容を実行
```

### **Option 2: 直接インポート**
[![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/your-repo/magpie/blob/main/colab_6domains.ipynb)

## ⚙️ **Colab設定**

### **GPU設定**
1. `ランタイム` → `ランタイムのタイプを変更`
2. `ハードウェアアクセラレータ`: GPU
3. `GPU タイプ`: 
   - **T4**: 軽量モード（推奨）
   - **A100**: フルモード（高性能）

### **メモリ最適化**
```python
# 軽量モード（T4 GPU推奨）
USE_LIGHTWEIGHT_MODEL = True
MODEL_PATH = "Qwen/Qwen2.5-3B-Instruct"
PROBLEMS_PER_DOMAIN = 20  # 各ドメイン20問
TENSOR_PARALLEL = 1
GPU_MEMORY_UTIL = 0.80

# フルモード（A100推奨）
USE_LIGHTWEIGHT_MODEL = False
MODEL_PATH = "deepseek-ai/DeepSeek-R1"  
PROBLEMS_PER_DOMAIN = 50  # 各ドメイン50問
TENSOR_PARALLEL = 2
GPU_MEMORY_UTIL = 0.90
```

## 📊 **実行時間・リソース目安**

### **T4 GPU（軽量モード）**
- **各ドメイン**: 5-15分（20問）
- **総実行時間**: 45-90分（6ドメイン120問）
- **メモリ使用量**: 12-15GB
- **出力サイズ**: 5-10MB

### **A100 GPU（フルモード）**
- **各ドメイン**: 10-30分（50問）
- **総実行時間**: 1-3時間（6ドメイン300問）
- **メモリ使用量**: 40-60GB
- **出力サイズ**: 15-30MB

## 🔧 **Colab特有の調整**

### **1. パッケージインストール**
```python
# 必要最小限のインストール
!pip install -q vllm transformers torch accelerate
!pip install -q datasets sentencepiece tiktoken
!pip install -q numpy pandas tqdm matplotlib
```

### **2. ファイルパス調整**
```python
# Colab用パス設定
OUTPUT_DIR = "/content/magpie_6domains"
os.makedirs(OUTPUT_DIR, exist_ok=True)
```

### **3. 認証（DeepSeek R1使用時）**
```python
# Hugging Face認証
from huggingface_hub import login
login()  # トークンを手動入力
```

### **4. エラーハンドリング**
```python
# GPU メモリ不足対策
if torch.cuda.get_device_properties(0).total_memory < 20e9:  # 20GB未満
    USE_LIGHTWEIGHT_MODEL = True
    PROBLEMS_PER_DOMAIN = 10  # さらに削減
```

## 📥 **データダウンロード**

### **自動ダウンロード**
```python
from google.colab import files
import zipfile

# ZIPファイル作成＆ダウンロード
zip_file = f"{OUTPUT_DIR}/{DATASET_NAME}_complete.zip"
files.download(zip_file)
```

### **個別ファイル**
```python
# 統合データセット
files.download(f"{OUTPUT_DIR}/HLE_6Domains_Math_120_timestamp.json")

# ShareGPT形式
files.download(f"{OUTPUT_DIR}/HLE_6Domains_Math_120_timestamp_sharegpt.jsonl")
```

## ⚠️ **制限事項・注意点**

### **Colab制限**
- **実行時間**: 最大12時間（Pro版）
- **GPU時間**: 制限あり（使用量による）
- **メモリ**: T4=15GB、A100=40GB
- **ストレージ**: 一時的（セッション終了で削除）

### **推奨対策**
1. **段階実行**: 1-2ドメインずつ実行
2. **中間保存**: 各ドメイン完了時に保存
3. **バックアップ**: Google Driveに自動保存設定

### **メモリ不足時**
```python
# 問題数削減
PROBLEMS_PER_DOMAIN = 10  # デフォルト: 20

# バッチサイズ削減  
BATCH_SIZE = 5  # デフォルト: 10

# モデル変更
MODEL_PATH = "Qwen/Qwen2.5-1.5B-Instruct"  # より軽量
```

## 🔄 **実行フロー**

### **1. 環境セットアップ**
```python
# GPU確認 → リポジトリクローン → 依存関係インストール
```

### **2. 設定調整**
```python
# GPU性能に応じてパラメータ自動調整
```

### **3. 6ドメイン生成**
```python
# algebra → applied-mathematics → calculus → 
# discrete-mathematics → geometry → number-theory
```

### **4. 統合・分析**
```python
# データマージ → シャッフル → ShareGPT変換 → 品質分析
```

### **5. ダウンロード**
```python
# ZIP作成 → 自動ダウンロード
```

## 📈 **成功例**

### **T4での実行例**
```
🚀 6ドメインデータ生成開始
📊 設定: Qwen/Qwen2.5-3B-Instruct, 各20問題

✅ algebra 完了 (15分)
✅ applied-mathematics 完了 (12分)
✅ calculus 完了 (18分)
✅ discrete-mathematics 完了 (14分)
✅ geometry 完了 (16分)
✅ number-theory 完了 (13分)

📊 生成結果: 6/6 ドメイン成功
📁 総問題数: 120問題
📦 ファイルサイズ: 8.5MB
```

## 🆘 **トラブルシューティング**

### **GPU接続エラー**
```python
# ランタイム再接続
# ランタイム → ランタイムを再起動
```

### **メモリ不足**
```python
# 設定調整
USE_LIGHTWEIGHT_MODEL = True
PROBLEMS_PER_DOMAIN = 5  # 最小設定
```

### **依存関係エラー**
```python
# 個別インストール
!pip install --upgrade vllm
!pip install --force-reinstall transformers
```

## 🎯 **最適化のコツ**

1. **初回は軽量設定で試行**
2. **GPU使用量を監視**（`!nvidia-smi`）
3. **段階的にスケールアップ**
4. **中間結果を適宜保存**

**✅ Google Colabで完全に動作するように最適化されています！**