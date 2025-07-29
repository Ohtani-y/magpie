#!/bin/bash

# Complete Math Domain Dataset Generation Script
# Generates all 6 math domains with recommended problem distributions

set -e

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

echo -e "${GREEN}🧮 Complete Math Domain Dataset Generator${NC}"
echo "=============================================="

MODEL_PATH="${1}"

if [ -z "$MODEL_PATH" ]; then
    echo -e "${RED}Usage: $0 <model_path>${NC}"
    echo ""
    echo "Supported models:"
    echo "  - deepseek-ai/DeepSeek-R1-Distill-Qwen-32B"
    echo "  - deepseek-ai/DeepSeek-R1-Distill-Llama-70B"
    echo "  - deepseek-ai/DeepSeek-R1-0528-FP4"
    echo "  - google/gemma-3-27b-it"
    echo "  - Qwen/Qwen2.5-Math-72B-Instruct"
    echo "  - Qwen/Qwen2.5-Coder-32B-Instruct"
    echo ""
    echo "Example: $0 deepseek-ai/DeepSeek-R1-Distill-Qwen-32B"
    exit 1
fi

# Domain configuration with recommended problem counts
declare -A DOMAINS=(
    ["algebra"]="10000"
    ["calculus"]="10000"
    ["geometry"]="6000"
    ["statistics"]="6000"
    ["number_theory"]="4000"
    ["discrete"]="8000"
)

# Domain descriptions
declare -A DESCRIPTIONS=(
    ["algebra"]="Linear/quadratic equations, systems, functions, sequences, matrices"
    ["calculus"]="Limits, derivatives, integrals, differential equations, applications"
    ["geometry"]="Euclidean/coordinate geometry, trigonometry, proofs, constructions"
    ["statistics"]="Probability theory, statistical inference, regression, data analysis"
    ["number_theory"]="Prime numbers, modular arithmetic, Diophantine equations, cryptography"
    ["discrete"]="Graph theory, combinatorics, logic, algorithms, discrete probability"
)

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
MODEL_NAME=$(basename "$MODEL_PATH")
BASE_OUTPUT_DIR="../data/${MODEL_NAME}_AllDomains_${TIMESTAMP}"

echo -e "${BLUE}Configuration:${NC}"
echo "  Model: $MODEL_PATH"
echo "  Total problems: 44,000"
echo "  Domains: ${!DOMAINS[@]}"
echo "  Base output directory: $BASE_OUTPUT_DIR"
echo ""

# Create base output directory
mkdir -p "$BASE_OUTPUT_DIR"

cd "$(dirname "$0")"

# Generate each domain
for domain in "${!DOMAINS[@]}"; do
    count=${DOMAINS[$domain]}
    description=${DESCRIPTIONS[$domain]}
    
    echo -e "\n${PURPLE}🎯 Generating $domain dataset (${count} problems)${NC}"
    echo -e "${BLUE}Description: $description${NC}"
    echo -e "${YELLOW}📝 Expected model: $MODEL_PATH${NC}"
    echo -e "${YELLOW}📁 Expected folder pattern: ${MODEL_NAME}_${domain}_*${NC}"
    
    # Record start time for this domain generation
    DOMAIN_START_TIME=$(date +%s)
    
    # Call the domain-specific generation script
    echo -e "${BLUE}🚀 Starting generation for $domain...${NC}"
    if ! ./generate_domain_dataset.sh "$MODEL_PATH" "$domain" "$count"; then
        echo -e "${RED}❌ Error: Failed to generate $domain dataset${NC}"
        echo -e "${RED}🚫 Stopping execution to prevent incorrect folder processing${NC}"
        exit 1
    fi
    
    # Find the generated directory with strict validation
    echo -e "${YELLOW}🔍 Searching for generated folder...${NC}"
    
    # More precise search: exact model name + domain + timestamp pattern
    # Only look for directories created after we started this domain generation
    DOMAIN_OUTPUT=$(find ../data -name "${MODEL_NAME}_${domain}_[0-9]*" -type d -newermt "@$DOMAIN_START_TIME" 2>/dev/null | head -1)
    
    if [ -n "$DOMAIN_OUTPUT" ]; then
        # Validate that this is actually the correct folder
        FOLDER_BASENAME=$(basename "$DOMAIN_OUTPUT")
        if [[ "$FOLDER_BASENAME" =~ ^${MODEL_NAME}_${domain}_[0-9]{8}_[0-9]{6}$ ]]; then
            echo -e "${GREEN}✅ Found valid folder: $FOLDER_BASENAME${NC}"
            mv "$DOMAIN_OUTPUT" "$BASE_OUTPUT_DIR/${domain}"
            echo -e "${GREEN}✓ Moved to $BASE_OUTPUT_DIR/${domain}${NC}"
        else
            echo -e "${RED}❌ Warning: Found folder but pattern doesn't match expected format${NC}"
            echo -e "${RED}   Found: $FOLDER_BASENAME${NC}"
            echo -e "${RED}   Expected pattern: ${MODEL_NAME}_${domain}_YYYYMMDD_HHMMSS${NC}"
            echo -e "${RED}🚫 Skipping to prevent incorrect processing${NC}"
        fi
    else
        echo -e "${RED}❌ Error: No output folder found for $domain${NC}"
        echo -e "${RED}   Expected pattern: ${MODEL_NAME}_${domain}_*${NC}"
        echo -e "${RED}   Search path: ../data${NC}"
        echo -e "${RED}🚫 Stopping execution${NC}"
        exit 1
    fi
done

# Create combined dataset summary
echo -e "\n${YELLOW}📊 Creating combined dataset summary...${NC}"

cat > "$BASE_OUTPUT_DIR/combined_dataset_info.json" << EOF
{
  "dataset_name": "Magpie-Math-Complete-HLE-44K",
  "model": "$MODEL_PATH",
  "total_problems": 44000,
  "generation_date": "$(date -Iseconds)",
  "domains": {
    "algebra": {
      "problems": 10000,
      "description": "${DESCRIPTIONS[algebra]}",
      "directory": "algebra"
    },
    "calculus": {
      "problems": 10000,
      "description": "${DESCRIPTIONS[calculus]}",
      "directory": "calculus"
    },
    "geometry": {
      "problems": 6000,
      "description": "${DESCRIPTIONS[geometry]}",
      "directory": "geometry"
    },
    "statistics": {
      "problems": 6000,
      "description": "${DESCRIPTIONS[statistics]}",
      "directory": "statistics"
    },
    "number_theory": {
      "problems": 4000,
      "description": "${DESCRIPTIONS[number_theory]}",
      "directory": "number_theory"
    },
    "discrete": {
      "problems": 8000,
      "description": "${DESCRIPTIONS[discrete]}",
      "directory": "discrete"
    }
  },
  "files_per_domain": {
    "instructions": "<domain>_ins.json",
    "sft_data": "<domain>_ins_res.json",
    "preference_data": "<domain>_ins_5res_armorm.json",
    "info": "dataset_info.json"
  }
}
EOF

# Create a usage guide
cat > "$BASE_OUTPUT_DIR/README.md" << EOF
# Magpie Math Complete HLE Dataset

Generated with model: \`$MODEL_PATH\`
Generation date: $(date)

## Overview

This dataset contains 44,000 high-level examination (HLE) math problems across 6 domains:

| Domain | Problems | Description |
|--------|----------|-------------|
| Algebra | 10,000 | ${DESCRIPTIONS[algebra]} |
| Calculus | 10,000 | ${DESCRIPTIONS[calculus]} |
| Geometry | 6,000 | ${DESCRIPTIONS[geometry]} |
| Statistics | 6,000 | ${DESCRIPTIONS[statistics]} |
| Number Theory | 4,000 | ${DESCRIPTIONS[number_theory]} |
| Discrete Math | 8,000 | ${DESCRIPTIONS[discrete]} |

## Directory Structure

\`\`\`
$BASE_OUTPUT_DIR/
├── algebra/
│   ├── algebra_ins.json              # Problems only
│   ├── algebra_ins_res.json          # SFT: Problems + Solutions
│   ├── algebra_ins_5res_armorm.json  # Preference: Ranked multiple responses
│   └── dataset_info.json             # Domain-specific metadata
├── calculus/
│   └── ...
├── geometry/
│   └── ...
├── statistics/
│   └── ...
├── number_theory/
│   └── ...
├── discrete/
│   └── ...
├── combined_dataset_info.json        # Complete dataset metadata
└── README.md                         # This file
\`\`\`

## Data Formats

### SFT Data (Training)
Use \`<domain>_ins_res.json\` files for supervised fine-tuning.

### Preference Data (Alignment)
Use \`<domain>_ins_5res_armorm.json\` files for DPO/RLHF training.

## Usage Examples

\`\`\`bash
# Process algebra SFT data
python process_sft_data.py $BASE_OUTPUT_DIR/algebra/algebra_ins_res.json

# Combine all domains for training
python combine_domains.py $BASE_OUTPUT_DIR
\`\`\`

## Quality Metrics

Each domain includes quality evaluation using ArmoRM-Llama3-8B-v0.1 for preference ranking.

Generated by Magpie Math Dataset Generator
EOF

echo -e "\n${GREEN}🎉 Complete dataset generation finished!${NC}"
echo -e "${BLUE}Results:${NC}"
echo "  📁 Base directory: $BASE_OUTPUT_DIR"
echo "  📊 Total problems: 44,000"
echo "  📚 Domains: 6 (algebra, calculus, geometry, statistics, number_theory, discrete)"
echo "  📄 Documentation: $BASE_OUTPUT_DIR/README.md"
echo ""
echo -e "${GREEN}Dataset ready for training!${NC}"