#!/bin/bash

# Interactive Math Dataset Generation Menu

set -e

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

clear
echo -e "${GREEN}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║              🧮 Magpie Math Dataset Generator              ║${NC}"
echo -e "${GREEN}║                   HLE Mathematics Edition                 ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

# Model selection
echo -e "${YELLOW}📝 Select Model:${NC}"
echo "1) DeepSeek-R1-Distill-Qwen-32B (Recommended - Balanced performance)"
echo "2) DeepSeek-R1-Distill-Llama-70B (High performance - Requires A100)"
echo "3) DeepSeek-R1-0528-FP4 (Memory efficient - FP4 quantized)"
echo "4) Gemma-3-27B-it (Google model)"
echo "5) Qwen2.5-Math-72B-Instruct (Math specialist)"
echo "6) Qwen2.5-Coder-32B-Instruct (Computational math focus)"
echo ""
read -p "Enter choice (1-6): " model_choice

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
echo -e "${YELLOW}🎯 Select Generation Mode:${NC}"
echo "1) Single Domain - Generate one specific math domain"
echo "2) All Domains - Generate complete HLE math dataset (44K problems)"
echo "3) Custom Selection - Choose specific domains"
echo ""
read -p "Enter choice (1-3): " mode_choice

case $mode_choice in
    1) # Single domain
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
        
        case $domain_choice in
            1) DOMAIN="algebra"; RECOMMENDED_COUNT=10000;;
            2) DOMAIN="calculus"; RECOMMENDED_COUNT=10000;;
            3) DOMAIN="geometry"; RECOMMENDED_COUNT=6000;;
            4) DOMAIN="statistics"; RECOMMENDED_COUNT=6000;;
            5) DOMAIN="number_theory"; RECOMMENDED_COUNT=4000;;
            6) DOMAIN="discrete"; RECOMMENDED_COUNT=8000;;
            *) echo -e "${RED}Invalid choice${NC}"; exit 1;;
        esac
        
        echo ""
        read -p "Number of problems (default: $RECOMMENDED_COUNT): " custom_count
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