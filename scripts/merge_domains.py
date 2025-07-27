#!/usr/bin/env python3
"""
DeepSeek R1 6ドメインデータセット統合スクリプト

オリジナルデータの変更を最小限にして、6つの数学ドメインデータを統合・シャッフルします。
"""

import json
import random
import glob
import os
from pathlib import Path
from datetime import datetime
import argparse

def find_deepseek_r1_files(data_dir="data"):
    """DeepSeek R1で生成されたファイルを自動検出"""
    deepseek_dirs = glob.glob(f"{data_dir}/DeepSeek-R1-*")
    
    domain_files = {}
    domains = ["algebra", "applied-mathematics", "calculus", "discrete-mathematics", "geometry", "number-theory"]
    
    for domain in domains:
        # ドメイン名でフィルタリング
        domain_dirs = [d for d in deepseek_dirs if domain in d.lower()]
        
        if domain_dirs:
            # 最新のディレクトリを選択
            latest_dir = max(domain_dirs, key=os.path.getctime)
            
            # *_ins_res.jsonファイルを探す
            res_files = glob.glob(f"{latest_dir}/Magpie_DeepSeek-R1_*_ins_res.json")
            if res_files:
                domain_files[domain] = res_files[0]
    
    return domain_files

def add_domain_metadata(data, domain_name):
    """各エントリにドメインメタデータを追加（最小限の変更）"""
    for item in data:
        # オリジナルデータに最小限のメタデータのみ追加
        item['domain'] = domain_name
        item['source'] = 'deepseek-r1'
        item['dataset_version'] = '1.0'
    return data

def merge_and_shuffle_domains(domain_files, output_dir="data"):
    """6ドメインのデータを統合・シャッフル"""
    all_data = []
    domain_stats = {}
    
    print("📊 ドメイン別データ読み込み中...")
    
    for domain, filepath in domain_files.items():
        print(f"  📁 {domain}: {filepath}")
        
        try:
            with open(filepath, 'r', encoding='utf-8') as f:
                domain_data = json.load(f)
            
            # ドメインメタデータを追加（最小限）
            domain_data = add_domain_metadata(domain_data, domain)
            
            all_data.extend(domain_data)
            domain_stats[domain] = len(domain_data)
            
            print(f"    ✅ {len(domain_data)}問題を読み込み")
            
        except Exception as e:
            print(f"    ❌ エラー: {e}")
            continue
    
    print(f"\n📈 統計:")
    total_problems = sum(domain_stats.values())
    for domain, count in domain_stats.items():
        percentage = (count / total_problems) * 100 if total_problems > 0 else 0
        print(f"  {domain}: {count}問題 ({percentage:.1f}%)")
    print(f"  合計: {total_problems}問題")
    
    # データをシャッフル
    print("\n🔀 データをシャッフル中...")
    random.shuffle(all_data)
    
    # 出力ファイル名
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    merged_file = f"{output_dir}/DeepSeek-R1-Math-Combined-{total_problems}_{timestamp}.json"
    
    # 統合データを保存
    os.makedirs(output_dir, exist_ok=True)
    with open(merged_file, 'w', encoding='utf-8') as f:
        json.dump(all_data, f, ensure_ascii=False, indent=2)
    
    print(f"✅ 統合データセット保存: {merged_file}")
    
    return merged_file, domain_stats

def convert_to_sharegpt(merged_file, output_dir="data"):
    """ShareGPT形式に変換"""
    print("\n🔄 ShareGPT形式への変換中...")
    
    with open(merged_file, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    # ShareGPT形式のファイル名
    base_name = Path(merged_file).stem
    sharegpt_file = f"{output_dir}/{base_name}_sharegpt.jsonl"
    
    with open(sharegpt_file, 'w', encoding='utf-8') as f:
        for i, item in enumerate(data):
            # ShareGPT形式に変換（最小限の構造）
            sharegpt_entry = {
                "conversation_id": f"deepseek-r1-math-{i}",
                "domain": item.get('domain', 'unknown'),
                "source": item.get('source', 'deepseek-r1'),
                "conversations": [
                    {"from": "human", "value": item['instruction']},
                    {"from": "gpt", "value": item['response']}
                ],
                "gen_input_configs": item.get('gen_input_configs', {}),
                "gen_response_configs": item.get('gen_response_configs', {}),
                "pre_query_template": item.get('pre_query_template', ''),
                "created": item.get('created', ''),
                "id": item.get('id', i)
            }
            
            f.write(json.dumps(sharegpt_entry, ensure_ascii=False) + '\n')
    
    print(f"✅ ShareGPT形式データ保存: {sharegpt_file}")
    return sharegpt_file

def main():
    parser = argparse.ArgumentParser(description="DeepSeek R1 6ドメインデータセット統合")
    parser.add_argument("--data_dir", default="data", help="データディレクトリ")
    parser.add_argument("--output_dir", default="data", help="出力ディレクトリ")
    parser.add_argument("--seed", type=int, default=42, help="シャッフル用シード")
    
    args = parser.parse_args()
    
    # シャッフル用シードを設定
    random.seed(args.seed)
    
    print("🧮 DeepSeek R1 6ドメイン数学データセット統合ツール")
    print("=" * 60)
    
    # DeepSeek R1ファイルを自動検出
    domain_files = find_deepseek_r1_files(args.data_dir)
    
    if not domain_files:
        print("❌ DeepSeek R1で生成されたファイルが見つかりません")
        print("先に generate_all_domains.sh を実行してください")
        return
    
    print(f"📁 検出されたファイル: {len(domain_files)}個")
    for domain, filepath in domain_files.items():
        print(f"  {domain}: {Path(filepath).name}")
    
    # データを統合・シャッフル
    merged_file, stats = merge_and_shuffle_domains(domain_files, args.output_dir)
    
    # ShareGPT形式に変換
    sharegpt_file = convert_to_sharegpt(merged_file, args.output_dir)
    
    print("\n🎉 処理完了！")
    print("📄 出力ファイル:")
    print(f"  - 統合データ: {merged_file}")
    print(f"  - ShareGPT形式: {sharegpt_file}")

if __name__ == "__main__":
    main()