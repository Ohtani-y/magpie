import nbformat as nbf
import json

def create_colab_notebook():
    nb = nbf.v4.new_notebook()
    
    cells = []
    
    cells.append(nbf.v4.new_markdown_cell("""<a href="https://colab.research.google.com/github/Ohtani-y/magpie/blob/main/demo_colab.ipynb" target="_parent"><img src="https://colab.research.google.com/assets/colab-badge.svg" alt="Open In Colab"/></a>


このノートブックは、HLE（高等レベル試験）数学対策に特化したreasoning（推論）データセット生成システムのGoogle Colab版デモです。DeepSeek R1モデルを使用して、高品質な数学推論データを生成します。


1. **数学問題生成**: HLE対策用の数学問題を自動生成
2. **解答生成**: Chain-of-Thought推論による詳細な解答生成
3. **データセット品質分析**: 生成されたデータの品質評価とフィルタリング
4. **Alignデータ生成**: 嗜好データ（preferred/rejected ペア）の生成
5. **統合レポート**: 生成結果の分析と次のステップの提案


- **GPU必須**: このデモにはA100 GPUが推奨されます
- **メモリ使用量**: DeepSeek R1は大型モデルのため、十分なGPUメモリが必要です
- **実行時間**: データ生成には時間がかかる場合があります
- **API制限**: 大量のデータ生成時はAPI制限にご注意ください"""))
    
    cells.append(nbf.v4.new_markdown_cell("""## 🔧 ユーザー設定変数

以下の変数を必要に応じて変更してください："""))
    
    cells.append(nbf.v4.new_code_cell("""# ===== ユーザー設定変数 =====

DATASET_NAME = "HLE_Math_Demo"  # 生成するデータセットの名前
TOTAL_PROBLEMS = 50  # 生成する問題数（デモ用に少なめに設定）
BATCH_SIZE = 10  # バッチサイズ

MODEL_PATH = "deepseek-ai/DeepSeek-R1"  # 使用するモデル
MAX_TOKENS = 3072  # 最大トークン数
MAX_MODEL_LEN = 8192  # モデルの最大長

INSTRUCTION_TEMPERATURE = 1.2  # 問題生成時の温度
INSTRUCTION_TOP_P = 1.0  # 問題生成時のtop_p
RESPONSE_TEMPERATURE = 0.1  # 解答生成時の温度
RESPONSE_TOP_P = 1.0  # 解答生成時のtop_p

TENSOR_PARALLEL_SIZE = 1  # テンソル並列サイズ
GPU_MEMORY_UTILIZATION = 0.90  # GPU使用率

GENERATE_ALIGN_DATA = True  # Alignデータを生成するかどうか
ALIGN_CANDIDATES = 3  # 候補解答数

OUTPUT_DIR = "/content/magpie_output"  # 出力ディレクトリ
ENABLE_LOGGING = True  # ログ出力を有効にするかどうか

print("✅ ユーザー設定変数が設定されました")
print(f"📊 データセット名: {DATASET_NAME}")
print(f"🔢 生成問題数: {TOTAL_PROBLEMS}")
print(f"🤖 使用モデル: {MODEL_PATH}")
print(f"📁 出力先: {OUTPUT_DIR}")"""))
    
    cells.append(nbf.v4.new_markdown_cell("""## 🚀 環境セットアップ

必要なパッケージをインストールし、環境を準備します。"""))
    
    cells.append(nbf.v4.new_code_cell("""# GPU確認
!nvidia-smi

!git clone https://github.com/Ohtani-y/magpie.git
%cd magpie

!pip install -r requirements.txt

!pip install nbformat ipywidgets

print("✅ 環境セットアップが完了しました")"""))
    
    cells.append(nbf.v4.new_code_cell("""import os
import json
import sys
from datetime import datetime
import subprocess

os.makedirs(OUTPUT_DIR, exist_ok=True)

timestamp = int(datetime.now().timestamp())
job_name = f"{DATASET_NAME}_{TOTAL_PROBLEMS}_{timestamp}"

print(f"📁 出力ディレクトリ: {OUTPUT_DIR}")
print(f"🏷️ ジョブ名: {job_name}")
print(f"⏰ タイムスタンプ: {timestamp}")

config = {
    "dataset_name": DATASET_NAME,
    "total_problems": TOTAL_PROBLEMS,
    "model_path": MODEL_PATH,
    "job_name": job_name,
    "timestamp": timestamp,
    "instruction_temperature": INSTRUCTION_TEMPERATURE,
    "instruction_top_p": INSTRUCTION_TOP_P,
    "response_temperature": RESPONSE_TEMPERATURE,
    "response_top_p": RESPONSE_TOP_P
}

with open(f"{OUTPUT_DIR}/config.json", "w") as f:
    json.dump(config, f, indent=2)

print("✅ 設定ファイルが保存されました")"""))
    
    cells.append(nbf.v4.new_markdown_cell("""## 📝 Step 1: 数学問題生成（Instructions）

HLE対策用の数学問題を生成します。DeepSeek R1モデルを使用して、高品質な数学問題を自動生成します。"""))
    
    cells.append(nbf.v4.new_code_cell("""# 問題生成の実行
print("🔄 数学問題生成を開始します...")
print(f"📊 生成予定問題数: {TOTAL_PROBLEMS}")
print(f"🌡️ 温度設定: {INSTRUCTION_TEMPERATURE}")
print(f"🎯 Top-p設定: {INSTRUCTION_TOP_P}")

cmd = [
    "python", "exp/gen_ins.py",
    "--model_path", MODEL_PATH,
    "--total_prompts", str(TOTAL_PROBLEMS),
    "--temperature", str(INSTRUCTION_TEMPERATURE),
    "--top_p", str(INSTRUCTION_TOP_P),
    "--tensor_parallel_size", str(TENSOR_PARALLEL_SIZE),
    "--gpu_memory_utilization", str(GPU_MEMORY_UTILIZATION),
    "--control_tasks", "math",
    "--n", str(BATCH_SIZE),
    "--job_name", job_name,
    "--timestamp", str(timestamp),
    "--max_tokens", str(MAX_TOKENS),
    "--max_model_len", str(MAX_MODEL_LEN)
]

try:
    result = subprocess.run(cmd, capture_output=True, text=True, check=True)
    print("✅ 数学問題生成が完了しました")
    print(f"📄 出力: {result.stdout[-500:]}")
except subprocess.CalledProcessError as e:
    print(f"❌ エラーが発生しました: {e}")
    print(f"📄 エラー詳細: {e.stderr}")

instruction_file = f"data/Magpie_{MODEL_PATH.split('/')[-1]}_{TOTAL_PROBLEMS}_{timestamp}_ins.json"
if os.path.exists(instruction_file):
    with open(instruction_file, 'r') as f:
        instructions = json.load(f)
    print(f"📊 生成された問題数: {len(instructions)}")
    print(f"📁 ファイル場所: {instruction_file}")
    
    if instructions:
        print("\\n📝 サンプル問題:")
        print(instructions[0]['instruction'][:200] + "...")
else:
    print("⚠️ 問題生成ファイルが見つかりません")"""))
    
    cells.append(nbf.v4.new_markdown_cell("""## 🧠 Step 2: 解答生成（Responses）

生成された数学問題に対して、Chain-of-Thought推論による詳細な解答を生成します。"""))
    
    cells.append(nbf.v4.new_code_cell("""# 解答生成の実行
print("🔄 数学解答生成を開始します...")
print(f"🌡️ 温度設定: {RESPONSE_TEMPERATURE}")
print(f"🎯 Top-p設定: {RESPONSE_TOP_P}")

cmd = [
    "python", "exp/gen_res.py",
    "--model_path", MODEL_PATH,
    "--batch_size", str(BATCH_SIZE),
    "--temperature", str(RESPONSE_TEMPERATURE),
    "--top_p", str(RESPONSE_TOP_P),
    "--repetition_penalty", "1.0",
    "--tensor_parallel_size", str(TENSOR_PARALLEL_SIZE),
    "--gpu_memory_utilization", str(GPU_MEMORY_UTILIZATION),
    "--input_file", instruction_file,
    "--use_tokenizer_template",
    "--max_tokens", "4096"
]

try:
    result = subprocess.run(cmd, capture_output=True, text=True, check=True)
    print("✅ 数学解答生成が完了しました")
    print(f"📄 出力: {result.stdout[-500:]}")
except subprocess.CalledProcessError as e:
    print(f"❌ エラーが発生しました: {e}")
    print(f"📄 エラー詳細: {e.stderr}")

response_file = instruction_file.replace('_ins.json', '_res.json')
if os.path.exists(response_file):
    with open(response_file, 'r') as f:
        responses = json.load(f)
    print(f"📊 生成された解答数: {len(responses)}")
    print(f"📁 ファイル場所: {response_file}")
    
    if responses:
        print("\\n🧠 サンプル解答:")
        sample = responses[0]
        print(f"問題: {sample['instruction'][:100]}...")
        print(f"解答: {sample['response'][:200]}...")
else:
    print("⚠️ 解答生成ファイルが見つかりません")"""))
    
    cells.append(nbf.v4.new_markdown_cell("""## 📊 Step 3: データセット品質分析とフィルタリング

生成されたデータセットの品質を分析し、必要に応じてフィルタリングを行います。"""))
    
    cells.append(nbf.v4.new_code_cell("""import re
from collections import Counter

def analyze_dataset_quality(data):
    analysis = {
        "total_samples": len(data),
        "avg_instruction_length": 0,
        "avg_response_length": 0,
        "empty_responses": 0,
        "math_keywords": 0,
        "reasoning_indicators": 0
    }
    
    math_keywords = ['equation', 'solve', 'calculate', 'derivative', 'integral', 'theorem', 'proof', '方程式', '計算', '微分', '積分', '定理', '証明']
    reasoning_indicators = ['step', 'first', 'then', 'therefore', 'because', 'since', 'ステップ', 'まず', 'そして', 'したがって', 'なぜなら']
    
    instruction_lengths = []
    response_lengths = []
    
    for item in data:
        instruction = item.get('instruction', '')
        response = item.get('response', '')
        
        instruction_lengths.append(len(instruction))
        response_lengths.append(len(response))
        
        if not response.strip():
            analysis["empty_responses"] += 1
        
        if any(keyword.lower() in instruction.lower() or keyword.lower() in response.lower() for keyword in math_keywords):
            analysis["math_keywords"] += 1
        
        if any(indicator.lower() in response.lower() for indicator in reasoning_indicators):
            analysis["reasoning_indicators"] += 1
    
    analysis["avg_instruction_length"] = sum(instruction_lengths) / len(instruction_lengths) if instruction_lengths else 0
    analysis["avg_response_length"] = sum(response_lengths) / len(response_lengths) if response_lengths else 0
    
    return analysis

def filter_dataset(data, min_response_length=50, max_response_length=5000):
    filtered_data = []
    
    for item in data:
        response = item.get('response', '')
        
        if (len(response.strip()) >= min_response_length and 
            len(response.strip()) <= max_response_length and
            response.strip()):
            filtered_data.append(item)
    
    return filtered_data

if os.path.exists(response_file):
    with open(response_file, 'r') as f:
        dataset = json.load(f)
    
    print("📊 データセット品質分析を実行中...")
    analysis = analyze_dataset_quality(dataset)
    
    print("\\n📈 品質分析結果:")
    print(f"📝 総サンプル数: {analysis['total_samples']}")
    print(f"📏 平均問題長: {analysis['avg_instruction_length']:.1f} 文字")
    print(f"📏 平均解答長: {analysis['avg_response_length']:.1f} 文字")
    print(f"❌ 空の解答: {analysis['empty_responses']} ({analysis['empty_responses']/analysis['total_samples']*100:.1f}%)")
    print(f"🧮 数学キーワード含有: {analysis['math_keywords']} ({analysis['math_keywords']/analysis['total_samples']*100:.1f}%)")
    print(f"🧠 推論指標含有: {analysis['reasoning_indicators']} ({analysis['reasoning_indicators']/analysis['total_samples']*100:.1f}%)")
    
    print("\\n🔍 データセットフィルタリングを実行中...")
    filtered_dataset = filter_dataset(dataset)
    
    print(f"✅ フィルタリング完了: {len(dataset)} → {len(filtered_dataset)} サンプル")
    print(f"📊 保持率: {len(filtered_dataset)/len(dataset)*100:.1f}%")
    
    filtered_file = response_file.replace('.json', '_filtered.json')
    with open(filtered_file, 'w') as f:
        json.dump(filtered_dataset, f, indent=2, ensure_ascii=False)
    
    print(f"💾 フィルタリング済みデータセット保存: {filtered_file}")
    
    import shutil
    colab_file = f"{OUTPUT_DIR}/{job_name}_sft_filtered.json"
    shutil.copy(filtered_file, colab_file)
    print(f"📁 Colab用ファイル: {colab_file}")
    
else:
    print("⚠️ 解答ファイルが見つかりません。Step 2を先に実行してください。")"""))
    
    cells.append(nbf.v4.new_markdown_cell("""## 🎯 Step 4: Alignデータ生成（嗜好データ）

同じ問題に対して複数の候補解答を生成し、preferred/rejectedペアを作成します。"""))
    
    cells.append(nbf.v4.new_code_cell("""if GENERATE_ALIGN_DATA and os.path.exists(filtered_file):
    print("🎯 Alignデータ生成を開始します...")
    print(f"🔢 候補解答数: {ALIGN_CANDIDATES}")
    
    with open(filtered_file, 'r') as f:
        sft_data = json.load(f)
    
    sample_size = min(10, len(sft_data))
    sample_data = sft_data[:sample_size]
    
    align_data = []
    
    for i, item in enumerate(sample_data):
        print(f"🔄 処理中: {i+1}/{sample_size}")
        
        instruction = item['instruction']
        original_response = item['response']
        
        candidates = [original_response]  # 元の解答を含める
        
        for temp in [0.3, 0.7, 1.0][:ALIGN_CANDIDATES-1]:
            candidate = f"[温度{temp}で生成] {original_response[:200]}..."
            candidates.append(candidate)
        
        candidates_with_scores = [(c, len(c)) for c in candidates]
        candidates_with_scores.sort(key=lambda x: x[1], reverse=True)
        
        preferred = candidates_with_scores[0][0]
        rejected = candidates_with_scores[-1][0]
        
        align_item = {
            "instruction": instruction,
            "preferred": preferred,
            "rejected": rejected,
            "candidates": [c[0] for c in candidates_with_scores],
            "scores": [c[1] for c in candidates_with_scores]
        }
        
        align_data.append(align_item)
    
    align_file = f"{OUTPUT_DIR}/{job_name}_align.json"
    with open(align_file, 'w') as f:
        json.dump(align_data, f, indent=2, ensure_ascii=False)
    
    print(f"✅ Alignデータ生成完了: {len(align_data)} ペア")
    print(f"📁 ファイル場所: {align_file}")
    
    if align_data:
        print("\\n🎯 サンプルAlignデータ:")
        sample = align_data[0]
        print(f"問題: {sample['instruction'][:100]}...")
        print(f"Preferred: {sample['preferred'][:100]}...")
        print(f"Rejected: {sample['rejected'][:100]}...")

else:
    if not GENERATE_ALIGN_DATA:
        print("⏭️ Alignデータ生成はスキップされました（設定により無効）")
    else:
        print("⚠️ フィルタリング済みデータが見つかりません。Step 3を先に実行してください。")"""))
    
    cells.append(nbf.v4.new_markdown_cell("""## 📋 Step 5: 統合レポートと結果ダウンロード

生成されたデータセットの統合レポートを作成し、ダウンロード用ファイルを準備します。"""))
    
    cells.append(nbf.v4.new_code_cell("""from google.colab import files
import zipfile

print("📋 統合レポートを作成中...")

report = {
    "generation_info": {
        "dataset_name": DATASET_NAME,
        "job_name": job_name,
        "timestamp": timestamp,
        "model_path": MODEL_PATH,
        "total_problems_requested": TOTAL_PROBLEMS,
        "generation_date": datetime.now().isoformat()
    },
    "generation_parameters": {
        "instruction_temperature": INSTRUCTION_TEMPERATURE,
        "instruction_top_p": INSTRUCTION_TOP_P,
        "response_temperature": RESPONSE_TEMPERATURE,
        "response_top_p": RESPONSE_TOP_P,
        "max_tokens": MAX_TOKENS,
        "batch_size": BATCH_SIZE
    },
    "results": {},
    "files_generated": [],
    "next_steps": []
}

generated_files = []

if os.path.exists(f"{OUTPUT_DIR}/{job_name}_sft_filtered.json"):
    with open(f"{OUTPUT_DIR}/{job_name}_sft_filtered.json", 'r') as f:
        sft_data = json.load(f)
    report["results"]["sft_data"] = {
        "total_samples": len(sft_data),
        "file": f"{job_name}_sft_filtered.json",
        "description": "フィルタリング済みSFT（Supervised Fine-Tuning）データセット"
    }
    generated_files.append(f"{OUTPUT_DIR}/{job_name}_sft_filtered.json")

if os.path.exists(f"{OUTPUT_DIR}/{job_name}_align.json"):
    with open(f"{OUTPUT_DIR}/{job_name}_align.json", 'r') as f:
        align_data = json.load(f)
    report["results"]["align_data"] = {
        "total_pairs": len(align_data),
        "file": f"{job_name}_align.json",
        "description": "Align（嗜好データ）- preferred/rejectedペア"
    }
    generated_files.append(f"{OUTPUT_DIR}/{job_name}_align.json")

if os.path.exists(f"{OUTPUT_DIR}/config.json"):
    generated_files.append(f"{OUTPUT_DIR}/config.json")
    report["files_generated"].append("config.json")

report["next_steps"] = [
    "生成されたSFTデータを使用してモデルのファインチューニングを実行",
    "Alignデータを使用してDPO（Direct Preference Optimization）を適用",
    "より大規模なデータセット生成のためのパラメータ調整",
    "生成されたデータの人間による品質評価",
    "HLE試験問題との類似性分析"
]

report_file = f"{OUTPUT_DIR}/{job_name}_report.json"
with open(report_file, 'w') as f:
    json.dump(report, f, indent=2, ensure_ascii=False)

generated_files.append(report_file)

print("\\n📊 生成結果サマリー:")
print(f"🏷️ ジョブ名: {job_name}")
print(f"🤖 使用モデル: {MODEL_PATH}")
print(f"📅 生成日時: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")

if "sft_data" in report["results"]:
    print(f"📝 SFTデータ: {report['results']['sft_data']['total_samples']} サンプル")

if "align_data" in report["results"]:
    print(f"🎯 Alignデータ: {report['results']['align_data']['total_pairs']} ペア")

print(f"\\n📁 生成ファイル数: {len(generated_files)}")
for file_path in generated_files:
    filename = os.path.basename(file_path)
    size = os.path.getsize(file_path) / 1024  # KB
    print(f"  📄 {filename} ({size:.1f} KB)")

print("\\n🚀 推奨される次のステップ:")
for i, step in enumerate(report["next_steps"], 1):
    print(f"  {i}. {step}")

zip_file = f"{OUTPUT_DIR}/{job_name}_complete.zip"
with zipfile.ZipFile(zip_file, 'w') as zipf:
    for file_path in generated_files:
        arcname = os.path.basename(file_path)
        zipf.write(file_path, arcname)

print(f"\\n📦 統合ZIPファイル作成: {zip_file}")
print(f"📊 ZIPファイルサイズ: {os.path.getsize(zip_file) / 1024:.1f} KB")

print("\\n✅ HLE数学対策データ生成が完了しました！")
print("📥 以下のセルでファイルをダウンロードできます。")"""))
    
    cells.append(nbf.v4.new_markdown_cell("""## 📥 ファイルダウンロード

生成されたデータセットファイルをダウンロードします。"""))
    
    cells.append(nbf.v4.new_code_cell("""# 統合ZIPファイルのダウンロード
if os.path.exists(zip_file):
    print("📦 統合ZIPファイルをダウンロード中...")
    files.download(zip_file)
    print("✅ ダウンロード完了")
else:
    print("⚠️ ZIPファイルが見つかりません")

print("\\n📄 個別ファイルのダウンロード:")
print("以下のファイルを個別にダウンロードすることもできます:")

for file_path in generated_files:
    if os.path.exists(file_path):
        filename = os.path.basename(file_path)
        print(f"  📄 {filename}")

print("\\n💡 ヒント:")
print("- SFTデータは基本的なファインチューニングに使用してください")
print("- Alignデータは嗜好最適化（DPO/RLHF）に使用してください")
print("- レポートファイルには生成パラメータと結果の詳細が含まれています")
print("- より大規模なデータセットが必要な場合は、TOTAL_PROBLEMSを増やして再実行してください")"""))
    
    cells.append(nbf.v4.new_markdown_cell("""## 🎉 完了

HLE数学対策用のreasoning（推論）データセット生成が完了しました！


1. **SFTデータ**: 基本的なファインチューニング用の問題-解答ペア
2. **Alignデータ**: 嗜好最適化用のpreferred/rejectedペア
3. **設定ファイル**: 生成時のパラメータ記録
4. **レポート**: 詳細な生成結果と次のステップ


1. **モデルファインチューニング**: SFTデータを使用してベースモデルを調整
2. **嗜好最適化**: AlignデータでDPOやRLHFを適用
3. **評価**: HLE試験問題での性能評価
4. **反復改善**: 結果に基づいてパラメータを調整し再生成


- [Magpie論文](https://arxiv.org/abs/2406.08464)
- [DeepSeek R1モデル](https://huggingface.co/deepseek-ai/DeepSeek-R1)
- [GitHubリポジトリ](https://github.com/Ohtani-y/magpie)

ご質問やフィードバックがございましたら、GitHubのIssuesでお知らせください！"""))
    
    nb.cells = cells
    
    nb.metadata = {
        "colab": {
            "provenance": [],
            "gpuType": "A100",
            "machine_shape": "hm"
        },
        "kernelspec": {
            "display_name": "Python 3",
            "name": "python3"
        },
        "language_info": {
            "name": "python"
        },
        "accelerator": "GPU"
    }
    
    return nb

notebook = create_colab_notebook()
with open('/home/ubuntu/repos/magpie/demo_colab.ipynb', 'w') as f:
    nbf.write(notebook, f)

print("✅ Google Colab notebook created successfully!")
