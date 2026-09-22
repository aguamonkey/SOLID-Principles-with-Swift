# Running the examples

[Back to the learning path](../README.md)

## Requirements

Use Xcode with an installed iOS Simulator runtime. The projects use Swift 5 language mode; the compiler bundled with Xcode may have a newer version number. Some source files use `#Preview`, so use Xcode 15 or later, with an SDK that supports the selected target.

The DIP project targets iOS 17.2. The OCP, LSP, and ISP projects target iOS 16.2. The SRP app target specifies iOS 15.4, while its unit test target specifies iOS 16.2. These are project settings, not a claim that every older Xcode release has been verified.

## Verified environment

On 22 September 2026, Galactic Explorer built and all seven OCP unit tests plus both atlas UI tests passed using Xcode 26.2 and an iPhone 17 simulator running iOS 26.2. The UI checks cover selection/cycling and the largest accessibility text size. The README screenshot is captured from that running app. Other apps and the separate launch-test suite were not rerun in this change.

## Open and run

1. Choose a lesson from the [main README](../README.md) and open the `.xcodeproj` named in its **Run the app** section.
2. Select the app scheme and an installed iPhone simulator compatible with its deployment target.
3. Press **Cmd+R** to run. A simulator run does not require an Apple Developer account.
4. Press **Cmd+U** to execute the scheme's tests. The lesson links to the unit tests worth reading first.

The OCP app loads bundled JSON. The DIP app currently points at a placeholder network endpoint; follow its lesson's mock-based test route for a deterministic success example.

## Build test bundles from Terminal

Run these commands from the repository root. **`build-for-testing` compiles the app and test bundles; it does not execute the tests.** Each project gets a separate temporary build directory.

```sh
xcodebuild build-for-testing -project "SRPExample- Angels and Demons/SRP-Example-Angels-and-Demons/SRP-Example-Angels-and-Demons.xcodeproj" -scheme "SRP-Example-Angels-and-Demons" -destination "generic/platform=iOS Simulator" -derivedDataPath /tmp/solid-srp-dd CODE_SIGNING_ALLOWED=NO
xcodebuild build-for-testing -project "Open-Closed-Principle-(OCP)-Galactic-Explorer/Open-Closed-Principle-(OCP)-Galactic-Explorer.xcodeproj" -scheme "Open-Closed-Principle-(OCP)-Galactic-Explorer" -destination "generic/platform=iOS Simulator" -derivedDataPath /tmp/solid-ocp-dd CODE_SIGNING_ALLOWED=NO
xcodebuild build-for-testing -project "LSPExample/LSPExample.xcodeproj" -scheme "LSPExample" -destination "generic/platform=iOS Simulator" -derivedDataPath /tmp/solid-lsp-dd CODE_SIGNING_ALLOWED=NO
xcodebuild build-for-testing -project "EcoShop Backend ISP/EcoShop Backend ISP.xcodeproj" -scheme "EcoShop Backend ISP" -destination "generic/platform=iOS Simulator" -derivedDataPath /tmp/solid-isp-dd CODE_SIGNING_ALLOWED=NO
xcodebuild build-for-testing -project "ModularNetworkServiceExample/ModularNetworkServiceExample.xcodeproj" -scheme "ModularNetworkServiceExample" -destination "generic/platform=iOS Simulator" -derivedDataPath /tmp/solid-dip-dd CODE_SIGNING_ALLOWED=NO
```

## Execute tests from Terminal

For example, list the available OCP destinations:

```sh
xcodebuild -showdestinations -project "Open-Closed-Principle-(OCP)-Galactic-Explorer/Open-Closed-Principle-(OCP)-Galactic-Explorer.xcodeproj" -scheme "Open-Closed-Principle-(OCP)-Galactic-Explorer"
```

Copy an available iOS Simulator ID into the command below, replacing `SIMULATOR_ID`:

```sh
xcodebuild test \
  -project "Open-Closed-Principle-(OCP)-Galactic-Explorer/Open-Closed-Principle-(OCP)-Galactic-Explorer.xcodeproj" \
  -scheme "Open-Closed-Principle-(OCP)-Galactic-Explorer" \
  -destination 'platform=iOS Simulator,id=SIMULATOR_ID' \
  -derivedDataPath /tmp/solid-ocp-dd \
  -only-testing:'Open-Closed-Principle-(OCP)-Galactic-ExplorerTests' \
  CODE_SIGNING_ALLOWED=NO
```

This command runs the seven OCP unit tests. Omit `-only-testing` to include the scheme's UI tests as well. Use the corresponding project, scheme, and test target for the other lessons. `generic/platform=iOS Simulator` is a build destination, not a device on which tests can execute.

## If setup fails

- **No compatible destination:** install a suitable iOS runtime in Xcode Settings and select an available simulator.
- **Scheme missing:** open the project in Xcode and check Product → Scheme → Manage Schemes. For automation, share the app scheme and commit its scheme file.
- **Network demo fails:** its default endpoint is illustrative. Use the injected mocks described in the DIP lesson.
- **Tests build but no results appear:** use **Cmd+U** or `xcodebuild test`, rather than `build-for-testing`.
