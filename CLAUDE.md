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

### HLE Math Specialist Models
```bash
# DeepSeek R1 Distill models
./magpie-deepseek-r1-distill-qwen-32b.sh deepseek-ai/DeepSeek-R1-Distill-Qwen-32B 1000
./magpie-deepseek-r1-distill-llama-70b.sh deepseek-ai/DeepSeek-R1-Distill-Llama-70B 1000

# Quantized model for memory efficiency
./magpie-deepseek-r1-fp4.sh deepseek-ai/DeepSeek-R1-0528-FP4 1000

# Math-specialized models
./magpie-qwen25-math-72b.sh Qwen/Qwen2.5-Math-72B-Instruct 1000
./magpie-qwen25-coder-32b.sh Qwen/Qwen2.5-Coder-32B-Instruct 1000

# Gemma 3 model
./magpie-gemma3-27b.sh google/gemma-3-27b-it 1000
```

### Domain-Specific Generation
```bash
# Interactive menu (recommended)
./run_math_generation.sh

# Generate specific domain
./generate_domain_dataset.sh <model> <domain> <count>

# Generate all domains (36K problems total)
./generate_all_math_domains.sh <model>

# Examples:
./generate_domain_dataset.sh deepseek-ai/DeepSeek-R1-Distill-Qwen-32B algebra 10000
./generate_all_math_domains.sh Qwen/Qwen2.5-Math-72B-Instruct
```

### Development Commands
```bash
# Install dependencies (includes vllm, transformers, and cloud APIs)
pip install -r requirements.txt

# Run notebook for production workflow
jupyter notebook demo_production.ipynb

# Test single model generation
python exp/gen_ins.py --model_path deepseek-ai/DeepSeek-R1 --total_prompts 10 --control_tasks math

# Validate model configuration
python -c "import json; print(json.load(open('configs/model_configs.json')).keys())"
```

## Architecture

### Data Generation Pipeline

The system follows a 4-stage pipeline:

1. **Instruction Generation** (`exp/gen_ins.py`)
   - Uses vLLM for high-throughput problem generation
   - Supports domain-specific generation via `--control_tasks math --domain <domain>`
   - Handles model-specific tokenization and templates from `configs/model_configs.json`

2. **Response Generation** (`exp/gen_res.py`)
   - Generates Chain-of-Thought solutions for problems
   - Uses lower temperature (0.0-0.2) for consistent reasoning
   - Supports both local and API-based generation

3. **Multi-Response Generation** (`exp/gen_po_multi_res.py`)
   - Creates 5 candidate responses per problem for preference data
   - Used for DPO/RLHF alignment training

4. **Quality Evaluation** (`exp/gen_po_rewards.py`)
   - Uses ArmoRM-Llama3-8B-v0.1 to rank response quality
   - Generates preference pairs for alignment training

### Model Configuration System

The `configs/model_configs.json` contains domain-specific prompt templates:
- `pre_query_template_math`: General math problems
- `pre_query_template_algebra`: Algebra-specific prompts
- `pre_query_template_calculus`: Calculus-specific prompts
- `pre_query_template_geometry`: Geometry-specific prompts
- `pre_query_template_statistics`: Statistics-specific prompts
- `pre_query_template_number_theory`: Number theory-specific prompts

### Data Organization

Generated datasets follow this structure:
```
data/
├── <ModelName>_<Domain>_<Timestamp>/
│   ├── <domain>_ins.json              # Problems only
│   ├── <domain>_ins_res.json          # Problems + Solutions (SFT)
│   ├── <domain>_ins_5res.json         # Problems + 5 responses
│   ├── <domain>_ins_5res_armorm.json  # Ranked responses (Align)
│   └── dataset_info.json              # Metadata
```

## Key Implementation Details

### Script Parameters

Most generation scripts accept these key parameters:
- `--total_prompts`: Number of problems to generate
- `--temperature`: Creativity level (1.0-1.2 for problems, 0.0-0.2 for solutions)
- `--top_p`: Nucleus sampling parameter
- `--tensor_parallel_size`: GPU parallelization (2-4 for large models)
- `--gpu_memory_utilization`: Memory usage (0.9-0.95)
- `--control_tasks math`: Enables mathematical problem generation
- `--domain <domain>`: Specifies math domain (algebra, calculus, etc.)

### Model Requirements

- **Memory**: 32GB+ VRAM minimum, 80GB A100 recommended for 70B models
- **Dependencies**: vllm>=0.6.5, transformers, sentence-transformers
- **Authentication**: Hugging Face login required for DeepSeek models

### Data Output Formats

- **SFT Data**: `{"instruction": "...", "response": "..."}`
- **Preference Data**: `{"instruction": "...", "responses": [...], "scores": [...]}`
- **Metadata**: Model configs, generation parameters, timestamps

### Supported Models (HLE Math Focus)

- **DeepSeek R1 Distill Qwen 32B** - Balanced performance, recommended
- **DeepSeek R1 Distill Llama 70B** - High performance, requires A100 80GB
- **DeepSeek R1 0528 FP4** - Memory efficient with FP4 quantization
- **Gemma 3 27B-it** - Google's latest model
- **Qwen2.5-Math 72B** - Mathematics specialist model
- **Qwen2.5-Coder 32B** - Computational mathematics focus

### Math Domains

The system generates problems across 5 specialized domains:

1. **Algebra** (10K problems recommended)
   - Linear and quadratic equations
   - Systems of equations and inequalities
   - Functions and their properties
   - Sequences and series
   - Matrix operations

2. **Calculus** (10K problems recommended)
   - Limits and continuity
   - Derivatives and applications
   - Integration techniques
   - Differential equations
   - Multivariable calculus

3. **Geometry** (6K problems recommended)
   - Euclidean geometry proofs
   - Coordinate geometry
   - Trigonometry
   - Solid geometry
   - Geometric constructions

4. **Statistics** (6K problems recommended)
   - Probability theory
   - Statistical inference
   - Regression analysis
   - Data analysis
   - Bayesian statistics

5. **Number Theory** (4K problems recommended)
   - Prime numbers and divisibility
   - Modular arithmetic
   - Diophantine equations
   - Cryptographic applications
   - Elementary number theory

## Important Notes

- GPU Requirements: A100 80GB recommended, minimum V100 32GB
- DeepSeek R1 requires Hugging Face login for model access
- Output files follow pattern: `Magpie_{model}_{count}_{timestamp}_{type}.json`
- Japanese logging enabled in DeepSeek R1 scripts for progress tracking
- Temperature settings: Higher for problem generation (1.0-1.2), lower for answers (0.0-0.2)

## Development Memories

- 対話式メニューで簡単生成（推奨）: Update `cd scripts/run_math_generation.sh` to support specifying menu choices via arguments