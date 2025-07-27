# 🚀 セットアップ・実行ガイド

## 📋 前提条件

### **ハードウェア要件**
- **GPU**: NVIDIA A100 (80GB) 推奨、V100 (32GB) 最小
- **メモリ**: 32GB以上推奨
- **ストレージ**: 100GB以上の空き容量

### **ソフトウェア要件**
- Python 3.8+
- CUDA 11.8+
- pip または conda

## 🔧 インストール手順

### **1. リポジトリクローン**
```bash
git clone https://github.com/your-repo/magpie.git
cd magpie
```

### **2. 依存関係インストール**
```bash
pip install -r requirements.txt
```

### **3. 実行権限付与**
```bash
chmod +x scripts/*.sh
```

### **4. DeepSeek R1アクセス設定**
```bash
# Hugging Face Hubにログイン（DeepSeek R1アクセス用）
huggingface-cli login
```

## ⚡ クイックスタート

### **Option 1: 対話型デモ実行**
```bash
python scripts/run_example.py
```
選択肢:
- `1`: 単一ドメインテスト (algebra, 10問)
- `2`: 全6ドメイン軽量テスト (各5問)  
- `3`: フル実行 (各100問) ⚠️時間注意
- `4`: データ統合のみ

### **Option 2: 手動実行**

#### **単一ドメイン生成**
```bash
cd scripts
./magpie-deepseek-r1-domains.sh algebra deepseek-ai/DeepSeek-R1 100
```

#### **全6ドメイン一括生成**
```bash
cd scripts
./generate_all_domains.sh
```

#### **データ統合・シャッフル**
```bash
python scripts/merge_domains.py --data_dir data --output_dir data
```

## 📊 生成される出力

### **ドメイン別データ**
```
data/
├── DeepSeek-R1-algebra_100_[timestamp]/
│   ├── Magpie_DeepSeek-R1_100_[timestamp]_ins.json
│   └── Magpie_DeepSeek-R1_100_[timestamp]_ins_res.json
├── DeepSeek-R1-calculus_100_[timestamp]/
├── DeepSeek-R1-geometry_100_[timestamp]/
└── ...
```

### **統合データ**
```
data/
├── DeepSeek-R1-Math-Combined-600_[timestamp].json
└── DeepSeek-R1-Math-Combined-600_[timestamp]_sharegpt.jsonl
```

## 🎛️ パラメータ調整

### **生成パラメータ**
```bash
# カスタムパラメータでの実行
./magpie-deepseek-r1-domains.sh \
    algebra \                    # ドメイン
    deepseek-ai/DeepSeek-R1 \   # モデル
    100 \                       # 問題数
    1.0 \                       # instruction top_p
    1.2 \                       # instruction temperature
    1.0 \                       # response top_p
    0.1                         # response temperature
```

### **軽量テスト用設定**
```bash
# Qwen2.5-3Bで軽量テスト
./magpie-deepseek-r1-domains.sh \
    algebra \
    Qwen/Qwen2.5-3B-Instruct \
    10 \
    1.0 1.2 1.0 0.1
```

## 🐛 トラブルシューティング

### **GPU メモリ不足**
```bash
# tensor_parallelを減らす
# scripts/magpie-deepseek-r1-domains.sh 内で調整:
tensor_parallel=2  # デフォルト: 4
gpu_memory_utilization=0.80  # デフォルト: 0.90
```

### **CUDA エラー**
```bash
# CUDA環境確認
nvidia-smi
python -c "import torch; print(torch.cuda.is_available())"
```

### **Hugging Face アクセスエラー**
```bash
# 再ログイン
huggingface-cli logout
huggingface-cli login
```

### **権限エラー**
```bash
# 実行権限確認・付与
ls -la scripts/*.sh
chmod +x scripts/*.sh
```

## 📈 性能最適化

### **GPU設定**
```bash
# 複数GPU使用時
export CUDA_VISIBLE_DEVICES=0,1,2,3
# tensor_parallel=4 に設定
```

### **バッチサイズ調整**
```bash
# メモリに応じて調整
# scripts/magpie-deepseek-r1-domains.sh 内:
n=25          # デフォルト: 50
batch_size=25 # デフォルト: 50
```

## 🔍 データ検証

### **生成データ確認**
```bash
# 問題数カウント
python -c "
import json
with open('data/DeepSeek-R1-Math-Combined-*.json') as f:
    data = json.load(f)
    print(f'総問題数: {len(data)}')
"
```

### **ドメイン分布確認**
```bash
python -c "
import json
from collections import Counter
with open('data/DeepSeek-R1-Math-Combined-*.json') as f:
    data = json.load(f)
    domains = Counter(item['domain'] for item in data)
    for domain, count in domains.items():
        print(f'{domain}: {count}問題')
"
```

## 📝 カスタマイズ

### **新しいドメイン追加**
1. `scripts/generate_all_domains.sh` の `domains` 配列に追加
2. 対応するテンプレートを `configs/model_configs.json` に追加

### **モデル変更**
```bash
# 異なるモデルで実行
./magpie-deepseek-r1-domains.sh \
    algebra \
    Qwen/Qwen2.5-Math-72B-Instruct \
    100
```

## 🆘 サポート

問題が発生した場合:
1. `SETUP.md` の再確認
2. `scripts/run_example.py` でのテスト実行
3. ログファイル確認: `data/DeepSeek-R1-*/`
4. GPU メモリ・CUDA 環境確認

## 📚 関連ドキュメント

- [README.md](README.md) - プロジェクト概要
- [CHANGES.md](CHANGES.md) - 変更履歴
- [configs/model_configs.json](configs/model_configs.json) - モデル設定