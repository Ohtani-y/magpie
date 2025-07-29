#!/bin/bash

# Require explicit model path argument
if [ -z "$1" ]; then
    echo "❌ エラー: モデルパスが指定されていません"
    echo "📋 使用方法: $0 <model_path> [total_prompts] [ins_topp] [ins_temp] [res_topp] [res_temp]"
    echo "💡 例: $0 deepseek-ai/DeepSeek-R1 1000"
    exit 1
fi
model_path="$1"
total_prompts=${2:-1000}
ins_topp=${3:-1.0}
ins_temp=${4:-1.2}
res_topp=${5:-1.0}
res_temp=${6:-0.1}

res_rep=1
device="0"
tensor_parallel=1  # RTX A2000用に調整
gpu_memory_utilization=0.85
n=32  # バッチサイズを小さくしてメモリ使用量を調整
batch_size=32

timestamp=$(date +%s)

job_name="DeepSeek-R1-Probability_${total_prompts}_${timestamp}"

log_dir="data"
if [ ! -d "../${log_dir}" ]; then
    mkdir -p "../${log_dir}"
fi

job_path="../${log_dir}/${job_name}"

mkdir -p $job_path
exec > >(tee -a "$job_path/${job_name}.log") 2>&1

echo "[確率分野データ生成] モデル名: $model_path"
echo "[確率分野データ生成] ジョブ名: $job_name"
echo "[確率分野データ生成] 総問題数: $total_prompts"
echo "[確率分野データ生成] 問題生成設定: temp=$ins_temp, top_p=$ins_topp"
echo "[確率分野データ生成] 解答生成設定: temp=$res_temp, top_p=$res_topp, rep=$res_rep"
echo "[確率分野データ生成] システム設定: device=$device, n=$n, batch_size=$batch_size, tensor_parallel=$tensor_parallel"
echo "[確率分野データ生成] タイムスタンプ: $timestamp"
echo "[確率分野データ生成] GPU使用率: $gpu_memory_utilization"

echo "[確率分野データ生成] 確率問題生成を開始..."
CUDA_VISIBLE_DEVICES=$device python ../exp/gen_ins.py \
    --device $device \
    --model_path $model_path \
    --total_prompts $total_prompts \
    --top_p $ins_topp \
    --temperature $ins_temp \
    --tensor_parallel_size $tensor_parallel \
    --gpu_memory_utilization $gpu_memory_utilization \
    --control_tasks probability \
    --n $n \
    --job_name $job_name \
    --timestamp $timestamp \
    --max_tokens 3072 \
    --max_model_len 8192

echo "[確率分野データ生成] 確率問題生成完了！"

echo "[確率分野データ生成] 確率解答生成を開始..."
CUDA_VISIBLE_DEVICES=$device python ../exp/gen_res.py \
    --device $device \
    --model_path $model_path \
    --batch_size $batch_size \
    --top_p $res_topp \
    --temperature $res_temp \
    --repetition_penalty $res_rep \
    --tensor_parallel_size $tensor_parallel \
    --gpu_memory_utilization $gpu_memory_utilization \
    --input_file $job_path/Magpie_${model_path##*/}_${total_prompts}_${timestamp}_ins.json \
    --use_tokenizer_template \
    --offline \
    --max_tokens 4096

echo "[確率分野データ生成] 確率解答生成完了！"
echo "[確率分野データ生成] 確率理論特化データセットが正常に生成されました。"
echo "[確率分野データ生成] 出力ファイル: $job_path/"
