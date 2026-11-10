#!/usr/bin/env python3
import argparse
import glob
import os
import subprocess
import sys
from pathlib import Path


def git_last_commit_ts(repo_dir: Path, relpath: Path):
    try:
        # run git log -1 --format=%ct -- <path>
        res = subprocess.run(
            ["git", "-C", str(repo_dir), "log", "-1", "--format=%ct", "--", str(relpath)],
            capture_output=True,
            text=True,
            check=False,
        )
        if res.returncode == 0 and res.stdout.strip():
            return int(res.stdout.strip())
    except Exception:
        pass
    # fallback: use file mtime
    try:
        return int(os.path.getmtime(repo_dir / relpath))
    except Exception:
        return 0


def find_stale(src_root: Path, cache_root: Path, patterns):
    stale = []
    seen = set()
    for pattern in patterns:
        pattern = pattern.strip()
        if not pattern:
            continue
        for path in src_root.glob(pattern if any(ch in pattern for ch in ["*", "?", "["]) else pattern):
            if path.is_file():
                rel = path.relative_to(src_root)
                if str(rel) in seen:
                    continue
                seen.add(str(rel))
                cache_path = cache_root.joinpath(rel)
                commit_ts = git_last_commit_ts(src_root, rel)
                if not cache_path.exists():
                    stale.append(str(rel))
                    continue
                try:
                    cache_mtime = int(os.path.getmtime(cache_path))
                except Exception:
                    cache_mtime = 0
                if cache_mtime < commit_ts:
                    stale.append(str(rel))
    return stale


def main(argv):
    p = argparse.ArgumentParser()
    p.add_argument("--src", default="./data", help="Source root")
    p.add_argument("--cache", default="./data-cache/cache", help="Cache root")
    p.add_argument("--patterns", default="**/*_dt.xml\n**/*_at.xml", help="newline-separated glob patterns")
    args = p.parse_args(argv)

    src_root = Path(args.src).resolve()
    cache_root = Path(args.cache).resolve()
    # patterns may be passed as a single string with newlines
    patterns = [p for p in args.patterns.splitlines() if p.strip()]

    stale = find_stale(src_root, cache_root, patterns)
    out_file = Path(__file__).parent / "_stale_output.txt"
    # write newline-separated relative paths
    out_file.write_text("\n".join(stale))
    # also print to stdout
    print("\n".join(stale))


if __name__ == "__main__":
    main(sys.argv[1:])
