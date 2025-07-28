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

echo -e "${GREEN}Generating $DESCRIPTION${NC}"
echo ""

cd "$(dirname "$0")"

# Step 1: Generate domain-specific instructions
echo -e "${YELLOW}📝 Step 1: Generating ${DOMAIN} problems...${NC}"
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

# Step 2: Generate solutions with MAXIMUM REASONING DEPTH
echo -e "${YELLOW}🧠 Step 2: Generating Extended Chain-of-Thought solutions (4096 tokens)...${NC}"
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

# Step 3: Generate multiple responses with DEEP REASONING for alignment data
echo -e "${YELLOW}🔄 Step 3: Generating multiple deep reasoning responses for preference learning...${NC}"
python ../exp/gen_po_multi_res.py \
    --model_path "$MODEL_PATH" \
    --ins_data_path "$OUTPUT_DIR/${DOMAIN}_ins.json" \
    --save_path "$OUTPUT_DIR/${DOMAIN}_ins_7res.json" \
    --gpu_memory_utilization 0.95 \
    --tensor_parallel_size 1 \
    --temperature 0.8     # Slightly higher temp for response diversity
    --top_p 0.95         # Higher top_p for richer reasoning paths
    --max_tokens $MAX_TOKENS_RES \
    --num_responses 7     # More candidates for better preference learning
    --batch_size 2        # Smaller batch for longer sequences

# Step 4: Evaluate response quality
echo -e "${YELLOW}⭐ Step 4: Evaluating response quality (7 candidates)...${NC}"
python ../exp/gen_po_rewards.py \
    --model_name_or_path "RLHFlow/ArmoRM-Llama3-8B-v0.1" \
    --ins_data_path "$OUTPUT_DIR/${DOMAIN}_ins_7res.json" \
    --save_path "$OUTPUT_DIR/${DOMAIN}_ins_7res_armorm.json" \
    --gpu_memory_utilization 0.9 \
    --batch_size 8        # Reduced batch size for longer sequences

# Generate dataset summary
echo -e "${YELLOW}📊 Generating dataset summary...${NC}"
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

echo -e "\n${GREEN}✅ MAXIMUM DIFFICULTY Dataset generation complete!${NC}"
echo -e "${BLUE}Generated files with ADVANCED REASONING:${NC}"
echo "  📝 Instructions (1024 tokens): $OUTPUT_DIR/${DOMAIN}_ins.json"
echo "  🎓 SFT data (4096 tokens): $OUTPUT_DIR/${DOMAIN}_ins_res.json"
echo "  🎯 Preference data (7 responses): $OUTPUT_DIR/${DOMAIN}_ins_7res_armorm.json"
echo "  📊 Dataset info: $OUTPUT_DIR/dataset_info.json"
echo ""
echo -e "${GREEN}Dataset: Magpie-${DOMAIN^}-ADVANCED-HLE-${PROBLEM_COUNT}${NC}"
echo -e "${BLUE}Model: $MODEL_PATH${NC}"
echo -e "${PURPLE}⚡ MAXIMUM DIFFICULTY MODE: Research-level problems with 10-20 step reasoning chains${NC}"