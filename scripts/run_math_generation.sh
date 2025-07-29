#!/bin/bash

# Interactive Math Dataset Generation Menu
#
# This script provides an easy way to generate mathematical datasets using various
# language models. It supports both interactive and non-interactive modes.
#
# QUICK USAGE (数値で指定):
#   ./run_math_generation.sh 1 1 1        # DeepSeek-Qwen-32Bで代数10K問題
#   ./run_math_generation.sh 5 2          # Qwen-Math-72Bで全ドメイン44K問題
#   ./run_math_generation.sh 2 1 2 5000   # DeepSeek-Llama-70Bで微積分5000問題
#
# USAGE:
#   ./run_math_generation.sh [OPTIONS] [model] [mode] [domain] [count]
#
# OPTIONS:
#   -h, --help     Show this help message and exit
#
# ARGUMENTS:
#   model   Model selection (1-6)
#           1 = DeepSeek-R1-Distill-Qwen-32B (Recommended, balanced performance)
#           2 = DeepSeek-R1-Distill-Llama-70B (High performance, requires A100)
#           3 = DeepSeek-R1-0528-FP4 (Memory efficient with FP4 quantization)
#           4 = Gemma-3-27B-it (Google's latest model)
#           5 = Qwen2.5-Math-72B-Instruct (Mathematics specialist)
#           6 = Qwen2.5-Coder-32B-Instruct (Computational mathematics focus)
#
#   mode    Generation mode (1-3)
#           1 = Single Domain - Generate problems for one specific math domain
#           2 = All Domains - Generate complete dataset (44K problems total)
#           3 = Custom Selection - Choose multiple domains interactively
#
#   domain  Domain selection for mode 1 (1-6)
#           1 = Algebra (10K problems recommended)
#           2 = Calculus (10K problems recommended)
#           3 = Geometry (6K problems recommended)
#           4 = Statistics (6K problems recommended)
#           5 = Number Theory (4K problems recommended)
#           6 = Discrete Mathematics (8K problems recommended)
#
#   count   Number of problems to generate (optional)
#           If not specified, uses recommended count for the domain
#
# EXAMPLES:
#   # Interactive mode (asks all questions)
#   ./run_math_generation.sh
#
#   # Generate algebra problems with DeepSeek-R1-Distill-Qwen-32B
#   ./run_math_generation.sh 1 1 1
#
#   # Generate all domains with Qwen2.5-Math-72B
#   ./run_math_generation.sh 5 2
#
#   # Generate 5000 calculus problems with DeepSeek-R1-Distill-Llama-70B
#   ./run_math_generation.sh 2 1 2 5000
#
#   # Show help
#   ./run_math_generation.sh -h
#
# NOTES:
#   - Models 2 and 5 require high-memory GPUs (A100 80GB recommended)
#   - DeepSeek models require Hugging Face authentication
#   - Generated datasets are saved in the data/ directory
#   - Each run creates timestamped output files

set -e

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Show help if requested
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    # Japanese help
    echo "Magpie Math Dataset Generator - 使い方ガイド"
    echo ""
    echo "使い方:"
    echo "  ./run_math_generation.sh [モデル番号] [モード番号] [ドメイン番号] [問題数]"
    echo ""
    echo "モデル番号:"
    echo "  1 = DeepSeek-R1-Distill-Qwen-32B（推奨・バランス型）"
    echo "  2 = DeepSeek-R1-Distill-Llama-70B（高性能・A100必須）"
    echo "  3 = DeepSeek-R1-0528-FP4（メモリ効率型）"
    echo "  4 = Gemma-3-27B-it（Google製）"
    echo "  5 = Qwen2.5-Math-72B-Instruct（数学特化）"
    echo "  6 = Qwen2.5-Coder-32B-Instruct（計算数学特化）"
    echo ""
    echo "モード番号:"
    echo "  1 = 単一ドメイン生成"
    echo "  2 = 全ドメイン生成（44K問題）"
    echo "  3 = カスタム選択（対話モードのみ）"
    echo ""
    echo "ドメイン番号（モード1の場合）:"
    echo "  1 = 代数（10K問題推奨）"
    echo "  2 = 微積分（10K問題推奨）"
    echo "  3 = 幾何（6K問題推奨）"
    echo "  4 = 統計（6K問題推奨）"
    echo "  5 = 数論（4K問題推奨）"
    echo "  6 = 離散数学（8K問題推奨）"
    echo ""
    echo "例:"
    echo "  ./run_math_generation.sh              # 対話モード"
    echo "  ./run_math_generation.sh 1 1 1        # DeepSeek-Qwen-32Bで代数生成"
    echo "  ./run_math_generation.sh 5 2          # Qwen-Math-72Bで全ドメイン生成"
    echo "  ./run_math_generation.sh 2 1 2 5000   # DeepSeek-Llama-70Bで微積分5000問題"
    exit 0
fi

# Parse command line arguments
model_choice=$1
mode_choice=$2
domain_choice=$3
custom_count=$4

# Check if running in non-interactive mode
if [ -n "$model_choice" ] && [ -n "$mode_choice" ]; then
    echo -e "${GREEN}Running in non-interactive mode${NC}"
    echo -e "${BLUE}Model: $model_choice, Mode: $mode_choice${NC}"
    [ -n "$domain_choice" ] && echo -e "${BLUE}Domain: $domain_choice${NC}"
    [ -n "$custom_count" ] && echo -e "${BLUE}Count: $custom_count${NC}"
    echo ""
else
    # Interactive mode
    clear
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║              🧮 Magpie Math Dataset Generator              ║${NC}"
    echo -e "${GREEN}║                   HLE Mathematics Edition                 ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}💡 ヒント: 引数を使って直接実行もできます:${NC}"
    echo -e "${BLUE}   ./run_math_generation.sh 1 1 1        # DeepSeek-Qwen-32Bで代数生成${NC}"
    echo -e "${BLUE}   ./run_math_generation.sh 5 2          # Qwen-Math-72Bで全ドメイン生成${NC}"
    echo -e "${BLUE}   ./run_math_generation.sh 2 1 2 5000   # DeepSeek-Llama-70Bで微積分5000問題${NC}"
    echo -e "${BLUE}   ./run_math_generation.sh -h           # 日本語ヘルプを表示${NC}"
    echo ""
fi

# Model selection
if [ -z "$model_choice" ]; then
    echo -e "${YELLOW}📝 Select Model:${NC}"
    echo "1) DeepSeek-R1-Distill-Qwen-32B (Recommended - Balanced performance)"
    echo "2) DeepSeek-R1-Distill-Llama-70B (High performance - Requires A100)"
    echo "3) DeepSeek-R1-0528-FP4 (Memory efficient - FP4 quantized)"
    echo "4) Gemma-3-27B-it (Google model)"
    echo "5) Qwen2.5-Math-72B-Instruct (Math specialist)"
    echo "6) Qwen2.5-Coder-32B-Instruct (Computational math focus)"
    echo ""
    read -p "Enter choice (1-6): " model_choice
fi

case $model_choice in
    1) MODEL="deepseek-ai/DeepSeek-R1-Distill-Qwen-32B"
       MODEL_DESC="DeepSeek R1 Distill Qwen 32B";;
    2) MODEL="deepseek-ai/DeepSeek-R1-Distill-Llama-70B"
       MODEL_DESC="DeepSeek R1 Distill Llama 70B";;
    3) MODEL="deepseek-ai/DeepSeek-R1-0528-FP4"
       MODEL_DESC="DeepSeek R1 FP4";;
    4) MODEL="google/gemma-3-27b-it"
       MODEL_DESC="Gemma 3 27B";;
    5) MODEL="Qwen/Qwen2.5-Math-72B-Instruct"
       MODEL_DESC="Qwen2.5 Math 72B";;
    6) MODEL="Qwen/Qwen2.5-Coder-32B-Instruct"
       MODEL_DESC="Qwen2.5 Coder 32B";;
    *) echo -e "${RED}Invalid choice${NC}"; exit 1;;
esac

echo ""
echo -e "${BLUE}Selected: $MODEL_DESC${NC}"
echo ""

# Generation mode selection
if [ -z "$mode_choice" ]; then
    echo -e "${YELLOW}🎯 Select Generation Mode:${NC}"
    echo "1) Single Domain - Generate one specific math domain"
    echo "2) All Domains - Generate complete HLE math dataset (44K problems)"
    echo "3) Custom Selection - Choose specific domains"
    echo ""
    read -p "Enter choice (1-3): " mode_choice
fi

case $mode_choice in
    1) # Single domain
        if [ -z "$domain_choice" ]; then
            echo ""
            echo -e "${YELLOW}📚 Select Math Domain:${NC}"
            echo "1) Algebra (10K problems recommended)"
            echo "2) Calculus (10K problems recommended)"
            echo "3) Geometry (6K problems recommended)"
            echo "4) Statistics (6K problems recommended)"
            echo "5) Number Theory (4K problems recommended)"
            echo "6) Discrete Mathematics (8K problems recommended)"
            echo ""
            read -p "Enter choice (1-6): " domain_choice
        fi
        
        case $domain_choice in
            1) DOMAIN="algebra"; RECOMMENDED_COUNT=10000;;
            2) DOMAIN="calculus"; RECOMMENDED_COUNT=10000;;
            3) DOMAIN="geometry"; RECOMMENDED_COUNT=6000;;
            4) DOMAIN="statistics"; RECOMMENDED_COUNT=6000;;
            5) DOMAIN="number_theory"; RECOMMENDED_COUNT=4000;;
            6) DOMAIN="discrete"; RECOMMENDED_COUNT=8000;;
            *) echo -e "${RED}Invalid choice${NC}"; exit 1;;
        esac
        
        if [ -z "$custom_count" ]; then
            echo ""
            read -p "Number of problems (default: $RECOMMENDED_COUNT): " custom_count
        fi
        PROBLEM_COUNT=${custom_count:-$RECOMMENDED_COUNT}
        
        echo ""
        echo -e "${PURPLE}🚀 Starting generation...${NC}"
        echo -e "${BLUE}Model: $MODEL_DESC${NC}"
        echo -e "${BLUE}Domain: $DOMAIN${NC}"
        echo -e "${BLUE}Problems: $PROBLEM_COUNT${NC}"
        echo ""
        
        ./generate_domain_dataset.sh "$MODEL" "$DOMAIN" "$PROBLEM_COUNT"
        ;;
        
    2) # All domains
        echo ""
        echo -e "${PURPLE}🚀 Starting complete dataset generation...${NC}"
        echo -e "${BLUE}Model: $MODEL_DESC${NC}"
        echo -e "${BLUE}Total problems: 44,000${NC}"
        echo -e "${BLUE}Domains: Algebra (10K), Calculus (10K), Geometry (6K), Statistics (6K), Number Theory (4K), Discrete (8K)${NC}"
        echo ""
        
        ./generate_all_math_domains.sh "$MODEL"
        ;;
        
    3) # Custom selection
        if [ -n "$domain_choice" ]; then
            echo -e "${RED}Custom selection mode (3) cannot be used with command line arguments${NC}"
            echo -e "${RED}Please use mode 1 for single domain or mode 2 for all domains${NC}"
            exit 1
        fi
        echo ""
        echo -e "${YELLOW}📚 Select Domains (multiple choice, space-separated):${NC}"
        echo "1) Algebra"
        echo "2) Calculus"
        echo "3) Geometry"
        echo "4) Statistics"
        echo "5) Number Theory"
        echo "6) Discrete Mathematics"
        echo ""
        read -p "Enter choices (e.g., '1 3 5'): " domain_choices
        
        SELECTED_DOMAINS=()
        for choice in $domain_choices; do
            case $choice in
                1) SELECTED_DOMAINS+=("algebra");;
                2) SELECTED_DOMAINS+=("calculus");;
                3) SELECTED_DOMAINS+=("geometry");;
                4) SELECTED_DOMAINS+=("statistics");;
                5) SELECTED_DOMAINS+=("number_theory");;
                6) SELECTED_DOMAINS+=("discrete");;
                *) echo -e "${RED}Invalid choice: $choice${NC}"; exit 1;;
            esac
        done
        
        echo ""
        echo -e "${PURPLE}🚀 Starting custom generation...${NC}"
        echo -e "${BLUE}Model: $MODEL_DESC${NC}"
        echo -e "${BLUE}Selected domains: ${SELECTED_DOMAINS[*]}${NC}"
        echo ""
        
        # Generate each selected domain with recommended counts
        for domain in "${SELECTED_DOMAINS[@]}"; do
            case $domain in
                "algebra") count=10000;;
                "calculus") count=10000;;
                "geometry") count=6000;;
                "statistics") count=6000;;
                "number_theory") count=4000;;
                "discrete") count=8000;;
            esac
            
            echo -e "${YELLOW}Generating $domain ($count problems)...${NC}"
            ./generate_domain_dataset.sh "$MODEL" "$domain" "$count"
        done
        ;;
        
    *) echo -e "${RED}Invalid choice${NC}"; exit 1;;
esac

echo ""
echo -e "${GREEN}🎉 Generation complete!${NC}"
echo -e "${BLUE}Check the data/ directory for generated datasets.${NC}"