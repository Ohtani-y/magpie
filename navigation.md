# 🧮 Reasoning特化データセットナビゲーション

## HLE数学対策データセット

### [**DeepSeek R1**](https://huggingface.co/deepseek-ai/DeepSeek-R1) - 推奨
|モデル名 | データセット | タイプ | 説明 |
|-------------|:-------|:-------|:-------|
| [DeepSeek R1 685B](https://huggingface.co/deepseek-ai/DeepSeek-R1) | Magpie-DeepSeek-R1-Math-Reasoning | SFT | HLE数学対策に特化した高品質推論データセット
| [DeepSeek R1 685B](https://huggingface.co/deepseek-ai/DeepSeek-R1) | Magpie-DeepSeek-R1-CoT-Math | SFT | Chain-of-Thought推論を含む数学問題解決データセット

### [**Meta Llama 3.1**](https://huggingface.co/collections/meta-llama/llama-31-669fc079a0c406a149a5738f)
|Model Name | Dataset | Type | Description |
|-------------|:-------|:-------|:-------|
| [Llama 3.1 70B Instruct](https://huggingface.co/meta-llama/Meta-Llama-3.1-70B-Instruct) | [Magpie-Llama-3.1-Pro-1M](https://huggingface.co/datasets/Magpie-Align/Magpie-Llama-3.1-Pro-1M-v0.1) | SFT | 1M Raw conversations built with Meta Llama 3.1 70B.
| [Llama 3.1 70B Instruct](https://huggingface.co/meta-llama/Meta-Llama-3.1-70B-Instruct) | [Magpie-Llama-3.1-Pro-300K-Filtered](https://huggingface.co/datasets/Magpie-Align/Magpie-Llama-3.1-Pro-300K-Filtered) | SFT | Apply a filter and select 300K high quality conversations.
| [Llama 3.1 70B Instruct](https://huggingface.co/meta-llama/Meta-Llama-3.1-70B-Instruct) | [Magpie-Llama-3.1-Pro-500K-Filtered](https://huggingface.co/datasets/Magpie-Align/Magpie-Llama-3.1-Pro-500K-Filtered) | SFT | Apply a filter and select 500K high quality conversations.
| [Llama 3.1 70B Instruct](https://huggingface.co/meta-llama/Meta-Llama-3.1-70B-Instruct) | [Magpie-Llama-3.1-Pro-MT-500K](https://huggingface.co/datasets/Magpie-Align/Magpie-Llama-3.1-Pro-MT-500K-v0.1) | SFT | Extend Magpie-Llama-3.1-Pro-500K-Filtered to multi-turn.
| [Llama 3.1 70B Instruct](https://huggingface.co/meta-llama/Meta-Llama-3.1-70B-Instruct) | [Magpie-Llama-3.1-Pro-MT-300K-Filtered](https://huggingface.co/datasets/Magpie-Align/Magpie-Llama-3.1-Pro-MT-300K-Filtered) | SFT | Select 300K high quality multi-turn conversations from Magpie-Llama-3.1-Pro-MT-500K.
| [Llama 3.1 70B Instruct](https://huggingface.co/meta-llama/Meta-Llama-3.1-70B-Instruct) | [Magpie-Llama-3.1-Pro-DPO-100K](https://huggingface.co/datasets/Magpie-Align/Magpie-Llama-3.1-Pro-DPO-100K-v0.1) | DPO | DPO dataset via Best-of-N sampling and rewards.

### [**Meta Llama 3**](https://huggingface.co/collections/meta-llama/meta-llama-3-66214712577ca38149ebb2b6)
|Model Name | Dataset | Type | Description |
|-------------|:-------|:-------|:-------|
| [Llama 3 70B Instruct](https://huggingface.co/meta-llama/Meta-Llama-3-70B-Instruct) | [Magpie-Pro-1M](https://huggingface.co/datasets/Magpie-Align/Llama-3-Magpie-Pro-1M-v0.1) | SFT | 1M Raw conversations built with Meta Llama 3 70B.
| [Llama 3 70B Instruct](https://huggingface.co/meta-llama/Meta-Llama-3-70B-Instruct) | [Magpie-Pro-300K-Filtered](https://huggingface.co/datasets/Magpie-Align/Magpie-Pro-300K-Filtered) | SFT | Apply a filter and select 300K high quality conversations.
| [Llama 3 70B Instruct](https://huggingface.co/meta-llama/Meta-Llama-3-70B-Instruct) | [Magpie-Pro-MT-300K](https://huggingface.co/datasets/Magpie-Align/Magpie-Pro-MT-300K-v0.1) | SFT | Select 300K difficult questions and extend to multi-turn conversations.
| [Llama 3 70B Instruct](https://huggingface.co/meta-llama/Meta-Llama-3-70B-Instruct) | [Magpie-Pro-DPO-100K](https://huggingface.co/datasets/Magpie-Align/Magpie-Pro-DPO-100K-v0.1) | DPO | DPO dataset via Best-of-N sampling and rewards.
| [Llama 3 8B Instruct](https://huggingface.co/meta-llama/Meta-Llama-3-8B-Instruct) | [Magpie-Air-3M](https://huggingface.co/datasets/Magpie-Align/Llama-3-Magpie-Air-3M-v0.1) | SFT | 3M Raw conversations built with Meta Llama 3 8B.
| [Llama 3 8B Instruct](https://huggingface.co/meta-llama/Meta-Llama-3-8B-Instruct) | [Magpie-Air-300K-Filtered](https://huggingface.co/datasets/Magpie-Align/Magpie-Air-300K-Filtered) | SFT | Apply a filter and select 300K high quality data.
| [Llama 3 8B Instruct](https://huggingface.co/meta-llama/Meta-Llama-3-8B-Instruct) | [Magpie-Air-MT-300K](https://huggingface.co/datasets/Magpie-Align/Magpie-Air-MT-300K-v0.1) | SFT | Select 300K difficult questions and extend to multi-turn conversations.
| [Llama 3 8B Instruct](https://huggingface.co/meta-llama/Meta-Llama-3-8B-Instruct) | [Magpie-Air-DPO-100K](https://huggingface.co/datasets/Magpie-Align/Magpie-Air-DPO-100K-v0.1) | DPO | DPO dataset via Best-of-N sampling and rewards.

### [**Qwen2.5**](https://huggingface.co/collections/Qwen/qwen25-66e81a666513e518adb90d9e)
|Model Name | Dataset | Type | Description |
|-------------|:-------|:-------|:-------|
| [Qwen2.5 72B Instruct](https://huggingface.co/Qwen/Qwen2.5-72B-Instruct) | [Magpie-Qwen2.5-Pro-1M](https://huggingface.co/datasets/Magpie-Align/Magpie-Qwen2.5-Pro-1M-v0.1) | SFT | 1M Raw conversations built with Qwen2.5 72B Instruct.
| [Qwen2.5 72B Instruct](https://huggingface.co/Qwen/Qwen2.5-72B-Instruct) | [Magpie-Qwen2.5-Pro-300K-Filtered](https://huggingface.co/datasets/Magpie-Align/Magpie-Qwen2.5-Pro-300K-Filtered) | SFT | Apply a filter and select 300K high quality conversations.

### [**Qwen2**](https://huggingface.co/collections/Qwen/qwen2-6659360b33528ced941e557f)
|Model Name | Dataset | Type | Description |
|-------------|:-------|:-------|:-------|
| [Qwen2 72B Instruct](https://huggingface.co/Qwen/Qwen2-72B-Instruct) | [Magpie-Qwen2-Pro-1M](https://huggingface.co/datasets/Magpie-Align/Magpie-Qwen2-Pro-1M-v0.1) | SFT | 1M Raw conversations built with Qwen2 72B Instruct.
| [Qwen2 72B Instruct](https://huggingface.co/Qwen/Qwen2-72B-Instruct) | [Magpie-Qwen2-Pro-300K-Filtered](https://huggingface.co/datasets/Magpie-Align/Magpie-Qwen2-Pro-300K-Filtered) | SFT | Apply a filter and select 300K high quality conversations.
| [Qwen2 72B Instruct](https://huggingface.co/Qwen/Qwen2-72B-Instruct) | [Magpie-Qwen2-Pro-200K-Chinese](https://huggingface.co/datasets/Magpie-Align/Magpie-Qwen2-Pro-200K-Chinese) | SFT | Apply a filter and select 200K high quality Chinese conversations.
| [Qwen2 72B Instruct](https://huggingface.co/Qwen/Qwen2-72B-Instruct) | [Magpie-Qwen2-Pro-200K-English](https://huggingface.co/datasets/Magpie-Align/Magpie-Qwen2-Pro-200K-English) | SFT | Apply a filter and select 200K high quality English conversations.
| [Qwen2 7B Instruct](https://huggingface.co/Qwen/Qwen2-7B-Instruct) | [Magpie-Qwen2-Air-3M](https://huggingface.co/datasets/Magpie-Align/Magpie-Qwen2-Air-3M-v0.1) | SFT | 3M Raw conversations built with Qwen2 7B Instruct.
| [Qwen2 7B Instruct](https://huggingface.co/Qwen/Qwen2-7B-Instruct) | [Magpie-Qwen2-Air-300K-Filtered](https://huggingface.co/datasets/Magpie-Align/Magpie-Qwen-Air-300K-Filtered) | SFT | Apply a filter and select 300K high quality conversations.

### [**Phi-3**](https://huggingface.co/collections/microsoft/phi-3-6626e15e9585a200d2d761e3)
|Model Name | Dataset | Type | Description |
|-------------|:-------|:-------|:-------|
| [Phi-3 Medium Instruct](https://huggingface.co/microsoft/Phi-3-medium-128k-instruct) | [Magpie-Phi3-Pro-1M](https://huggingface.co/datasets/Magpie-Align/Magpie-Phi3-Pro-1M-v0.1) | SFT | 1M Raw conversations built with Phi-3 Medium Instruct.
| [Phi-3 Medium Instruct](https://huggingface.co/microsoft/Phi-3-medium-128k-instruct) | [Magpie-Phi3-Pro-300K-Filtered](https://huggingface.co/datasets/Magpie-Align/Magpie-Phi3-Pro-300K-Filtered) | SFT | Apply a filter and select 300K high quality conversations.

### [**Gemma-2**](https://huggingface.co/collections/google/gemma-2-release-667d6600fd5220e7b967f315)
|Model Name | Dataset | Type | Description |
|-------------|:-------|:-------|:-------|
| [Gemma-2-27b-it](https://huggingface.co/google/gemma-2-27b-it) | [Magpie-Gemma2-Pro-534K](https://huggingface.co/datasets/Magpie-Align/Magpie-Gemma2-Pro-534K-v0.1) | SFT | 534K conversations built with Gemma-2-27b-it.
| [Gemma-2-27b-it](https://huggingface.co/google/gemma-2-27b-it) | [Magpie-Gemma2-Pro-200K-Filtered](https://huggingface.co/datasets/Magpie-Align/Magpie-Gemma2-Pro-200K-Filtered) | SFT | Apply a filter and select 200K conversations.

---

## Domain Datasets

### 🧠 CoT推論データセット
|モデル | データセット | タイプ | 説明 |
|-------------|:-------|:-------|:-------|
| DeepSeek R1 (問題生成) + DeepSeek R1 (解答生成) | [Magpie-Reasoning-V3-DeepSeek-R1-Math](https://huggingface.co/datasets/Magpie-Align/Magpie-Reasoning-V3-DeepSeek-R1-Math) | SFT | HLE数学対策に特化したDeepSeek R1による高品質推論データセット
| Qwen2-72B-Instruct (問題) + DeepSeek R1 (解答) | [Magpie-Reasoning-V1-150K-CoT-Deepseek-R1-Llama-70B](https://huggingface.co/datasets/Magpie-Align/Magpie-Reasoning-V1-150K-CoT-Deepseek-R1-Llama-70B) | SFT | 150K件のQwen2問題とDeepSeek R1解答の組み合わせ
| Llama3.1/3.3-70B-Instruct (問題) + DeepSeek R1 (解答) | [Magpie-Reasoning-V2-250K-CoT-Deepseek-R1-Llama-70B](https://huggingface.co/datasets/Magpie-Align/Magpie-Reasoning-V2-250K-CoT-Deepseek-R1-Llama-70B) | SFT | 250K件のLlama3問題とDeepSeek R1解答の組み合わせ


## 🎯 HLE対策推奨データセット組み合わせ

### 基本セット（初級〜中級）
- **Magpie-Qwen2-Math-Lightweight-100K**: 基礎数学問題
- **Magpie-Algebra-HLE-50K**: 代数学強化
- **Magpie-Geometry-HLE-30K**: 幾何学基礎

### 標準セット（中級〜上級）
- **Magpie-DeepSeek-R1-HLE-Math-500K**: メインデータセット
- **Magpie-Calculus-HLE-50K**: 微積分学
- **Magpie-Statistics-HLE-30K**: 統計学

### 完全セット（上級〜最高レベル）
- **Magpie-DeepSeek-R1-HLE-Math-500K**: メインデータセット
- **全分野別データセット**: 180K件の専門問題
- **Magpie-Reasoning-V3-DeepSeek-R1-Math**: CoT推論強化

## 📈 データセット品質指標

|品質レベル | 特徴 | 推奨用途 |
|-------------|:-------|:-------|
| ⭐⭐⭐⭐⭐ | DeepSeek R1生成、CoT推論、HLE特化 | 最高レベル試験対策
| ⭐⭐⭐⭐ | 数学特化モデル生成、段階的解法 | 上級試験対策
| ⭐⭐⭐ | 汎用モデル+数学テンプレート | 中級試験対策

### 📐 数学特化データセット

|モデル | データセット | タイプ | 説明 |
|-------------|:-------|:-------|:-------|
| [DeepSeek R1](https://huggingface.co/deepseek-ai/DeepSeek-R1) | Magpie-DeepSeek-R1-HLE-Math-500K | SFT | HLE対策に特化した500K件の数学推論データセット
| [Qwen2.5 Math 72B](https://huggingface.co/Qwen/Qwen2.5-Math-72B-Instruct) | [Magpie-Qwen2.5-Math-Pro-300K-v0.1](https://huggingface.co/datasets/Magpie-Align/Magpie-Qwen2.5-Math-Pro-300K-v0.1) | SFT | Qwen2.5 Math 72Bによる300K件の数学対話データ
| [Qwen2 Math 7B](https://huggingface.co/Qwen/Qwen2-Math-7B-Instruct) | Magpie-Qwen2-Math-Lightweight-100K | SFT | 軽量版数学データセット（100K件）

### 📊 分野別数学データセット

|数学分野 | データセット | 問題数 | 特徴 |
|-------------|:-------|:-------|:-------|
| 代数学 (Algebra) | Magpie-Algebra-HLE-50K | 50K | 二次方程式、不等式、関数等
| 微積分学 (Calculus) | Magpie-Calculus-HLE-50K | 50K | 極限、微分、積分、応用問題
| 幾何学 (Geometry) | Magpie-Geometry-HLE-30K | 30K | 平面・立体幾何、三角法
| 統計学 (Statistics) | Magpie-Statistics-HLE-30K | 30K | 確率、統計的推論、データ分析
| 数論 (Number Theory) | Magpie-NumberTheory-HLE-20K | 20K | 整数論、暗号理論基礎
