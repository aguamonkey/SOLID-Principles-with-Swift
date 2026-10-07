#!/usr/bin/env python3
"""Run the same focused Swift suites locally and in GitHub Actions."""
import argparse
from datetime import datetime
import json
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
LESSONS = json.loads((ROOT / "scripts/lessons.json").read_text())


def select_simulator(devices, name, ios):
    runtime = f"com.apple.CoreSimulator.SimRuntime.iOS-{ios.replace('.', '-')}"
    matches = [d for d in devices.get(runtime, [])
               if d.get("isAvailable") and d["name"] == name]
    if not matches:
        raise ValueError(f"No available {name} with iOS {ios}. Install the runtime in Xcode or use --simulator-id.")
    return next((d["udid"] for d in matches if d["state"] == "Booted"), matches[0]["udid"])


def validate_result(summary):
    if summary.get("totalTestCount", 0) == 0 or summary.get("passedTests", 0) == 0:
        raise ValueError("No tests passed. Check the target/class names in scripts/lessons.json.")
    if summary.get("failedTests", 0) or summary.get("result") != "Passed":
        raise ValueError("Xcode's result bundle does not report a passing test run.")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("lesson", choices=["all", *LESSONS])
    parser.add_argument("--suite", choices=["all", "unit", "ui"], default="all")
    parser.add_argument("--simulator-id", help="Use an existing simulator UUID instead of name/runtime lookup")
    parser.add_argument("--device", default="iPhone 17")
    parser.add_argument("--ios", default="26.2")
    args = parser.parse_args()
    try:
        simulator = args.simulator_id
        if not simulator:
            inventory = subprocess.check_output(["xcrun", "simctl", "list", "devices", "available", "--json"], text=True)
            simulator = select_simulator(json.loads(inventory)["devices"], args.device, args.ios)
        subprocess.run(["xcrun", "simctl", "boot", simulator], check=False, capture_output=True)
        subprocess.run(["xcrun", "simctl", "bootstatus", simulator, "-b"], check=True)
        stamp = datetime.now().strftime("%Y%m%d-%H%M%S-%f")
        output = ROOT / ".test-results" / stamp
        output.mkdir(parents=True)
        lessons = LESSONS if args.lesson == "all" else {args.lesson: LESSONS[args.lesson]}
        failed = []
        for key, lesson in lessons.items():
            result = output / f"{key}.xcresult"
            log = output / f"{key}.log"
            command = ["xcodebuild", "test", "-project", lesson["project"], "-scheme", lesson["scheme"],
                       "-destination", f"platform=iOS Simulator,id={simulator}",
                       "-derivedDataPath", str(ROOT / ".test-results" / "DerivedData" / key),
                       "-resultBundlePath", str(result), "-parallel-testing-enabled", "NO", "CODE_SIGNING_ALLOWED=NO"]
            suites = ("unit", "ui") if args.suite == "all" else (args.suite,)
            command.extend(f"-only-testing:{lesson[suite]}" for suite in suites)
            print(f"Running {key.upper()} ({args.suite}) on {simulator}…", flush=True)
            with log.open("w") as stream:
                completed = subprocess.run(command, cwd=ROOT, stdout=stream, stderr=subprocess.STDOUT)
            passed = completed.returncode == 0
            if passed:
                try:
                    summary = json.loads(subprocess.check_output(
                        ["xcrun", "xcresulttool", "get", "test-results", "summary", "--path", str(result)], text=True))
                    validate_result(summary)
                    print(f"{summary['passedTests']} tests passed", flush=True)
                except (OSError, ValueError, subprocess.CalledProcessError) as error:
                    passed = False
                    print(f"Result verification failed: {error}", flush=True)
            print(f"{'PASS' if passed else 'FAIL'} {key.upper()} — {result}", flush=True)
            if not passed:
                failed.append(key)
                print("\n".join(log.read_text(errors="replace").splitlines()[-60:]), flush=True)
        print(f"Logs and result bundles: {output}", flush=True)
        return bool(failed)
    except (OSError, ValueError, subprocess.CalledProcessError) as error:
        print(f"Cannot run tests: {error}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
