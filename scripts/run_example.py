#!/usr/bin/env python3
"""
実行可能なサンプルスクリプト: DeepSeek R1 6ドメインデータセット生成・統合

このスクリプトは、実際に動作する完全なワークフローを提供します。
"""

import subprocess
import os
import sys
import time
from pathlib import Path

def run_command(cmd, description):
    """コマンドを実行してエラーハンドリング"""
    print(f"\n🚀 {description}")
    print(f"実行: {' '.join(cmd)}")
    
    try:
        result = subprocess.run(cmd, cwd=".", capture_output=True, text=True, check=False)
        
        if result.returncode == 0:
            print(f"✅ {description} 成功")
            if result.stdout:
                print(f"出力: {result.stdout[:500]}...")
            return True
        else:
            print(f"❌ {description} 失敗")
            print(f"エラー: {result.stderr}")
            return False
            
    except Exception as e:
        print(f"❌ {description} 例外発生: {e}")
        return False

def make_scripts_executable():
    """スクリプトに実行権限を付与"""
    scripts_dir = Path("scripts")
    if scripts_dir.exists():
        for script in scripts_dir.glob("*.sh"):
            try:
                os.chmod(script, 0o755)
                print(f"✅ 実行権限付与: {script}")
            except Exception as e:
                print(f"⚠️ 実行権限付与失敗: {script} - {e}")

def check_dependencies():
    """依存関係チェック"""
    print("🔍 依存関係チェック中...")
    
    # Python依存関係
    try:
        import vllm
        print("✅ vLLM インストール済み")
    except ImportError:
        print("❌ vLLM が見つかりません。requirements.txtからインストールしてください")
        return False
    
    try:
        import torch
        print(f"✅ PyTorch {torch.__version__} インストール済み")
    except ImportError:
        print("❌ PyTorch が見つかりません")
        return False
    
    # GPU確認
    try:
        import torch
        if torch.cuda.is_available():
            gpu_count = torch.cuda.device_count()
            print(f"✅ GPU {gpu_count}台 利用可能")
            for i in range(gpu_count):
                gpu_name = torch.cuda.get_device_name(i)
                print(f"  GPU {i}: {gpu_name}")
        else:
            print("⚠️ CUDA GPU が見つかりません。CPUで実行されます（非常に低速）")
    except:
        print("⚠️ GPU情報を取得できませんでした")
    
    return True

def generate_single_domain_demo(domain="algebra", problems=10):
    """単一ドメインのデモ生成（少数問題で高速テスト）"""
    print(f"\n📊 デモ実行: {domain}ドメイン {problems}問題生成")
    
    # 軽量モデルでテスト（DeepSeek R1の代わり）
    model_path = "Qwen/Qwen2.5-3B-Instruct"  # より軽量
    
    cmd = [
        "./scripts/magpie-deepseek-r1-domains.sh",
        domain,
        model_path,
        str(problems),
        "1.0",  # ins_topp
        "1.2",  # ins_temp  
        "1.0",  # res_topp
        "0.1"   # res_temp
    ]
    
    return run_command(cmd, f"{domain}ドメインデモ生成")

def generate_all_domains_demo():
    """全6ドメインの軽量デモ"""
    print("\n🎯 全6ドメイン軽量デモ実行")
    
    domains = ["algebra", "applied-mathematics", "calculus", "discrete-mathematics", "geometry", "number-theory"]
    success_count = 0
    
    for domain in domains:
        if generate_single_domain_demo(domain, problems=5):  # 各ドメイン5問のみ
            success_count += 1
        time.sleep(2)  # GPU cooldown
    
    print(f"\n📈 結果: {success_count}/{len(domains)} ドメイン成功")
    return success_count == len(domains)

def merge_generated_data():
    """生成されたデータを統合"""
    print("\n🔄 データ統合実行")
    
    cmd = ["python", "scripts/merge_domains.py", "--data_dir", "data", "--output_dir", "data"]
    return run_command(cmd, "6ドメインデータ統合")

def main():
    """メイン実行フロー"""
    print("🧮 DeepSeek R1 6ドメインデータセット生成・統合デモ")
    print("=" * 60)
    
    # 1. 依存関係チェック
    if not check_dependencies():
        print("❌ 依存関係が不足しています。setup を確認してください。")
        return False
    
    # 2. スクリプト実行権限付与
    make_scripts_executable()
    
    # 3. 選択肢提示
    print("\n📋 実行オプション:")
    print("  1. 単一ドメインテスト (algebra, 10問)")
    print("  2. 全6ドメイン軽量テスト (各5問)")
    print("  3. フル実行 (各100問) - 推奨しません（時間がかかります）")
    print("  4. データ統合のみ (既存データがある場合)")
    
    try:
        choice = input("\n選択してください (1-4): ").strip()
    except KeyboardInterrupt:
        print("\n\n中断されました。")
        return False
    
    success = False
    
    if choice == "1":
        success = generate_single_domain_demo("algebra", 10)
    elif choice == "2":
        success = generate_all_domains_demo()
    elif choice == "3":
        print("⚠️ フル実行は非常に時間がかかります。継続しますか？ (y/N)")
        confirm = input().strip().lower()
        if confirm == 'y':
            cmd = ["./scripts/generate_all_domains.sh"]
            success = run_command(cmd, "全6ドメインフル生成")
        else:
            print("フル実行をキャンセルしました。")
            return False
    elif choice == "4":
        success = merge_generated_data()
    else:
        print("❌ 無効な選択です。")
        return False
    
    # 4. データ統合（生成が成功した場合）
    if success and choice in ["1", "2", "3"]:
        print("\n📁 生成されたデータを確認中...")
        data_files = list(Path("data").glob("DeepSeek-R1-*/"))
        if data_files:
            print(f"✅ {len(data_files)}個のデータフォルダが見つかりました")
            merge_generated_data()
        else:
            print("⚠️ 生成データが見つかりません")
    
    print("\n🎉 デモ実行完了！")
    print("\n📄 生成ファイル:")
    for file in Path("data").glob("DeepSeek-R1-Math-Combined-*"):
        print(f"  {file}")
    
    return success

if __name__ == "__main__":
    try:
        success = main()
        sys.exit(0 if success else 1)
    except KeyboardInterrupt:
        print("\n\n⚠️ 実行が中断されました。")
        sys.exit(1)
    except Exception as e:
        print(f"\n❌ 予期しないエラー: {e}")
        sys.exit(1)