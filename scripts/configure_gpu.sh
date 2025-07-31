#!/bin/bash

# GPU Configuration Setup Script for Magpie
# This script automatically configures tensor_parallel_size based on available GPUs

set -e

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

echo -e "${GREEN}🔧 Magpie GPU Configuration Setup${NC}"
echo "=============================================="

# Function to detect available GPUs
detect_gpus() {
    if command -v nvidia-smi &> /dev/null; then
        nvidia-smi --list-gpus | wc -l
    else
        echo "0"
    fi
}

# Function to get GPU memory info
get_gpu_memory() {
    if command -v nvidia-smi &> /dev/null; then
        nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits | head -1
    else
        echo "0"
    fi
}

# Detect system configuration
AVAILABLE_GPUS=$(detect_gpus)
GPU_MEMORY_MB=$(get_gpu_memory)
GPU_MEMORY_GB=$((GPU_MEMORY_MB / 1024))

echo -e "${BLUE}System Configuration:${NC}"
echo "  Available GPUs: $AVAILABLE_GPUS"
echo "  GPU Memory per device: ${GPU_MEMORY_GB}GB"
echo ""

if [ "$AVAILABLE_GPUS" -eq 0 ]; then
    echo -e "${RED}❌ No NVIDIA GPUs detected!${NC}"
    echo "Please ensure NVIDIA drivers and CUDA are properly installed."
    exit 1
fi

# Function to recommend tensor_parallel_size based on model
recommend_tensor_parallel() {
    local model_type=$1
    local available_gpus=$2
    
    case $model_type in
        "70B"|"72B")
            if [ $available_gpus -ge 4 ]; then
                echo "4"
            elif [ $available_gpus -ge 2 ]; then
                echo "2"
            else
                echo "1"
            fi
            ;;
        "32B"|"27B")
            if [ $available_gpus -ge 2 ]; then
                echo "2"
            else
                echo "1"
            fi
            ;;
        *)
            echo "1"
            ;;
    esac
}

# Interactive mode or automatic mode
if [ "$1" = "--auto" ]; then
    echo -e "${YELLOW}🤖 Automatic configuration mode${NC}"
    AUTO_MODE=true
else
    echo -e "${YELLOW}📝 Interactive configuration mode${NC}"
    echo "Available options:"
    echo "  1) Configure for small models (≤8B) - 1 GPU"
    echo "  2) Configure for medium models (32B) - up to 2 GPUs"
    echo "  3) Configure for large models (70B+) - up to 4 GPUs"
    echo "  4) Custom configuration"
    echo ""
    read -p "Select configuration (1-4): " config_choice
    AUTO_MODE=false
fi

# Set tensor_parallel_size based on choice
if [ "$AUTO_MODE" = true ]; then
    # Auto-detect based on available GPUs
    if [ $AVAILABLE_GPUS -ge 4 ]; then
        TENSOR_PARALLEL_SIZE=4
        CONFIG_TYPE="Large models (70B+)"
    elif [ $AVAILABLE_GPUS -ge 2 ]; then
        TENSOR_PARALLEL_SIZE=2
        CONFIG_TYPE="Medium models (32B)"
    else
        TENSOR_PARALLEL_SIZE=1
        CONFIG_TYPE="Small models (≤8B)"
    fi
else
    case $config_choice in
        1)
            TENSOR_PARALLEL_SIZE=1
            CONFIG_TYPE="Small models (≤8B)"
            ;;
        2)
            TENSOR_PARALLEL_SIZE=$([ $AVAILABLE_GPUS -ge 2 ] && echo "2" || echo "1")
            CONFIG_TYPE="Medium models (32B)"
            ;;
        3)
            if [ $AVAILABLE_GPUS -ge 4 ]; then
                TENSOR_PARALLEL_SIZE=4
            elif [ $AVAILABLE_GPUS -ge 2 ]; then
                TENSOR_PARALLEL_SIZE=2
            else
                TENSOR_PARALLEL_SIZE=1
            fi
            CONFIG_TYPE="Large models (70B+)"
            ;;
        4)
            echo ""
            read -p "Enter custom tensor_parallel_size (1-$AVAILABLE_GPUS): " TENSOR_PARALLEL_SIZE
            if [ $TENSOR_PARALLEL_SIZE -gt $AVAILABLE_GPUS ]; then
                echo -e "${RED}❌ Error: Cannot use more GPUs than available${NC}"
                exit 1
            fi
            CONFIG_TYPE="Custom configuration"
            ;;
        *)
            echo -e "${RED}Invalid choice${NC}"
            exit 1
            ;;
    esac
fi

# Adjust GPU memory utilization based on tensor_parallel_size
if [ $TENSOR_PARALLEL_SIZE -eq 1 ]; then
    GPU_MEMORY_UTIL="0.95"
else
    GPU_MEMORY_UTIL="0.9"
fi

echo ""
echo -e "${PURPLE}🎯 Configuration Summary:${NC}"
echo "  Configuration type: $CONFIG_TYPE"
echo "  Tensor parallel size: $TENSOR_PARALLEL_SIZE"
echo "  GPU memory utilization: $GPU_MEMORY_UTIL"
echo "  Target file: scripts/generate_domain_dataset.sh"
echo ""

# Backup original file
if [ ! -f "scripts/generate_domain_dataset.sh.backup" ]; then
    echo -e "${YELLOW}📋 Creating backup of original file...${NC}"
    cp scripts/generate_domain_dataset.sh scripts/generate_domain_dataset.sh.backup
fi

# Apply configuration
echo -e "${YELLOW}🔧 Applying GPU configuration...${NC}"

# Update tensor_parallel_size in generate_domain_dataset.sh
sed -i "s/--tensor_parallel_size [0-9]\+/--tensor_parallel_size $TENSOR_PARALLEL_SIZE/g" scripts/generate_domain_dataset.sh

# Update gpu_memory_utilization
sed -i "s/--gpu_memory_utilization [0-9.]\+/--gpu_memory_utilization $GPU_MEMORY_UTIL/g" scripts/generate_domain_dataset.sh

echo -e "${GREEN}✅ GPU configuration applied successfully!${NC}"
echo ""
echo -e "${BLUE}📝 Changes made:${NC}"
echo "  - tensor_parallel_size: $TENSOR_PARALLEL_SIZE"
echo "  - gpu_memory_utilization: $GPU_MEMORY_UTIL"
echo "  - Backup saved: scripts/generate_domain_dataset.sh.backup"
echo ""

# Show model compatibility
echo -e "${YELLOW}🎯 Model Compatibility:${NC}"
case $TENSOR_PARALLEL_SIZE in
    1)
        echo "  ✅ DeepSeek-R1-Distill-Qwen-32B (single GPU)"
        echo "  ✅ Gemma-3-27B (single GPU)"
        echo "  ⚠️  Large models (70B+) may require more memory"
        ;;
    2)
        echo "  ✅ DeepSeek-R1-Distill-Qwen-32B"
        echo "  ✅ Gemma-3-27B"
        echo "  ✅ DeepSeek-R1-FP4"
        echo "  ⚠️  Large models (70B+) may work with reduced performance"
        ;;
    4)
        echo "  ✅ All supported models"
        echo "  ✅ DeepSeek-R1-Distill-Llama-70B"
        echo "  ✅ Qwen2.5-Math-72B"
        ;;
esac

echo ""
echo -e "${GREEN}🚀 Ready to run Magpie with optimized GPU configuration!${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "  1. Test with: ./run_math_generation.sh 1 0.01 1"
echo "  2. Run full generation: ./run_math_generation.sh 1 1.0 1"
echo ""
echo -e "${YELLOW}💡 To restore original settings:${NC}"
echo "  cp scripts/generate_domain_dataset.sh.backup scripts/generate_domain_dataset.sh"
