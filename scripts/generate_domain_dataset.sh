#!/bin/bash

# Domain-Specific Math Dataset Generation Script
# Generates specialized datasets for each math domain with recommended problem counts

set -e

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${GREEN}🧮 Domain-Specific Math Dataset Generator${NC}"
echo "=============================================="

# Model configuration
MODEL_PATH="${1}"
DOMAIN="${2}"
PROBLEM_COUNT="${3}"

if [ -z "$MODEL_PATH" ] || [ -z "$DOMAIN" ] || [ -z "$PROBLEM_COUNT" ]; then
    echo -e "${RED}Usage: $0 <model_path> <domain> <problem_count>${NC}"
    echo ""
    echo "Available domains:"
    echo "  - algebra        (Recommended: 10,000 problems)"
    echo "  - calculus       (Recommended: 10,000 problems)"
    echo "  - geometry       (Recommended: 6,000 problems)"
    echo "  - statistics     (Recommended: 6,000 problems)"
    echo "  - number_theory  (Recommended: 4,000 problems)"
    echo "  - discrete       (Recommended: 8,000 problems)"
    echo ""
    echo "Example: $0 deepseek-ai/DeepSeek-R1-Distill-Qwen-32B algebra 10000"
    exit 1
fi

# Domain validation
case $DOMAIN in
    algebra|calculus|geometry|statistics|number_theory|discrete)
        ;;
    *)
        echo -e "${RED}Invalid domain: $DOMAIN${NC}"
        echo "Valid domains: algebra, calculus, geometry, statistics, number_theory, discrete"
        exit 1
        ;;
esac

# Generate timestamp
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
MODEL_NAME=$(basename "$MODEL_PATH")
OUTPUT_DIR="../data/${MODEL_NAME}_${DOMAIN}_${TIMESTAMP}"

echo -e "${BLUE}Configuration:${NC}"
echo "  Model: $MODEL_PATH"
echo "  Domain: $DOMAIN"
echo "  Problem count: $PROBLEM_COUNT"
echo "  Output directory: $OUTPUT_DIR"
echo ""

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Domain-specific parameters optimized for MAXIMUM DIFFICULTY and DEEP REASONING
case $DOMAIN in
    "algebra")
        INS_TEMP=1.3       # High creativity for complex problem generation
        RES_TEMP=0.05      # Low temp for precise, rigorous solutions
        MAX_TOKENS_INS=1024   # Extended space for complex problem statements
        MAX_TOKENS_RES=4096   # Large space for detailed 15-20 step proofs
        DESCRIPTION="ADVANCED ALGEBRA - Abstract algebra, Galois theory, field extensions, matrix theory"
        ;;
    "calculus")
        INS_TEMP=1.2       # Balanced creativity for sophisticated analysis problems
        RES_TEMP=0.0       # Zero temp for rigorous analytical proofs
        MAX_TOKENS_INS=1024   # Extended space for complex multi-variable problems
        MAX_TOKENS_RES=4096   # Large space for detailed analytical reasoning
        DESCRIPTION="ADVANCED CALCULUS - Real/complex analysis, measure theory, functional analysis"
        ;;
    "geometry")
        INS_TEMP=1.35      # High creativity for complex geometric configurations
        RES_TEMP=0.05      # Low temp for precise geometric proofs
        MAX_TOKENS_INS=1024   # Extended space for complex constructions
        MAX_TOKENS_RES=4096   # Large space for detailed geometric reasoning
        DESCRIPTION="ADVANCED GEOMETRY - Projective geometry, differential geometry, algebraic geometry"
        ;;
    "statistics")
        INS_TEMP=1.1       # Moderate creativity for sophisticated statistical problems
        RES_TEMP=0.0       # Zero temp for rigorous statistical inference
        MAX_TOKENS_INS=1024   # Extended space for complex statistical scenarios
        MAX_TOKENS_RES=4096   # Large space for detailed statistical proofs
        DESCRIPTION="ADVANCED STATISTICS - Measure-theoretic probability, advanced inference, martingales"
        ;;
    "number_theory")
        INS_TEMP=1.25      # High creativity for deep number theory problems
        RES_TEMP=0.0       # Zero temp for rigorous number-theoretic proofs
        MAX_TOKENS_INS=1024   # Extended space for complex Diophantine problems
        MAX_TOKENS_RES=4096   # Large space for detailed number-theoretic reasoning
        DESCRIPTION="ADVANCED NUMBER THEORY - Analytic number theory, algebraic number theory, L-functions"
        ;;
    "discrete")
        INS_TEMP=1.3       # High creativity for complex combinatorial problems
        RES_TEMP=0.05      # Low temp for precise algorithmic analysis
        MAX_TOKENS_INS=1024   # Extended space for complex combinatorial constructions
        MAX_TOKENS_RES=4096   # Large space for detailed combinatorial proofs
        DESCRIPTION="ADVANCED DISCRETE MATH - Extremal graph theory, algebraic combinatorics, complexity theory"
        ;;
esac

echo -e "${GREEN}🎯 データセット生成を開始します${NC}"
echo -e "${BLUE}対象分野: $DESCRIPTION${NC}"
echo -e "${BLUE}生成問題数: $PROBLEM_COUNT 問${NC}"
echo -e "${BLUE}使用モデル: $MODEL_PATH${NC}"
echo ""

cd "$(dirname "$0")"

# Progress tracking function
log_progress() {
    local step="$1"
    local total="$2"
    local message="$3"
    local detail="$4"
    echo -e "${CYAN}[ステップ $step/$total] $message${NC}"
    if [ -n "$detail" ]; then
        echo -e "${GRAY}  → $detail${NC}"
    fi
    echo ""
}

# Step 1: Generate domain-specific instructions
log_progress "1" "4" "📝 数学問題の生成" "${DOMAIN}分野の問題を${PROBLEM_COUNT}問生成中..."
echo -e "${YELLOW}⏳ 推定時間: 5-10分 (問題数により変動)${NC}"
python ../exp/gen_ins.py \
    --model_path "$MODEL_PATH" \
    --save_path "$OUTPUT_DIR/${DOMAIN}_ins.json" \
    --gpu_memory_utilization 0.95 \
    --total_prompts $PROBLEM_COUNT \
    --tensor_parallel_size 1 \
    --top_p 1.0 \
    --temperature $INS_TEMP \
    --control_tasks math \
    --domain "$DOMAIN" \
    --max_tokens $MAX_TOKENS_INS

echo -e "${GREEN}✅ ステップ1完了: 問題生成が完了しました${NC}"
echo ""

# Step 2: Generate solutions with MAXIMUM REASONING DEPTH
log_progress "2" "4" "🧠 解答生成 (高度推論)" "Chain-of-Thought形式で詳細な解答を生成中 (最大4096トークン)..."
echo -e "${YELLOW}⏳ 推定時間: 10-20分 (問題の複雑さにより変動)${NC}"
python ../exp/gen_res.py \
    --model_path "$MODEL_PATH" \
    --ins_data_path "$OUTPUT_DIR/${DOMAIN}_ins.json" \
    --save_path "$OUTPUT_DIR/${DOMAIN}_ins_res.json" \
    --gpu_memory_utilization 0.95 \
    --tensor_parallel_size 1 \
    --top_p 1.0 \
    --temperature $RES_TEMP \
    --max_tokens $MAX_TOKENS_RES \
    --batch_size 4        # Reduced batch size for longer sequences

echo -e "${GREEN}✅ ステップ2完了: 解答生成が完了しました${NC}"
echo ""

# Step 3: Generate multiple responses with DEEP REASONING for alignment data
log_progress "3" "4" "🔄 多様な解答生成" "各問題に対し7種類の異なる解答を生成中 (学習用データ)..."
echo -e "${YELLOW}⏳ 推定時間: 15-30分 (特に時間がかかるステップ)${NC}"
python ../exp/gen_po_multi_res.py \
    --model_path "$MODEL_PATH" \
    --ins_data_path "$OUTPUT_DIR/${DOMAIN}_ins.json" \
    --save_path "$OUTPUT_DIR/${DOMAIN}_ins_7res.json" \
    --gpu_memory_utilization 0.95 \
    --tensor_parallel_size 1 \
    --temperature 0.8 \
    --top_p 0.95 \
    --max_tokens $MAX_TOKENS_RES \
    --num_responses 7 \
    --batch_size 2

echo -e "${GREEN}✅ ステップ3完了: 多様な解答生成が完了しました${NC}"
echo ""

# Step 4: Evaluate response quality
log_progress "4" "4" "⭐ 解答品質評価" "ArmoRM-Llama3-8Bモデルを使用して7つの解答候補を評価中..."
echo -e "${YELLOW}⏳ 推定時間: 5-10分 (評価処理)${NC}"
python ../exp/gen_po_rewards.py \
    --model_name_or_path "RLHFlow/ArmoRM-Llama3-8B-v0.1" \
    --ins_data_path "$OUTPUT_DIR/${DOMAIN}_ins_7res.json" \
    --save_path "$OUTPUT_DIR/${DOMAIN}_ins_7res_armorm.json" \
    --gpu_memory_utilization 0.9 \
    --batch_size 8        # Reduced batch size for longer sequences

echo -e "${GREEN}✅ ステップ4完了: 解答品質評価が完了しました${NC}"
echo ""

# Generate dataset summary
echo -e "${CYAN}📊 データセット情報を作成中...${NC}"
cat > "$OUTPUT_DIR/dataset_info.json" << EOF
{
  "dataset_name": "Magpie-${DOMAIN^}-HLE-${PROBLEM_COUNT}",
  "model": "$MODEL_PATH",
  "domain": "$DOMAIN",
  "problem_count": $PROBLEM_COUNT,
  "description": "$DESCRIPTION",
  "generation_date": "$(date -Iseconds)",
  "parameters": {
    "instruction_temperature": $INS_TEMP,
    "response_temperature": $RES_TEMP,
    "max_tokens_instruction": $MAX_TOKENS_INS,
    "max_tokens_response": $MAX_TOKENS_RES,
    "num_preference_responses": 7,
    "advanced_reasoning_mode": true
  },
  "files": {
    "instructions": "${DOMAIN}_ins.json",
    "sft_data": "${DOMAIN}_ins_res.json",
    "preference_data": "${DOMAIN}_ins_7res_armorm.json"
  }
}
EOF

echo ""
echo -e "${GREEN}🎉 データセット生成が完全に完了しました！${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════${NC}"
echo ""
echo -e "${BLUE}📋 生成結果サマリー:${NC}"
echo -e "${CYAN}  分野: ${DOMAIN^} (${DESCRIPTION})${NC}"
echo -e "${CYAN}  問題数: ${PROBLEM_COUNT}問${NC}"
echo -e "${CYAN}  使用モデル: $MODEL_PATH${NC}"
echo -e "${CYAN}  生成日時: $(date '+%Y年%m月%d日 %H:%M:%S')${NC}"
echo ""
echo -e "${BLUE}📁 生成されたファイル:${NC}"
echo -e "${YELLOW}  📝 問題データ (最大1024トークン):${NC}"
echo -e "      $OUTPUT_DIR/${DOMAIN}_ins.json"
echo -e "${YELLOW}  🎓 SFT学習データ (最大4096トークン):${NC}"
echo -e "      $OUTPUT_DIR/${DOMAIN}_ins_res.json"
echo -e "${YELLOW}  🎯 嗜好学習データ (7候補+評価スコア):${NC}"
echo -e "      $OUTPUT_DIR/${DOMAIN}_ins_7res_armorm.json"
echo -e "${YELLOW}  📊 データセット情報:${NC}"
echo -e "      $OUTPUT_DIR/dataset_info.json"
echo ""
echo -e "${GREEN}🚀 データセット名: Magpie-${DOMAIN^}-ADVANCED-HLE-${PROBLEM_COUNT}${NC}"
echo -e "${PURPLE}⚡ 高難度モード: 研究レベルの問題 (10-20ステップの推論チェーン)${NC}"
echo ""
echo -e "${BLUE}💡 次のステップ:${NC}"
echo -e "${GRAY}  • SFT学習: ${DOMAIN}_ins_res.json を使用${NC}"
echo -e "${GRAY}  • 嗜好学習: ${DOMAIN}_ins_7res_armorm.json を使用${NC}"
echo -e "${GRAY}  • データ確認: dataset_info.json で詳細確認${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════${NC}"