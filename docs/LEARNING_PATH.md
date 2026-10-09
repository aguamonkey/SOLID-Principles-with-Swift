# From principles to engineering judgment

[All lessons](../README.md)

Use the five SOLID apps to practise explaining a design, owning a feature, and making decisions under competing requirements. These stages describe the scope of an exercise. They are not a hiring rubric or a rule that more abstractions mean a more senior engineer.

| Stage | Scope of thinking | Evidence to produce |
| --- | --- | --- |
| Foundation | Explain a boundary and replace one implementation | A source walkthrough and a small extension |
| Feature ownership | Make the feature reliable for its users | Failure/recovery behaviour, cancellation, accessible UI, behavioural tests |
| System ownership | Define contracts, lifetimes, and migration under constraints | Alternatives, an explicit decision, cross-consumer invariants, and a rollout plan |

The existing apps already include feature-ownership work. The advanced track makes the next change pressure explicit rather than labelling the original code “junior”. Choosing a simpler solution can demonstrate stronger judgment.

## First progression: Dependency Inversion

1. **Explain the boundary:** study the [patchboard lesson](../ModularNetworkServiceExample/README.md#after-accept-dependencies-through-abstractions). Replace its repository without rewriting the receiver.
2. **Own its behaviour:** inspect the [failure and cancellation tests](../ModularNetworkServiceExample/README.md#read-and-run-the-tests). Explain how an older request can finish after cancellation.
3. **Protect a shared invariant:** open the [advanced refresh lab](../ModularNetworkServiceExample/Advanced/README.md). Saved content remains readable while refresh runs; obsolete work must not overwrite either the screen or shared cache.
4. **Make a new decision:** attempt the [freshness exercise](../ModularNetworkServiceExample/Advanced/EXERCISE.md) before reading its solution.
5. **Practise the interview:** answer the [discussion prompts](../ModularNetworkServiceExample/Advanced/INTERVIEW.md), then compare with the separate answer notes.

## How to study a transition

Write down the behaviour before editing code. Include what happens on failure and cancellation, who owns the work, and when an earlier result becomes invalid. Sketch the smallest design that satisfies that contract and identify one alternative you would reject. Run a test that demonstrates the failure your change prevents.

After implementing the change, explain which decision belongs to the product, which belongs to a consumer, and which belongs to infrastructure. Connect it to a real project you have worked on where possible. For interview preparation, practise the explanation without reading the README, then ask someone to challenge an assumption.

## Track availability

| Lesson | Existing study material | Advanced progression |
| --- | --- | --- |
| [SRP](../SRPExample-%20Angels%20and%20Demons/README.md) | Responsibility boundaries, loading/recovery, field-guide UI | Future scenario: multiple consumers and change ownership |
| [OCP](../Open-Closed-Principle-%28OCP%29-Galactic-Explorer/README.md) | Registry extension, decoding, atlas selection | Future scenario: evolving extension contracts |
| [LSP](../LSPExample/README.md) | Behavioural contracts and rehearsal interactions | Future scenario: async errors and cancellation contracts |
| [ISP](../EcoShop%20Backend%20ISP/README.md) | Read-only consumers and catalog mutations | Future scenario: consumers evolving independently |
| [DIP](../ModularNetworkServiceExample/README.md) | Explicit composition, failures, overlapping requests | **Available:** cached content, reentrancy, request ordering, diagnostics, and a migration decision |

Only the DIP advanced progression is implemented. Its structure is the template for future lessons: scenario → contract → alternatives → implementation → evidence → exercise → interview discussion.

## Self-review

You are ready to move beyond an exercise when you can:

- Explain the user-visible rule and test it without quoting a definition of SOLID.
- Show where concrete dependencies are assembled and how long they live.
- Demonstrate what happens when work completes in an unexpected order.
- Defend a simpler alternative and identify a requirement that would change your choice.
- Explain how you would introduce the change into an existing app, including how to detect a regression.

A repository can provide practice and evidence. Interview readiness also depends on your production experience, communication, and your ability to adapt when the constraints change.
