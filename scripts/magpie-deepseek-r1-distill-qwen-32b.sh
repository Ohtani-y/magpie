#!/bin/bash

# DeepSeek R1 Distill Qwen 32B - Math Dataset Generation Script

MODEL_PATH="${1:-deepseek-ai/DeepSeek-R1-Distill-Qwen-32B}"
TOTAL_PROMPTS="${2:-1000}"
INS_TOPP="${3:-1.0}"
INS_TEMP="${4:-1.2}"
RES_TOPP="${5:-1.0}"
RES_TEMP="${6:-0.1}"

echo "🧮 DeepSeek R1 Distill Qwen 32B - Math Dataset Generation"
echo "========================================================"
echo "Model: $MODEL_PATH"
echo "Total prompts: $TOTAL_PROMPTS"
echo "Instruction generation: top_p=$INS_TOPP, temp=$INS_TEMP"
echo "Response generation: top_p=$RES_TOPP, temp=$RES_TEMP"

cd "$(dirname "$0")"

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
OUTPUT_DIR="../data/DeepSeek-R1-Distill-Qwen-32B_${TIMESTAMP}"
mkdir -p "$OUTPUT_DIR"

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
    --control_tasks math

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
    --batch_size 8

# Step 3: Generate multiple responses for alignment data
echo -e "\n🔄 Generating multiple responses for preference learning..."
python ../exp/gen_po_multi_res.py \
    --model_path "$MODEL_PATH" \
    --ins_data_path "$OUTPUT_DIR/math_ins.json" \
    --save_path "$OUTPUT_DIR/math_ins_5res.json" \
    --gpu_memory_utilization 0.9 \
    --tensor_parallel_size 2 \
    --temperature 0.7 \
    --top_p 0.9 \
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