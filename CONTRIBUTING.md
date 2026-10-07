# Contributing

[Back to the learning path](README.md)

Aim for a change a learner can explain: what needs to vary, which boundary handles it, and why that boundary is worth its cost. Keep each app small enough to study in one sitting.

## Change a lesson

1. Create a descriptive branch from `develop`, such as `feature/clearer-ocp-exercise`.
2. Make a focused change. Keep principle-specific behaviour separate from visual styling.
3. Update the app README's explanation, source route, exercise, and solution when they are affected. Link it from the root README if adding a lesson.
4. Run the [documentation checks](docs/SETUP.md#documentation-checks) and the affected [lesson tests](docs/SETUP.md#execute-tests-from-terminal). Run all five lessons when changing shared verification tooling.
5. Open a pull request against `develop`. Explain the concrete behaviour change, checks run, and any checks you could not run. Wait for the relevant GitHub checks before merging.

For behavioural changes, add a test that would fail without the fix or extension. Avoid tests that merely repeat the implementation. In protocol examples, demonstrate what a consumer can rely on, not just that a type conforms.

## Update screenshots

Capture the actual app in the simulator, using consistent device framing and readable text. Save PNGs under `docs/images/`, link to them from the lesson, and update the root gallery when its representative screen changes. Keep useful alternative states in the lesson rather than expanding the main gallery indefinitely.

Follow the [design boundaries and screenshot criteria](docs/DESIGN.md). Check large accessibility text and dark appearance when changing layout or colour. State whether those checks were automated or visual.

## Improve study material

Use concrete Swift examples and clickable source links. Keep solutions separate from exercises so learners can try a change first. Explain the tradeoff as well as the benefit, and distinguish an illustrative snippet from code that currently runs in the app.

Documentation-only changes need the documentation checks. They do not require rerunning app suites unless they change executable instructions or expected behaviour.
