#!/usr/bin/env python3
"""
Call-Site & Reachability Audit Tool
Scans Java / Python codebases to detect orphaned methods (methods declared but never called).
"""

import os
import sys
import re
import argparse
from pathlib import Path

# Force UTF-8 on Windows terminals
if sys.stdout.encoding != 'utf-8':
    try:
        sys.stdout.reconfigure(encoding='utf-8')
    except Exception:
        pass

# Common methods to exclude from dead code warnings (framework / lifecycle hooks)
IGNORED_METHODS = {
    'main', 'init', 'create', 'render', 'dispose', 'resize', 'pause', 'resume',
    'act', 'draw', 'update', 'run', 'toString', 'hashCode', 'equals', 'clone',
    'compareTo', 'iterator', 'close', '__init__', '__str__', '__repr__',
    'handle', 'received', 'connected', 'disconnected', 'idle'
}

JAVA_METHOD_PATTERN = re.compile(
    r'(?:public|protected|private|static|\s)+[\w<>\[\]]+\s+([a-zA-Z0-9_]+)\s*\([^)]*\)\s*(?:throws\s+[\w\s,]+)?\s*\{'
)

def find_java_methods(content: str):
    """Find declared method names and their line numbers."""
    methods = []
    lines = content.splitlines()
    for idx, line in enumerate(lines, start=1):
        line_clean = line.strip()
        # Skip comments
        if line_clean.startswith('//') or line_clean.startswith('/*') or line_clean.startswith('*'):
            continue
        match = JAVA_METHOD_PATTERN.search(line)
        if match:
            method_name = match.group(1)
            # Avoid constructors or control flow keywords
            if method_name not in {'if', 'for', 'while', 'switch', 'catch'}:
                methods.append((method_name, idx))
    return methods

def audit_directory(target_dir: str):
    target_path = Path(target_dir)
    if not target_path.exists():
        print(f"Error: Path {target_dir} does not exist.")
        sys.exit(1)

    java_files = list(target_path.rglob("*.java"))
    if not java_files:
        print(f"No Java files found in {target_dir}")
        return

    # 1. Index all file contents
    file_contents = {}
    for f in java_files:
        try:
            file_contents[f] = f.read_text(encoding="utf-8", errors="ignore")
        except Exception as e:
            print(f"Warning: could not read {f}: {e}")

    # 2. Extract methods
    all_methods = []
    for f, content in file_contents.items():
        methods = find_java_methods(content)
        for m_name, line_num in methods:
            if m_name not in IGNORED_METHODS:
                all_methods.append((m_name, f, line_num))

    # 3. Check call-sites across all files
    orphans = []
    active = []

    for m_name, def_file, line_num in all_methods:
        # Regex to find call: method_name followed by '('
        call_regex = re.compile(rf'\b{re.escape(m_name)}\s*\(')
        call_count = 0
        call_locations = []

        for f, content in file_contents.items():
            for l_idx, line in enumerate(content.splitlines(), start=1):
                if f == def_file and l_idx == line_num:
                    continue  # Skip definition line itself
                if call_regex.search(line):
                    call_count += 1
                    call_locations.append((f.name, l_idx))

        if call_count == 0:
            orphans.append((m_name, def_file, line_num))
        else:
            active.append((m_name, def_file, line_num, call_count))

    # 4. Report
    print("=" * 60)
    print(f"🔎 CALL-SITE AUDIT REPORT: {target_dir}")
    print(f"Total Java files: {len(java_files)}")
    print(f"Total methods analyzed: {len(all_methods)}")
    print(f"Active connected methods: {len(active)}")
    print(f"Potential orphaned methods (Dead Code): {len(orphans)}")
    print("=" * 60)

    if orphans:
        print("\n⚠️ WARNING: The following methods have NO callers in the scanned codebase:")
        for m_name, f, line_num in orphans:
            rel_path = f.relative_to(target_path)
            print(f"  - [{rel_path}:{line_num}] {m_name}()")
    else:
        print("\n✅ All analyzed methods have at least one active call-site!")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Audit Java codebase for dead code and uncalled methods.")
    parser.add_argument("dir", nargs="?", default=".", help="Directory to audit")
    args = parser.parse_args()
    audit_directory(args.dir)
