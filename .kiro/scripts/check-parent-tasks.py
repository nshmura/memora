#!/usr/bin/env python3
"""
Parent Task Auto-Checker

サブタスクが全て完了した際に親タスクを自動でチェックするスクリプト
Usage: python check-parent-tasks.py tasks.md
"""

import sys
import re
from pathlib import Path

def parse_tasks(content):
    """タスク構造を解析"""
    lines = content.split('\n')
    tasks = {}
    current_parent = None
    
    for i, line in enumerate(lines):
        # 親タスク検出 (- [ ] 1. または - [x] 1.)
        parent_match = re.match(r'^- \[([ x])\] (\d+)\. (.+)', line)
        if parent_match:
            checked = parent_match.group(1) == 'x'
            task_num = parent_match.group(2)
            title = parent_match.group(3)
            current_parent = task_num
            tasks[task_num] = {
                'line': i,
                'checked': checked,
                'title': title,
                'subtasks': {},
                'content': line
            }
            continue
        
        # サブタスク検出 (  - [ ] 1.1 または   - [x] 1.1)
        if current_parent:
            sub_match = re.match(r'^  - \[([ x])\] (\d+\.\d+) (.+)', line)
            if sub_match:
                checked = sub_match.group(1) == 'x'
                subtask_num = sub_match.group(2)
                title = sub_match.group(3)
                tasks[current_parent]['subtasks'][subtask_num] = {
                    'line': i,
                    'checked': checked,
                    'title': title,
                    'content': line
                }
    
    return tasks, lines

def check_and_update_parents(tasks, lines):
    """親タスクの自動チェック"""
    updated = False
    
    for parent_num, parent_task in tasks.items():
        # 全サブタスクが完了しているかチェック
        if parent_task['subtasks']:
            all_subtasks_done = all(
                subtask['checked'] for subtask in parent_task['subtasks'].values()
            )
            
            # 親タスクが未完了なのに全サブタスクが完了している場合
            if all_subtasks_done and not parent_task['checked']:
                print(f"✅ Auto-checking parent task {parent_num}: {parent_task['title']}")
                # 行を更新
                old_line = lines[parent_task['line']]
                new_line = old_line.replace('- [ ]', '- [x]', 1)
                lines[parent_task['line']] = new_line
                updated = True
    
    return updated, lines

def main():
    if len(sys.argv) != 2:
        print("Usage: python check-parent-tasks.py tasks.md")
        sys.exit(1)
    
    tasks_file = Path(sys.argv[1])
    if not tasks_file.exists():
        print(f"Error: {tasks_file} not found")
        sys.exit(1)
    
    # ファイル読み込み
    content = tasks_file.read_text(encoding='utf-8')
    
    # タスク解析
    tasks, lines = parse_tasks(content)
    
    # 親タスクチェック
    updated, new_lines = check_and_update_parents(tasks, lines)
    
    if updated:
        # ファイル更新
        new_content = '\n'.join(new_lines)
        tasks_file.write_text(new_content, encoding='utf-8')
        print(f"📝 Updated {tasks_file}")
    else:
        print("✨ All parent tasks are already properly checked")

if __name__ == "__main__":
    main()