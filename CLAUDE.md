# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is the Magpie Reasoning system for generating high-quality mathematics reasoning datasets specialized for HLE (High-Level Examination) mathematics. It uses DeepSeek R1 and other models to generate complex mathematical problems and solutions with detailed reasoning chains.

## Common Commands

### Installation
```bash
pip install -r requirements.txt
```

### Quick Start - Generate Math Datasets
```bash
# Interactive mode (recommended for first-time users)
cd scripts
./run_math_generation.sh

# Direct execution with numeric arguments
./run_math_generation.sh 1 1.0 1      # DeepSeek-Qwen-32B, all domains, 100% (44K problems)
./run_math_generation.sh 5 0.5 1      # Qwen-Math-72B, all domains, 50% (22K problems)  
./run_math_generation.sh 2 0.5 2 2    # DeepSeek-Llama-70B, calculus domain, 50% (5K problems)
./run_math_generation.sh -h           # Show Japanese help
```

### GPU Configuration (Important - Run before first use)
```bash
# Automatic GPU configuration (recommended)
./scripts/configure_gpu.sh --auto

# Interactive GPU configuration
./scripts/configure_gpu.sh

# Restore original settings
cp scripts/generate_domain_dataset.sh.backup scripts/generate_domain_dataset.sh
```

## Architecture Overview

The system follows a 4-stage pipeline for generating mathematical reasoning datasets:

1. **Problem Generation** (`exp/gen_ins.py`)
   - Generates mathematical problems across 6 domains (algebra, calculus, geometry, statistics, number theory, discrete math)
   - Uses high temperature (1.0-1.35) for creative problem generation
   - Outputs: `*_ins.json` files

2. **Solution Generation** (`exp/gen_res.py`)
   - Generates detailed step-by-step solutions using Chain-of-Thought reasoning
   - Uses low temperature (0.0-0.05) for precise, rigorous solutions
   - Maximum 4096 tokens for detailed 10-20 step proofs
   - Outputs: `*_ins_res.json` files (SFT training data)

3. **Multiple Response Generation** (`exp/gen_po_multi_res.py`)
   - Generates 7 different solution approaches per problem
   - Used for preference learning and alignment
   - Outputs: `*_ins_7res.json` files

4. **Quality Evaluation** (`exp/gen_po_rewards.py`)
   - Uses ArmoRM-Llama3-8B model to evaluate and rank the 7 solutions
   - Creates preference pairs for DPO/RLHF training
   - Outputs: `*_ins_7res_armorm.json` files (preference/alignment data)

### Key Scripts

- `scripts/run_math_generation.sh` - Main entry point with interactive menu
- `scripts/generate_domain_dataset.sh` - Generates data for a single math domain
- `scripts/generate_all_math_domains.sh` - Generates data for all 6 domains
- `scripts/configure_gpu.sh` - Configures GPU settings for different hardware

### Configuration

Model configurations are stored in `configs/model_configs.json`. Each model has specific:
- Stop tokens and token IDs
- Temperature and sampling parameters
- GPU memory requirements

### Output Structure

Generated datasets are saved to `data/` directory with timestamped folders:
```
data/
├── <ModelName>_<Domain>_<Timestamp>/
│   ├── <domain>_ins.json                 # Problems only
│   ├── <domain>_ins_res.json            # Problems + solutions (SFT data)
│   ├── <domain>_ins_7res.json           # Problems + 7 solutions
│   ├── <domain>_ins_7res_armorm.json    # Evaluated preference data
│   └── dataset_info.json                # Metadata
```

## Domain-Specific Problem Counts (HLE Optimized)

- **Algebra**: 10,000 problems (abstract algebra, Galois theory, field extensions)
- **Calculus**: 10,000 problems (real/complex analysis, measure theory)
- **Geometry**: 6,000 problems (projective, differential, algebraic geometry)
- **Statistics**: 6,000 problems (measure-theoretic probability, advanced inference)
- **Number Theory**: 4,000 problems (analytic/algebraic number theory, L-functions)
- **Discrete Math**: 8,000 problems (extremal graph theory, complexity theory)

Total: 44,000 problems at 100% scale

## GPU Requirements

- **Minimum**: NVIDIA V100 (32GB) or RTX 4090 (24GB)
- **Recommended**: NVIDIA A100 (80GB)
- **Tensor Parallel**: Supports multi-GPU for 70B+ models

## Important Notes

- Always run GPU configuration before first use
- DeepSeek models require Hugging Face authentication
- Each domain generation creates 4 output files (problems, SFT data, multiple responses, preference data)
- Generated data uses CC BY-NC 4.0 license
- For research on high-difficulty mathematics problems with deep reasoning chains (10-20 steps)