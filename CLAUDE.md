# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Magpie Reasoning is a HLE (High-Level Examination) math-focused dataset generation system using DeepSeek R1 and other mathematical reasoning models. It generates high-quality mathematical reasoning datasets with Chain-of-Thought approaches for both SFT (Supervised Fine-Tuning) and Alignment data.

## Key Commands

### Data Generation
```bash
# Generate HLE math data using DeepSeek R1 (recommended)
cd scripts
./magpie-deepseek-r1.sh deepseek-ai/DeepSeek-R1 1000 1.0 1.2 1.0 0.1

# Parameters:
# - model_path: Model to use (DeepSeek R1 recommended)
# - total_prompts: Number of problems to generate
# - ins_topp, ins_temp: Problem generation parameters
# - res_topp, res_temp: Answer generation parameters
```

### Alternative Models
```bash
# Qwen2.5-Math 72B
./magpie-qwen2.5-math-72b.sh

# Qwen2-Math 7B (lightweight)
./magpie-qwen2-math-7b.sh

# General math template with Llama models
./magpie_math.sh "meta-llama/Meta-Llama-3-70B-Instruct" 1000
```

### Development Commands
```bash
# Install dependencies
pip install -r requirements.txt

# Run notebook for production workflow
jupyter notebook demo_production.ipynb

# Google Colab version
jupyter notebook demo_colab.ipynb
```

## Architecture

### Core Components

1. **Generation Engine** (`exp/`)
   - `gen_ins.py`: Generates math problems using vLLM with control tasks for math specialization
   - `gen_res.py`: Generates solutions with Chain-of-Thought reasoning
   - `gen_po_multi_res.py`: Creates multiple candidate answers for preference data
   - `gen_po_rewards.py`: Evaluates answer quality for alignment training

2. **Model Configurations** (`configs/model_configs.json`)
   - Contains prompt templates for each model including specialized math templates
   - Stop tokens and model-specific settings
   - DeepSeek R1 uses special tokens like `<｜im_start｜>` and `<｜im_end｜>`

3. **Data Processing**
   - `data_sft/`: Processes instruction-response pairs for supervised fine-tuning
   - `data_po/`: Creates preference data with preferred/rejected answer pairs
   - Generated data stored in `data/` directory with model name and timestamp

### Key Features

- **Math Specialization**: Uses `--control_tasks math` to generate domain-specific problems
- **DeepSeek R1 Optimization**: Configured for large model with `tensor_parallel=4` and optimized memory usage
- **Two Data Types**:
  - SFT: Single high-quality answer per problem
  - Align: Multiple answers with quality rankings for DPO/RLHF

### Model Support

- DeepSeek R1 (685B parameters, 37B activated) - Primary recommendation
- Qwen2.5-Math series (72B, 7B)
- Qwen2-Math series
- Llama 3.x with math templates
- Various other models via `model_configs.json`

## Important Notes

- GPU Requirements: A100 80GB recommended, minimum V100 32GB
- DeepSeek R1 requires Hugging Face login for model access
- Output files follow pattern: `Magpie_{model}_{count}_{timestamp}_{type}.json`
- Japanese logging enabled in DeepSeek R1 scripts for progress tracking
- Temperature settings: Higher for problem generation (1.0-1.2), lower for answers (0.0-0.2)