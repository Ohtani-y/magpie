# 汎用数学データ生成スクリプト

model_path=${1:-"Qwen/Qwen2.5-3B-Instruct"}  # モデル名を引数として受け取る(入力しない場合のデフォルトはQwen/Qwen2.5-3B-Instruct)
total_prompts=${2:-1000}  # 生成する問題数を引数として受け取る(入力しない場合のデフォルトは1000)
control_tasks=${3:-"math"}  # テンプレートを指定する単語を引数として受け取る（math、code、translation、probabilityなど）（7/25引数追加）
ins_topp=${4:-1}  # 指示生成のtop_pを引数として受け取る(入力しない場合のデフォルトは1)
ins_temp=${5:-1}  # 指示生成のtemperatureを引数として受け取る(入力しない場合のデフォルトは1)
res_topp=${6:-1}  # 解答生成のtop_pを引数として受け取る(入力しない場合のデフォルトは1)
res_temp=${7:-0}  # 解答生成のtemperatureを引数として受け取る(入力しない場合のデフォルトは0)
res_rep=1  # 解答生成のrepetition_penaltyを引数として受け取る(入力しない場合のデフォルトは1)

device="0"  # GPUを指定する

tensor_parallel=1  # テンソル並列化のサイズを指定する
gpu_memory_utilization=0.95  # GPUメモリ使用率を指定する
# n=200
n=32  # バッチサイズを小さくしてメモリ使用量を調整
# batch_size=200
batch_size=32  # バッチサイズを小さくしてメモリ使用量を調整

# Get Current Time
timestamp=$(date +%s)

# Generate Pretty Name
# job_name="${model_path##*/}_topp${ins_topp}_temp${ins_temp}_${timestamp}"
job_name="${model_path##*/}_topp${ins_topp}_temp${ins_temp}_Number-Theory"

### Setup Logging
log_dir="data"
if [ ! -d "../${log_dir}" ]; then
    mkdir -p "../${log_dir}"
fi

job_path="../${log_dir}/${job_name}"

mkdir -p $job_path
exec > >(tee -a "$job_path/${job_name}.log") 2>&1
echo "[magpie.sh] Model Name: $model_path"
echo "[magpie.sh] Pretty name: $job_name"
echo "[magpie.sh] Total Prompts: $total_prompts"
echo "[magpie.sh] Instruction Generation Config: temp=$ins_temp, top_p=$ins_topp"
echo "[magpie.sh] Response Generation Config: temp=$res_temp, top_p=$res_topp, rep=$res_rep"
echo "[magpie.sh] System Config: device=$device, n=$n, batch_size=$batch_size, tensor_parallel=$tensor_parallel"
echo "[magpie.sh] Timestamp: $timestamp"
echo "[magpie.sh] Job Name: $job_name"

echo "[magpie.sh] Start Generating Instructions..."
CUDA_VISIBLE_DEVICES=$device python ../exp/gen_ins.py \
    --device $device \
    --model_path $model_path \
    --total_prompts $total_prompts \
    --top_p $ins_topp \
    --temperature $ins_temp \
    --tensor_parallel $tensor_parallel \
    --gpu_memory_utilization $gpu_memory_utilization \
    --control_tasks $control_tasks \
    --n $n \
    --job_name $job_name \
    --timestamp $timestamp

echo "[magpie.sh] Finish Generating Instructions!"

echo "[magpie.sh] Start Generating Responses..."
CUDA_VISIBLE_DEVICES=$device python ../exp/gen_res.py \
    --device $device \
    --model_path $model_path \
    --batch_size $batch_size \
    --top_p $res_topp \
    --temperature $res_temp \
    --repetition_penalty $res_rep \
    --tensor_parallel $tensor_parallel \
    --gpu_memory_utilization $gpu_memory_utilization \
    --input_file $job_path/Magpie_${model_path##*/}_${total_prompts}_${timestamp}_ins.json \
    --offline

echo "[magpie.sh] Finish Generating Responses!"
