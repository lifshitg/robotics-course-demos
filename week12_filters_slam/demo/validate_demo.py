"""Run all regression tests and record current-runtime evidence without a GUI."""
import io
import json
from pathlib import Path
import platform
import time
import unittest
import numpy as np
import matplotlib


def main():
    demo = Path(__file__).resolve().parent
    output = demo.parent / 'slides' / 'demo_validation'
    output.mkdir(parents=True, exist_ok=True)
    suite = unittest.defaultTestLoader.discover(str(demo), pattern='test_*.py')
    stream = io.StringIO()
    begin = time.perf_counter()
    result = unittest.TextTestRunner(stream=stream, verbosity=2).run(suite)
    log = stream.getvalue()
    print(log)
    (output / 'tests.txt').write_text(log, encoding='utf-8')
    record = dict(tests_run=result.testsRun, failures=len(result.failures), errors=len(result.errors),
                  successful=result.wasSuccessful(), elapsed_seconds=time.perf_counter()-begin,
                  python=platform.python_version(), numpy=np.__version__, matplotlib=matplotlib.__version__,
                  pinned_environment=False, interactive_classroom_rehearsal=False)
    (output / 'tests.json').write_text(json.dumps(record, indent=2)+'\n', encoding='utf-8')
    raise SystemExit(0 if result.wasSuccessful() else 1)


if __name__ == '__main__':
    main()
