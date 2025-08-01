#!/bin/bash

# Interactive Math Dataset Generation Menu
#
# This script provides an easy way to generate mathematical datasets using various
# language models. It supports both interactive and non-interactive modes.
#
# QUICK USAGE (数値で指定):
#   ./run_math_generation.sh 1 L 1      # DeepSeek-Qwen-32Bで全ドメイン標準サイズ(44K問題)
#   ./run_math_generation.sh 5 M 1      # Qwen-Math-72Bで全ドメイン中サイズ(22K問題)
#   ./run_math_generation.sh 2 M 2 2    # DeepSeek-Llama-70Bで微積分中サイズ(5K問題)
#
# USAGE:
#   ./run_math_generation.sh [OPTIONS] [model] [scale] [mode] [domain]
#
# OPTIONS:
#   -h, --help     Show this help message and exit
#
# ARGUMENTS:
#   model   Model selection (1-6,8)
#           1 = DeepSeek-R1-Distill-Qwen-32B (Recommended, balanced performance)
#           2 = DeepSeek-R1-Distill-Llama-70B (High performance, requires A100)
#           3 = DeepSeek-R1-0528-FP4 (Memory efficient with FP4 quantization)
#           4 = Gemma-3-27B-it (Google's latest model)
#           5 = Qwen2.5-Math-72B-Instruct (Mathematics specialist)
#           6 = Qwen2.5-Coder-32B-Instruct (Computational mathematics focus)
#           8 = Qwen2.5-3B-Instruct (Test model, lightweight)
#
#   scale   Generation scale (S/M/L/XL)
#           S  = Small (10% - テスト用)
#           M  = Medium (50% - 開発用)
#           L  = Large (100% - 標準)
#           XL = Extra Large (200% - 大規模)
#
#   mode    Generation mode (1-3)
#           1 = All Domains - Generate complete dataset with ratio applied
#           2 = Single Domain - Generate problems for one specific math domain
#           3 = Custom Selection - Choose multiple domains interactively
#
#   domain  Domain selection for mode 2 (1-6)
#           1 = Algebra (default: 10K)
#           2 = Calculus (default: 10K)
#           3 = Geometry (default: 6K)
#           4 = Statistics (default: 6K)
#           5 = Number Theory (default: 4K)
#           6 = Discrete Mathematics (default: 8K)
#
# EXAMPLES:
#   # Interactive mode (asks all questions)
#   ./run_math_generation.sh
#
#   # Generate all domains with DeepSeek-R1-Distill-Qwen-32B at Large scale (44K)
#   ./run_math_generation.sh 1 L 1
#
#   # Generate all domains with Qwen2.5-Math-72B at Medium scale
#   ./run_math_generation.sh 5 M 1
#
#   # Generate calculus problems with DeepSeek-R1-Distill-Llama-70B at Medium scale (5K)
#   ./run_math_generation.sh 2 M 2 2
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

# Function to round to nearest 10
round_to_10() {
    local num=$1
    if [ "$num" -le 0 ]; then
        echo 10  # 最小値を10に設定
    else
        local rounded=$(( (num + 5) / 10 * 10 ))
        if [ "$rounded" -le 0 ]; then
            echo 10  # 0以下の場合は10に設定
        else
            echo $rounded
        fi
    fi
}

# Function to convert scale to ratio
scale_to_ratio() {
    local scale=$1
    case $scale in
        S|s) echo "0.1";;
        M|m) echo "0.5";;
        L|l) echo "1.0";;
        XL|xl|X|x) echo "2.0";;
        *) echo "$scale";;  # fallback to numeric input
    esac
}

# Function to calculate problem count with scale
calculate_count() {
    local base_count=$1
    local scale=$2
    local ratio=$(scale_to_ratio $scale)
    local result=$(echo "$base_count * $ratio" | bc | cut -d. -f1)
    round_to_10 $result
}

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
    echo "  ./run_math_generation.sh [モデル番号] [生成倍率] [モード番号] [ドメイン番号]"
    echo ""
    echo "モデル番号:"
    echo "  1 = DeepSeek-R1-Distill-Qwen-32B（推奨・バランス型）"
    echo "  2 = DeepSeek-R1-Distill-Llama-70B（高性能・A100必須）"
    echo "  3 = DeepSeek-R1-0528-FP4（メモリ効率型）"
    echo "  4 = Gemma-3-27B-it（Google製）"
    echo "  5 = Qwen2.5-Math-72B-Instruct（数学特化）"
    echo "  6 = Qwen2.5-Coder-32B-Instruct（計算数学特化）"
    echo "  8 = Qwen2.5-3B-Instruct（テスト用・軽量）"
    echo ""
    echo "生成倍率:"
    echo "  0.1 = デフォルトの10%（例：全ドメイン4.4K問題）"
    echo "  0.5 = デフォルトの50%（例：全ドメイン22K問題）"
    echo "  1.0 = デフォルトの100%（例：全ドメイン44K問題）"
    echo "  2.0 = デフォルトの200%（例：全ドメイン88K問題）"
    echo "  ※10の位で四捨五入されます"
    echo ""
    echo "モード番号:"
    echo "  1 = 全ドメイン生成（44K問題）"
    echo "  2 = 単一ドメイン生成"
    echo "  3 = カスタム選択（対話モードのみ）"
    echo ""
    echo "ドメイン番号（モード2の場合）:"
    echo "  1 = 代数（10K問題推奨）"
    echo "  2 = 微積分（10K問題推奨）"
    echo "  3 = 幾何（6K問題推奨）"
    echo "  4 = 統計（6K問題推奨）"
    echo "  5 = 数論（4K問題推奨）"
    echo "  6 = 離散数学（8K問題推奨）"
    echo ""
    echo "例:"
    echo "  ./run_math_generation.sh              # 対話モード"
    echo "  ./run_math_generation.sh 1 1.0 1      # DeepSeek-Qwen-32Bで全ドメイン100%生成"
    echo "  ./run_math_generation.sh 5 0.5 1      # Qwen-Math-72Bで全ドメイン50%生成"
    echo "  ./run_math_generation.sh 2 0.5 2 2    # DeepSeek-Llama-70Bで微積分50%生成"
    exit 0
fi

# Parse command line arguments
model_choice=$1
model_scale=$2
mode_choice=$3
domain_choice=$4

# Check if running in non-interactive mode
if [ -n "$model_choice" ] && [ -n "$model_scale" ] && [ -n "$mode_choice" ]; then
    echo -e "${GREEN}Running in non-interactive mode${NC}"
    echo -e "${BLUE}Model: $model_choice, Scale: $model_scale, Mode: $mode_choice${NC}"
    [ -n "$domain_choice" ] && echo -e "${BLUE}Domain: $domain_choice${NC}"
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
    echo -e "${BLUE}   ./run_math_generation.sh 1 1.0 1      # DeepSeek-Qwen-32Bで全ドメイン標準倍率生成${NC}"
    echo -e "${BLUE}   ./run_math_generation.sh 5 0.5 1      # Qwen-Math-72Bで全ドメイン0.5倍生成${NC}"
    echo -e "${BLUE}   ./run_math_generation.sh 2 0.5 2 2    # DeepSeek-Llama-70Bで微積分0.5倍生成${NC}"
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
    echo "8) Qwen2.5-3B-Instruct (Test model - Lightweight)"
    echo ""
    read -p "Enter choice (1-6,8): " model_choice
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
    8) MODEL="Qwen/Qwen2.5-3B-Instruct"
       MODEL_DESC="Qwen2.5 3B (Test)";;
    *) echo -e "${RED}Invalid choice${NC}"; exit 1;;
esac

echo ""
echo -e "${BLUE}Selected: $MODEL_DESC${NC}"
echo ""

# Scale selection
if [ -z "$model_scale" ]; then
    echo -e "${YELLOW}📊 生成倍率を選択（デフォルト数に対する倍率）:${NC}"
    echo "0.1 = 10%   (例: 全ドメイン 4,400問)"
    echo "0.5 = 50%   (例: 全ドメイン 22,000問)"
    echo "1.0 = 100%  (例: 全ドメイン 44,000問) [推奨]"
    echo "2.0 = 200%  (例: 全ドメイン 88,000問)"
    echo ""
    read -p "生成倍率を入力 (default: 1.0): " model_scale
    model_scale=${model_scale:-1.0}
fi

echo -e "${BLUE}生成倍率: ${model_scale}x${NC}"
echo ""

# Generation mode selection
if [ -z "$mode_choice" ]; then
    echo -e "${YELLOW}🎯 Select Generation Mode:${NC}"
    echo "1) All Domains - Generate complete HLE math dataset (44K problems)"
    echo "2) Single Domain - Generate one specific math domain"
    echo "3) Custom Selection - Choose specific domains"
    echo ""
    read -p "Enter choice (1-3): " mode_choice
fi

case $mode_choice in
    1) # All domains
        echo ""
        echo -e "${PURPLE}🚀 Starting complete dataset generation...${NC}"
        echo -e "${BLUE}Model: $MODEL_DESC${NC}"
        echo -e "${BLUE}生成倍率: ${model_scale}x${NC}"
        
        # Calculate totals with scale
        ALGEBRA_COUNT=$(calculate_count 10000 $model_scale)
        CALCULUS_COUNT=$(calculate_count 10000 $model_scale)
        GEOMETRY_COUNT=$(calculate_count 6000 $model_scale)
        STATISTICS_COUNT=$(calculate_count 6000 $model_scale)
        NUMBER_THEORY_COUNT=$(calculate_count 4000 $model_scale)
        DISCRETE_COUNT=$(calculate_count 8000 $model_scale)
        TOTAL_COUNT=$((ALGEBRA_COUNT + CALCULUS_COUNT + GEOMETRY_COUNT + STATISTICS_COUNT + NUMBER_THEORY_COUNT + DISCRETE_COUNT))
        
        echo -e "${BLUE}Total problems: $TOTAL_COUNT${NC}"
        echo -e "${BLUE}Domains: Algebra ($ALGEBRA_COUNT), Calculus ($CALCULUS_COUNT), Geometry ($GEOMETRY_COUNT), Statistics ($STATISTICS_COUNT), Number Theory ($NUMBER_THEORY_COUNT), Discrete ($DISCRETE_COUNT)${NC}"
        echo ""
        
        # Pass counts as environment variables instead of creating temp file
        export MAGPIE_ALGEBRA_COUNT="$ALGEBRA_COUNT"
        export MAGPIE_CALCULUS_COUNT="$CALCULUS_COUNT"
        export MAGPIE_GEOMETRY_COUNT="$GEOMETRY_COUNT"
        export MAGPIE_STATISTICS_COUNT="$STATISTICS_COUNT"
        export MAGPIE_NUMBER_THEORY_COUNT="$NUMBER_THEORY_COUNT"
        export MAGPIE_DISCRETE_COUNT="$DISCRETE_COUNT"
        
        # Call the original script directly
        "$(dirname "$0")/generate_all_math_domains.sh" "$MODEL"
        
        # Clean up environment variables
        unset MAGPIE_ALGEBRA_COUNT MAGPIE_CALCULUS_COUNT MAGPIE_GEOMETRY_COUNT
        unset MAGPIE_STATISTICS_COUNT MAGPIE_NUMBER_THEORY_COUNT MAGPIE_DISCRETE_COUNT
        ;;
        
    2) # Single domain
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
        
        # Calculate problem count with scale
        PROBLEM_COUNT=$(calculate_count $RECOMMENDED_COUNT $model_scale)
        
        echo ""
        echo -e "${PURPLE}🚀 Starting generation...${NC}"
        echo -e "${BLUE}Model: $MODEL_DESC${NC}"
        echo -e "${BLUE}Domain: $DOMAIN${NC}"
        echo -e "${BLUE}Base count: $RECOMMENDED_COUNT × ${model_scale} = $PROBLEM_COUNT problems${NC}"
        echo ""
        
        "$(dirname "$0")/generate_domain_dataset.sh" "$MODEL" "$DOMAIN" "$PROBLEM_COUNT"
        ;;
        
    3) # Custom selection
        if [ -n "$domain_choice" ]; then
            echo -e "${RED}Custom selection mode (3) cannot be used with command line arguments${NC}"
            echo -e "${RED}Please use mode 1 for all domains or mode 2 for single domain${NC}"
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
        echo -e "${BLUE}生成倍率: ${model_scale}x${NC}"
        echo -e "${BLUE}Selected domains: ${SELECTED_DOMAINS[*]}${NC}"
        echo ""
        
        # Generate each selected domain with recommended counts
        for domain in "${SELECTED_DOMAINS[@]}"; do
            case $domain in
                "algebra") base_count=10000;;
                "calculus") base_count=10000;;
                "geometry") base_count=6000;;
                "statistics") base_count=6000;;
                "number_theory") base_count=4000;;
                "discrete") base_count=8000;;
            esac
            
            count=$(calculate_count $base_count $model_scale)
            echo -e "${YELLOW}Generating $domain ($base_count × ${model_scale} = $count problems)...${NC}"
            "$(dirname "$0")/generate_domain_dataset.sh" "$MODEL" "$domain" "$count"
        done
        ;;
        
    *) echo -e "${RED}Invalid choice${NC}"; exit 1;;
esac

echo ""
echo -e "${GREEN}🎉 Generation complete!${NC}"
echo -e "${BLUE}Check the data/ directory for generated datasets.${NC}"