"""Run installed proof runtimes and retain actual execution/axiom records."""

import argparse
from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tomllib

ROOT = Path(__file__).resolve().parents[1]
THEOREMS = ('d4_count', 'd4_distinct', 'd4_norms', 'd4_pair_separation',
            'd4_distance_two_witness', 'square_mod_four',
            'no_integer_sum_squares_three', 'sum_squares_two_witness')
ALLOWED_AXIOMS = {'propext', 'Quot.sound'}


def installed_lean():
    binary = 'lean.exe' if os.name == 'nt' else 'lean'
    path = Path.home() / '.elan/toolchains/leanprover--lean4---v4.34.1/bin' / binary
    return str(path) if path.is_file() else None


def run(command, *, timeout=180):
    result = subprocess.run(command, cwd=ROOT, capture_output=True, text=True,
                            encoding='utf-8', errors='replace', timeout=timeout)
    return result.returncode, result.stdout + result.stderr


def parse_axioms(output):
    result = {}
    pattern = (r"'AnaxiaResearch\.(\w+)' (?:does not depend on any axioms"
               r'|depends on axioms: \[([^\]]*)\])')
    for match in re.finditer(pattern, output):
        result[match.group(1)] = [item.strip() for item in (match.group(2) or '').split(',') if item.strip()]
    return result


def source_audit(source):
    # Lean's actual kernel check and printed dependencies provide the trust gate.
    # This extra source check catches accidental proof placeholders early.
    code = re.sub(r'/\-.*?\-/', '', source, flags=re.S)
    code = re.sub(r'--[^\n]*', '', code)
    forbidden = re.findall(r'\b(?:sorry|admit|unsafe|axiom|native_decide)\b', code)
    if forbidden:
        raise ValueError('Lean source contains a forbidden placeholder or trust extension')


def validate(lean_binary, julia_binary=None):
    reports = ROOT / 'reports'
    reports.mkdir(exist_ok=True)
    lean_path = ROOT / 'lean/Certificates.lean'
    julia_path = ROOT / 'julia/verify.jl'
    source_audit(lean_path.read_text(encoding='utf-8'))
    result = {'schema_version': 1, 'checked_at_utc': datetime.now(timezone.utc).isoformat(),
              'global_new_conjecture_closures': 0,
              'sources': {str(path.relative_to(ROOT)).replace('\\', '/'):
                          hashlib.sha256(path.read_bytes()).hexdigest()
                          for path in (lean_path, julia_path)},
              'lean': {'status': 'not_run'}, 'julia': {'status': 'runtime_unavailable'}}
    if not lean_binary:
        raise ValueError('Provide an installed Lean 4.34.1 executable; this validator does not install runtimes')
    code, version = run([lean_binary, '--version'])
    if code or 'version 4.34.1' not in version:
        raise ValueError('Installed Lean runtime must report version 4.34.1')
    code, output = run([lean_binary, 'lean/Certificates.lean'])
    (reports / 'lean-verification.txt').write_text(output, encoding='utf-8', newline='\n')
    axioms = parse_axioms(output)
    passed = (code == 0 and set(axioms) == set(THEOREMS)
              and all(set(items) <= ALLOWED_AXIOMS for items in axioms.values()))
    result['lean'] = {'status': 'passed' if passed else 'failed', 'runtime': version.strip(),
                      'exit_code': code, 'checked_theorems': len(axioms), 'axiom_dependencies': axioms,
                      'new_axioms_declared': False, 'mathlib_required': False}
    if julia_binary:
        code, output = run([julia_binary, '--startup-file=no', 'julia/verify.jl',
                            '--output', 'reports/julia-verification.toml'])
        (reports / 'julia-verification.txt').write_text(output, encoding='utf-8', newline='\n')
        report_path = reports / 'julia-verification.toml'
        details = tomllib.loads(report_path.read_text(encoding='utf-8')) if code == 0 and report_path.exists() else {}
        julia_passed = code == 0 and details.get('all_assertions_passed') is True
        result['julia'] = {'status': 'passed' if julia_passed else 'failed', 'exit_code': code,
                           'runtime': details.get('runtime'), 'test_assertions': details.get('test_assertions')}
    result['status'] = 'passed' if result['lean']['status'] == 'passed' and result['julia']['status'] == 'passed' else 'partial' if passed and not julia_binary else 'failed'
    (reports / 'validation.json').write_text(json.dumps(result, indent=2) + '\n', encoding='utf-8', newline='\n')
    return result


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--lean', default=installed_lean())
    parser.add_argument('--julia', default=shutil.which('julia'))
    parser.add_argument('--require-julia', action='store_true')
    args = parser.parse_args(argv)
    try:
        result = validate(args.lean, args.julia)
        print(json.dumps(result, indent=2))
        return 0 if result['status'] == 'passed' or (result['status'] == 'partial' and not args.require_julia) else 2
    except (ValueError, OSError, subprocess.TimeoutExpired) as error:
        print(f'Validation error: {error}', file=sys.stderr)
        return 2


if __name__ == '__main__':
    raise SystemExit(main())
