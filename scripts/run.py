import glob
import os
import re
import subprocess
import sys
from concurrent.futures import ThreadPoolExecutor

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
os.chdir(ROOT)

RTL_FILES = sorted(glob.glob("rtl/imul/*.v") + glob.glob("rtl/proc/*.v"))
TIMEOUT = 60  # seconds per simulation
JOBS = os.cpu_count() or 4

UNIT_TESTS = sorted(
    glob.glob("tb/tb_isa/*_tb.v") +
    glob.glob("tb/tb_hz/*_tb.v") +
    glob.glob("tb/tb_imul/*_tb.v") +
    glob.glob("tb/tb_bp/*_tb.v")
)

BP_BENCHES = [
    ("bp_bubblesort", ["-DBENCH_BUBBLESORT"]),
    ("bp_binsearch",  ["-DBENCH_BINSEARCH"]),
    ("bp_sieve",      ["-DBENCH_SIEVE"]),
]

IMUL_BENCHES = [
    ("imul_matmul_w8",  ["-DBENCH_MATMUL_W8"]),
    ("imul_matmul_w16", ["-DBENCH_MATMUL_W16"]),
    ("imul_matmul_w32", ["-DBENCH_MATMUL_W32"]),
]

FAIL_RE = re.compile(r"\b(FAIL(ED)?|FATAL|ERROR)\b", re.I)
PASS_RE = re.compile(r"\bPASS(ED)?\b", re.I)


def has_code(path):
    """False if file is missing, empty, or only comments/whitespace."""
    if not os.path.isfile(path):
        return False
    txt = open(path, errors="ignore").read()
    txt = re.sub(r"/\*.*?\*/", "", txt, flags=re.S)
    txt = re.sub(r"//.*", "", txt)
    return "module" in txt


def run_sim(name, tb_file, defines=(), show=None):
    """Returns (label, passed, log_text). Safe to run in parallel."""
    label = show or f"{tb_file} {' '.join(defines)}".strip()
    if not has_code(tb_file):
        return label, False, f"[SKIP/EMPTY] {tb_file} is missing or has no module."

    os.makedirs("build", exist_ok=True)
    out_bin = os.path.join("build", name + ".out")

    cmd = ["iverilog", "-g2012", "-o", out_bin, *defines, *RTL_FILES, tb_file]
    comp = subprocess.run(cmd, capture_output=True, text=True)
    if comp.returncode != 0:
        return label, False, f"[COMPILE ERROR]\n{comp.stderr}"

    try:
        sim = subprocess.run(["vvp", out_bin], capture_output=True,
                             text=True, timeout=TIMEOUT)
    except subprocess.TimeoutExpired:
        return label, False, f"[TIMEOUT] >{TIMEOUT}s (missing $finish or infinite loop?)"

    out = (sim.stdout or "") + (sim.stderr or "")
    if sim.returncode != 0:
        return label, False, (f"[VVP EXIT {sim.returncode}] vvp crashed. "
                              f"On Windows, run from the OSS CAD Suite shell "
                              f"(environment.bat).\n{out}")
    if not out.strip():
        return label, False, "[EMPTY OUTPUT] testbench printed nothing."

    log = "\n".join(l for l in out.splitlines() if not l.startswith("WARNING:"))
    passed = bool(PASS_RE.search(out)) and not FAIL_RE.search(out)
    return label, passed, log


def run_many(jobs, show_log=False):
    """jobs: list of (name, tb_file, defines, show).
    Runs in parallel, prints results in job order. True if all passed."""
    with ThreadPoolExecutor(max_workers=JOBS) as ex:
        futs = [ex.submit(run_sim, *j) for j in jobs]
        results = [f.result() for f in futs]   # keeps list order

    ok_count = 0
    for label, passed, log in results:
        print(f"[{'PASS' if passed else 'FAIL'}] {label}", flush=True)
        if not passed or show_log:
            print(log, flush=True)
        ok_count += passed

    print(f"\n{ok_count}/{len(jobs)} passed.\n", flush=True)
    return ok_count == len(jobs)


def run_unit():
    jobs = []
    for i, t in enumerate(UNIT_TESTS):
        t = t.replace("\\", "/")
        name = f"{os.path.splitext(os.path.basename(t))[0]}_{i}"
        jobs.append((name, t, (), t))
    return run_many(jobs)


def run_bp():
    return run_many([(n, "tb/tb_bench_bp.v", d, n) for n, d in BP_BENCHES],
                    show_log=True)


def run_imul():
    return run_many([(n, "tb/tb_bench_imul.v", d, n) for n, d in IMUL_BENCHES],
                    show_log=True)


def main():
    mode = sys.argv[1].lower() if len(sys.argv) > 1 else "all"
    modes = {
        "unit": [run_unit], "bp": [run_bp], "imul": [run_imul],
        "bench": [run_bp, run_imul],
        "all": [run_unit, run_bp, run_imul],
    }
    if mode not in modes:
        print("Usage: python scripts/run.py [unit | bp | imul | bench | all]")
        sys.exit(1)

    ok = True
    for fn in modes[mode]:
        ok = fn() and ok   # keep going so you see all failures
    sys.exit(0 if ok else 1)


if __name__ == "__main__":
    main()