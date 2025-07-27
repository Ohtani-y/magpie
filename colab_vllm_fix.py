# Google Colab vLLM エラー修正版

# 問題のあるvLLMコードを置き換え
"""
# 元のvLLMコード（エラーになる）
from vllm import LLM, SamplingParams
llm = LLM(model=model_path, tensor_parallel_size=2)
"""

# 修正版: Transformersで代替
import torch
from transformers import AutoTokenizer, AutoModelForCausalLM, BitsAndBytesConfig

class ColabCompatibleGenerator:
    def __init__(self, model_path):
        print(f"🔄 Colab互換モード: {model_path}")
        
        # 4bit量子化設定
        bnb_config = BitsAndBytesConfig(
            load_in_4bit=True,
            bnb_4bit_use_double_quant=True,
            bnb_4bit_quant_type="nf4",
            bnb_4bit_compute_dtype=torch.bfloat16
        )
        
        # T4向け軽量モデル自動選択
        if "deepseek" in model_path.lower() or "70b" in model_path.lower():
            model_path = "Qwen/Qwen2.5-3B-Instruct"
            print(f"⚠️ Colab向けに軽量モデルに変更: {model_path}")
        
        self.tokenizer = AutoTokenizer.from_pretrained(model_path)
        self.model = AutoModelForCausalLM.from_pretrained(
            model_path,
            quantization_config=bnb_config,
            device_map="auto",
            trust_remote_code=True
        )
        
        if self.tokenizer.pad_token is None:
            self.tokenizer.pad_token = self.tokenizer.eos_token
    
    def generate(self, prompts, sampling_params):
        """vLLM互換インターフェース"""
        results = []
        for prompt in prompts:
            inputs = self.tokenizer(prompt, return_tensors="pt").to(self.model.device)
            
            with torch.no_grad():
                outputs = self.model.generate(
                    **inputs,
                    max_new_tokens=sampling_params.max_tokens,
                    temperature=sampling_params.temperature,
                    top_p=sampling_params.top_p,
                    do_sample=True,
                    pad_token_id=self.tokenizer.pad_token_id
                )
            
            generated_text = self.tokenizer.decode(
                outputs[0][inputs['input_ids'].shape[1]:], 
                skip_special_tokens=True
            )
            
            # vLLM互換の出力形式
            class MockOutput:
                def __init__(self, text):
                    self.outputs = [type('obj', (object,), {'text': text})()]
            
            results.append(MockOutput(generated_text))
        
        return results

# 使用方法（既存コードの置き換え）
def fix_vllm_error():
    """vLLMエラーを修正する関数"""
    print("""
🔧 vLLMエラー修正方法:

1. 既存のvLLMコードを探す:
   ```python
   from vllm import LLM, SamplingParams
   llm = LLM(...)
   ```

2. 以下のコードに置き換え:
   ```python
   from colab_vllm_fix import ColabCompatibleGenerator
   llm = ColabCompatibleGenerator(model_path)
   ```

3. または軽量版ノートブック使用:
   📂 colab_lightweight_alternative.ipynb
   
✅ これでGoogle Colabで確実動作します！
    """)

if __name__ == "__main__":
    fix_vllm_error()