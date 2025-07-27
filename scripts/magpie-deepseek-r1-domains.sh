#!/bin/bash

# DeepSeek R1による6ドメイン数学データセット生成スクリプト
# オリジナルのmagpie-deepseek-r1.shを基に、ドメイン特化版を作成

domain=${1:-"algebra"}
model_path=${2:-"deepseek-ai/DeepSeek-R1"}
total_prompts=${3:-100}
ins_topp=${4:-1.0}
ins_temp=${5:-1.2}
res_topp=${6:-1.0}
res_temp=${7:-0.1}

# 設定（オリジナルと同じ）
res_rep=1
device="0"
tensor_parallel=4
gpu_memory_utilization=0.90
n=50
batch_size=50

timestamp=$(date +%s)

# ドメイン名をファイル名に反映
job_name="DeepSeek-R1-${domain}_${total_prompts}_${timestamp}"

log_dir="data"
if [ ! -d "../${log_dir}" ]; then
    mkdir -p "../${log_dir}"
fi

job_path="../${log_dir}/${job_name}"

mkdir -p $job_path
exec > >(tee -a "$job_path/${job_name}.log") 2>&1

echo "[DeepSeek R1 ${domain}データ生成] モデル名: $model_path"
echo "[DeepSeek R1 ${domain}データ生成] ドメイン: $domain"
echo "[DeepSeek R1 ${domain}データ生成] ジョブ名: $job_name"
echo "[DeepSeek R1 ${domain}データ生成] 総問題数: $total_prompts"
echo "[DeepSeek R1 ${domain}データ生成] 問題生成設定: temp=$ins_temp, top_p=$ins_topp"
echo "[DeepSeek R1 ${domain}データ生成] 解答生成設定: temp=$res_temp, top_p=$res_topp, rep=$res_rep"
echo "[DeepSeek R1 ${domain}データ生成] システム設定: device=$device, n=$n, batch_size=$batch_size, tensor_parallel=$tensor_parallel"
echo "[DeepSeek R1 ${domain}データ生成] タイムスタンプ: $timestamp"
echo "[DeepSeek R1 ${domain}データ生成] GPU使用率: $gpu_memory_utilization"

echo "[DeepSeek R1 ${domain}データ生成] ${domain}問題生成を開始..."
CUDA_VISIBLE_DEVICES=$device python ../exp/gen_ins.py \
    --device $device \
    --model_path $model_path \
    --total_prompts $total_prompts \
    --top_p $ins_topp \
    --temperature $ins_temp \
    --tensor_parallel_size $tensor_parallel \
    --gpu_memory_utilization $gpu_memory_utilization \
    --control_tasks math \
    --n $n \
    --job_name $job_name \
    --timestamp $timestamp \
    --max_tokens 3072 \
    --max_model_len 8192 \
    --domain $domain

if [ $? -ne 0 ]; then
    echo "❌ 問題生成でエラーが発生しました"
    exit 1
fi

echo "[DeepSeek R1 ${domain}データ生成] ${domain}問題生成完了！"

echo "[DeepSeek R1 ${domain}データ生成] ${domain}解答生成を開始..."
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

if [ $? -ne 0 ]; then
    echo "❌ 解答生成でエラーが発生しました"
    exit 1
fi

echo "[DeepSeek R1 ${domain}データ生成] ${domain}解答生成完了！"
echo "[DeepSeek R1 ${domain}データ生成] ${domain}HLE対策用数学推論データセットが正常に生成されました。"
echo "[DeepSeek R1 ${domain}データ生成] 出力ファイル: $job_path/"