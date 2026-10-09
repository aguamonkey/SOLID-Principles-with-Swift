# Interview practice · Reason about the refresh lab

[Back to the lab](README.md) · [Learning progression](../../docs/LEARNING_PATH.md)

Answer these without opening the decision record or answer notes. Use the running app and source to support your explanation. There is no single required architecture; a good answer defines assumptions, considers alternatives, and connects a choice to evidence.

## Explain the progression

1. Explain dependency inversion in the patchboard using an actual caller and contract. How is it different from dependency injection?
2. The advanced example has fewer forwarding layers. Why can that still demonstrate stronger engineering judgment?
3. What user-visible requirement makes a retained cache useful here? When would you keep only a payload in the view model instead?

## Investigate a bug

4. Two refreshes start for the same URL. The second completes first. Why is an actor alone insufficient to prevent the first from overwriting it? Walk through the suspension points.
5. Cancelled transport returns a successful response anyway. Which checks protect the cache, and which protect the UI?
6. The newer refresh fails while the older succeeds. Should the older result be accepted? Give two defensible policies and explain which this lab implements.
7. A SwiftUI view is reconstructed while its state object survives. What goes wrong if its concrete adapter is recreated independently?

## Change a constraint

8. Two screens should share one in-flight HTTP request. Who owns cancellation when one screen disappears? Sketch the change before proposing code.
9. A user switches accounts. What must change about cache keys, visibility, in-flight work and invalidation?
10. Product asks for persistent saved content and five-minute freshness. Separate the product policy from storage and transport concerns.
11. The server sometimes returns an older version. Does latest-issued request identity solve that? What additional contract is needed?

## Operate and migrate

12. What would you log to investigate slow refreshes while avoiding sensitive data? What do the current events fail to tell you?
13. How would you introduce this behaviour into a shipped app and detect whether it made the experience worse?
14. Which tests should remain deterministic unit tests, and what would require HTTP integration or device-level evidence?
15. A teammate proposes a disk cache and another use-case layer. How would you evaluate that proposal together before expanding the scope?

## Review your explanation

| Dimension | Evidence of a useful answer |
| --- | --- |
| Contract | States outcomes on success, failure, cancellation and stale completion |
| Ownership | Identifies the task owner, dependency lifetime and cache scope |
| Alternatives | Explains a simpler option and the requirement that changes the choice |
| Evidence | Points to a test that would fail with the proposed bug |
| Migration | Preserves existing behaviour while introducing the new path deliberately |
| Communication | Makes assumptions explicit and responds constructively to a challenge |

Use this as a self-review, not a score claiming you qualify for a job title. Practise connecting the discussion to real responsibilities from your previous work.

When ready, compare with the [answer notes](INTERVIEW_NOTES.md).
