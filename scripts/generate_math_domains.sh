#!/bin/bash

# Math Domain Dataset Generation Script
# Supports: DeepSeek R1 Distill models, Gemma 3, Qwen models

set -e

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}🧮 Math Domain Dataset Generator${NC}"
echo "================================="

# Default parameters
TOTAL_PROMPTS=1000
INS_TOPP=1.0
INS_TEMP=1.2
RES_TOPP=1.0
RES_TEMP=0.1

# Model selection
echo -e "\n${YELLOW}Select model:${NC}"
echo "1) DeepSeek-R1-Distill-Qwen-32B"
echo "2) DeepSeek-R1-Distill-Llama-70B"
echo "3) DeepSeek-R1-0528-FP4"
echo "4) Gemma-3-27B-it"
echo "5) Qwen2.5-Math-72B-Instruct"
echo "6) Qwen2.5-Coder-32B-Instruct"
read -p "Enter choice (1-6): " model_choice

case $model_choice in
    1) MODEL="deepseek-ai/DeepSeek-R1-Distill-Qwen-32B";;
    2) MODEL="deepseek-ai/DeepSeek-R1-Distill-Llama-70B";;
    3) MODEL="deepseek-ai/DeepSeek-R1-0528-FP4";;
    4) MODEL="google/gemma-3-27b-it";;
    5) MODEL="Qwen/Qwen2.5-Math-72B-Instruct";;
    6) MODEL="Qwen/Qwen2.5-Coder-32B-Instruct";;
    *) echo -e "${RED}Invalid choice${NC}"; exit 1;;
esac

# Domain selection
echo -e "\n${YELLOW}Select math domain:${NC}"
echo "1) Algebra - 代数学 (Equations, functions, polynomials)"
echo "2) Calculus - 微積分学 (Limits, derivatives, integrals)"
echo "3) Geometry - 幾何学 (Plane and solid geometry, trigonometry)"
echo "4) Statistics - 統計学 (Probability, statistical inference, data analysis)"
echo "5) Number Theory - 数論 (Integer theory, cryptography basics)"
echo "6) All domains (Generate all 5 domains)"
read -p "Enter choice (1-6): " domain_choice

case $domain_choice in
    1) DOMAINS=("algebra");;
    2) DOMAINS=("calculus");;
    3) DOMAINS=("geometry");;
    4) DOMAINS=("statistics");;
    5) DOMAINS=("number_theory");;
    6) DOMAINS=("algebra" "calculus" "geometry" "statistics" "number_theory");;
    *) echo -e "${RED}Invalid choice${NC}"; exit 1;;
esac

# Problem count per domain
if [ ${#DOMAINS[@]} -eq 1 ]; then
    read -p "Number of problems to generate (default: 1000): " custom_count
    TOTAL_PROMPTS=${custom_count:-1000}
else
    echo -e "\n${YELLOW}Problems per domain:${NC}"
    echo "Algebra: 10000"
    echo "Calculus: 10000"
    echo "Geometry: 6000"
    echo "Statistics: 6000"
    echo "Number Theory: 4000"
    read -p "Use recommended distribution? (y/n): " use_recommended
fi

# Generate timestamp
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Function to generate domain-specific data
generate_domain_data() {
    local domain=$1
    local count=$2
    local model_name=$(basename "$MODEL")
    
    echo -e "\n${GREEN}Generating $domain dataset with $model_name...${NC}"
    
    # Create output directory
    OUTPUT_DIR="../data/${model_name}_${domain}_${TIMESTAMP}"
    mkdir -p "$OUTPUT_DIR"
    
    # Domain-specific system prompts
    case $domain in
        "algebra")
            SYSTEM_PROMPT="You are an expert in algebra. Generate problems involving: linear and quadratic equations, systems of equations, inequalities, functions and their properties, sequences and series, exponential and logarithmic functions, matrix operations, and polynomial factorization. Problems should be suitable for high-level examinations."
            ;;
        "calculus")
            SYSTEM_PROMPT="You are an expert in calculus. Generate problems involving: limits and continuity, derivatives and applications, integration techniques, differential equations, Taylor series, multivariable calculus, optimization problems, and related rates. Problems should demonstrate deep understanding of calculus concepts."
            ;;
        "geometry")
            SYSTEM_PROMPT="You are an expert in geometry. Generate problems involving: Euclidean geometry, coordinate geometry, vectors, trigonometry, solid geometry, transformations, conic sections, and geometric proofs. Include both computational and proof-based problems."
            ;;
        "statistics")
            SYSTEM_PROMPT="You are an expert in statistics and probability. Generate problems involving: probability theory, random variables, distributions, hypothesis testing, confidence intervals, regression analysis, Bayesian inference, and statistical modeling. Include real-world applications."
            ;;
        "number_theory")
            SYSTEM_PROMPT="You are an expert in number theory. Generate problems involving: divisibility, prime numbers, modular arithmetic, Diophantine equations, number-theoretic functions, cryptographic applications, continued fractions, and algebraic number theory basics."
            ;;
    esac
    
    # Generate instructions
    echo "Generating $domain problems..."
    python ../exp/gen_ins.py \
        --model_path "$MODEL" \
        --model_name_or_path "$MODEL" \
        --save_path "$OUTPUT_DIR/${domain}_ins.json" \
        --gpu_memory_utilization 0.95 \
        --total_prompts $count \
        --tensor_parallel_size 1 \
        --top_p $INS_TOPP \
        --temperature $INS_TEMP \
        --control_tasks math \
        --domain "$domain" \
        --system_prompt "$SYSTEM_PROMPT"
    
    # Generate responses
    echo "Generating solutions with Chain-of-Thought reasoning..."
    python ../exp/gen_res.py \
        --model_path "$MODEL" \
        --model_name_or_path "$MODEL" \
        --ins_data_path "$OUTPUT_DIR/${domain}_ins.json" \
        --save_path "$OUTPUT_DIR/${domain}_ins_res.json" \
        --gpu_memory_utilization 0.95 \
        --tensor_parallel_size 1 \
        --top_p $RES_TOPP \
        --temperature $RES_TEMP \
        --batch_size 16
    
    echo -e "${GREEN}✓ Completed $domain dataset${NC}"
}

# Main execution
cd "$(dirname "$0")"

# Generate for each domain
if [ ${#DOMAINS[@]} -eq 1 ]; then
    generate_domain_data "${DOMAINS[0]}" $TOTAL_PROMPTS
else
    # Use recommended distribution
    declare -A domain_counts=(
        ["algebra"]=10000
        ["calculus"]=10000
        ["geometry"]=6000
        ["statistics"]=6000
        ["number_theory"]=4000
    )
    
    for domain in "${DOMAINS[@]}"; do
        generate_domain_data "$domain" "${domain_counts[$domain]}"
    done
    
    # Merge all domains
    echo -e "\n${YELLOW}Merging all domain datasets...${NC}"
    python merge_math_domains.py \
        --model "$MODEL" \
        --timestamp "$TIMESTAMP" \
        --output_dir "../data"
fi

echo -e "\n${GREEN}✅ Dataset generation complete!${NC}"
echo "Output location: data/${MODEL}_*_${TIMESTAMP}/"