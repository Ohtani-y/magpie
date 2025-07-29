#!/bin/bash

# Qwen2.5-Coder-32B-Instruct - Math Dataset Generation Script

# Require explicit model path argument
if [ -z "$1" ]; then
    echo "❌ エラー: モデルパスが指定されていません"
    echo "📋 使用方法: $0 <model_path> [total_prompts] [ins_topp] [ins_temp] [res_topp] [res_temp]"
    echo "💡 例: $0 Qwen/Qwen2.5-Coder-32B-Instruct 1000"
    exit 1
fi
MODEL_PATH="$1"
TOTAL_PROMPTS="${2:-1000}"
INS_TOPP="${3:-1.0}"
INS_TEMP="${4:-1.1}"
RES_TOPP="${5:-1.0}"
RES_TEMP="${6:-0.1}"

echo "🧮 Qwen2.5-Coder-32B-Instruct - Math Dataset Generation"
echo "====================================================="
echo "Model: $MODEL_PATH"
echo "Total prompts: $TOTAL_PROMPTS"
echo "Instruction generation: top_p=$INS_TOPP, temp=$INS_TEMP"
echo "Response generation: top_p=$RES_TOPP, temp=$RES_TEMP"

cd "$(dirname "$0")"

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
OUTPUT_DIR="../data/Qwen2.5-Coder-32B-Instruct_${TIMESTAMP}"
mkdir -p "$OUTPUT_DIR"

# Note: Qwen2.5-Coder can handle mathematical algorithms and computational math
echo -e "\n💻 Using Qwen2.5-Coder for computational mathematics"

# Step 1: Generate math instructions
echo -e "\n📝 Generating math instructions..."
python ../exp/gen_ins.py \
    --model_path "$MODEL_PATH" \
    --save_path "$OUTPUT_DIR/math_ins.json" \
    --gpu_memory_utilization 0.9 \
    --total_prompts $TOTAL_PROMPTS \
    --tensor_parallel_size 2 \
    --top_p $INS_TOPP \
    --temperature $INS_TEMP \
    --control_tasks math \
    --max_tokens 512

# Step 2: Generate responses with Chain-of-Thought
echo -e "\n🧠 Generating Chain-of-Thought responses..."
python ../exp/gen_res.py \
    --model_path "$MODEL_PATH" \
    --ins_data_path "$OUTPUT_DIR/math_ins.json" \
    --save_path "$OUTPUT_DIR/math_ins_res.json" \
    --gpu_memory_utilization 0.9 \
    --tensor_parallel_size 2 \
    --top_p $RES_TOPP \
    --temperature $RES_TEMP \
    --batch_size 8 \
    --max_tokens 2048

# Step 3: Generate multiple responses for alignment data
echo -e "\n🔄 Generating multiple responses for preference learning..."
python ../exp/gen_po_multi_res.py \
    --model_path "$MODEL_PATH" \
    --ins_data_path "$OUTPUT_DIR/math_ins.json" \
    --save_path "$OUTPUT_DIR/math_ins_5res.json" \
    --gpu_memory_utilization 0.9 \
    --tensor_parallel_size 2 \
    --temperature 0.6 \
    --top_p 0.95 \
    --max_tokens 2048 \
    --num_responses 5

# Step 4: Evaluate response quality
echo -e "\n⭐ Evaluating response quality..."
python ../exp/gen_po_rewards.py \
    --model_name_or_path "RLHFlow/ArmoRM-Llama3-8B-v0.1" \
    --ins_data_path "$OUTPUT_DIR/math_ins_5res.json" \
    --save_path "$OUTPUT_DIR/math_ins_5res_armorm.json" \
    --gpu_memory_utilization 0.9 \
    --batch_size 16

echo -e "\n✅ Generation complete!"
echo "Output files:"
echo "  - Instructions: $OUTPUT_DIR/math_ins.json"
echo "  - SFT data: $OUTPUT_DIR/math_ins_res.json"
echo "  - Preference data: $OUTPUT_DIR/math_ins_5res_armorm.json"