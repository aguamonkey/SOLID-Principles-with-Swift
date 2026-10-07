# Running the examples

[Back to the learning path](../README.md)

## Requirements

Use Xcode with an installed iOS Simulator runtime. The projects use Swift 5 language mode; the compiler bundled with Xcode may have a newer version number. Some source files use `#Preview`, so use Xcode 15 or later, with an SDK that supports the selected target.

The DIP project targets iOS 17.2. The OCP, LSP, and ISP projects target iOS 16.2. The SRP app and its tests target iOS 16.2. These are project settings, not a claim that every older Xcode release has been verified.

## Verified environment

Verified with Xcode 26.2 and an iPhone 17 simulator running iOS 26.2 on 22 September 2026:

- **Galactic Explorer:** seven unit tests and two atlas UI tests passed.
- **Orchestra:** nine unit tests and three rehearsal UI tests passed. The two affected UI cases were rerun after the final layout refinements and passed again.
- **EcoShop:** thirteen unit tests and five ledger UI tests passed, including catalog refresh, add/edit/remove, empty shelves, and accessibility text. The Goods screen was also visually checked in simulator dark mode.

The UI checks cover app interactions and the largest accessibility text size. README screenshots come from the actual running apps. The separate template launch-test suites were not rerun in these changes.

Network Service was verified on 6 October 2026 with the same Xcode and simulator versions: ten unit tests and four patchboard UI tests passed. The UI cases were rerun after the layout refinement. Dark appearance was also visually checked. These checks use offline inputs and do not validate a live HTTP endpoint.

Angels and Demons was verified on 6 October 2026 with Xcode 26.2 and iOS 26.2: eleven unit tests and three field-guide UI tests passed. The collection/selection case was rerun for the final screenshots. Dark appearance was visually checked.

The repository-wide verification command was run on 6 and 7 October 2026 with Xcode 26.2 and iPhone 17 / iOS 26.2: all 50 unit and 17 focused UI tests passed. The documentation checker and its regression tests also passed locally. This records local verification; hosted GitHub Actions results are reported separately by the workflow.

## Open and run

1. Choose a lesson from the [main README](../README.md) and open the `.xcodeproj` named in its **Run the app** section.
2. Select the app scheme and an installed iPhone simulator compatible with its deployment target.
3. Press **Cmd+R** to run. A simulator run does not require an Apple Developer account.
4. Press **Cmd+U** to execute the scheme's tests. The lesson links to the unit tests worth reading first.

The OCP app loads bundled JSON. The DIP app uses local sample, delayed, and failure inputs, so its demo and tests work without a live endpoint.

## Execute tests from Terminal

Run these commands from the repository root with Python 3.9 or later and full Xcode 16 or later selected (the result summary command requires Xcode 16+). The runner uses the shared schemes in [lessons.json](../scripts/lessons.json), executes each selected lesson sequentially, and returns a failing exit code if any lesson fails or its result bundle contains no passing tests.

```sh
# All five lessons: focused unit and UI suites
python3 scripts/test_lessons.py all

# One lesson, or a faster unit-only pass
python3 scripts/test_lessons.py ocp
python3 scripts/test_lessons.py dip --suite unit
```

Lesson IDs are `srp`, `ocp`, `lsp`, `isp`, and `dip`. The default destination is **iPhone 17 / iOS 26.2**. To use another installed simulator:

```sh
python3 scripts/test_lessons.py srp --device "iPhone 16e" --ios 18.6
xcrun simctl list devices available
python3 scripts/test_lessons.py all --simulator-id SIMULATOR_ID
```

Replace `SIMULATOR_ID` with an available device UUID. Its runtime must meet the lesson's deployment target. The runner boots that simulator and waits for it to be ready. It disables signing and parallel test execution, keeps build caches per lesson, and writes timestamped logs and `.xcresult` bundles under the ignored `.test-results/` directory. Open a result bundle in Xcode to inspect failures and UI attachments.

`--suite ui` runs only the lesson's interaction suite. The automation excludes the separate generated launch/performance test classes. **Cmd+U** uses the full scheme selection and can include those templates.

For a raw Xcode command, for example:

```sh
xcodebuild test \
  -project LSPExample/LSPExample.xcodeproj \
  -scheme LSPExample \
  -destination 'platform=iOS Simulator,id=SIMULATOR_ID' \
  -derivedDataPath /tmp/solid-lsp-dd \
  -only-testing:LSPExampleTests \
  -only-testing:LSPExampleUITests/LSPExampleUITests \
  CODE_SIGNING_ALLOWED=NO
```

`xcodebuild build-for-testing` compiles the app and test bundles without executing tests. A `generic/platform=iOS Simulator` destination can build bundles, but cannot execute them.

## Documentation checks

No Xcode or third-party Python packages are needed:

```sh
python3 scripts/check_docs.py
PYTHONPATH=scripts python3 -m unittest discover -s scripts/tests -v
```

The checker validates local inline Markdown links, HTML image/link paths, and Markdown heading fragments, including percent-encoded paths. Fenced code examples are ignored. Use inline links for lesson navigation; reference-style links and external URL availability are outside this check's scope.

## GitHub Actions

[Repository checks](../.github/workflows/quality.yml) runs on pushes to `develop` and `feature/**`, pull requests targeting `develop`, and manual dispatch. One Linux job checks documentation and verification tooling. Five independent macOS jobs run the same focused app suites; a failure in one lesson does not cancel the others. Logs and result bundles are uploaded for seven days, including on test failure.

The workflow selects **macos-26**, **Xcode 26.2**, and **iPhone 17 / iOS 26.2** explicitly. GitHub's [runner image inventory](https://github.com/actions/runner-images/blob/main/images/macos/macos-26-arm64-Readme.md) lists the installed toolchains and runtimes. Runner images change over time; if a pinned toolchain is removed, update the workflow and reverify all five lessons before changing the documented environment.

## If setup fails

- **No compatible destination:** install a suitable iOS runtime in Xcode Settings and select an available simulator.
- **Scheme missing:** open the project in Xcode and check Product → Scheme → Manage Schemes. For automation, share the app scheme and commit its scheme file.
- **Network demo shows “NO SIGNAL”:** the Offline input deliberately fails. Select Sample and connect again.
- **Tests build but no results appear:** use **Cmd+U** or `xcodebuild test`, rather than `build-for-testing`.
