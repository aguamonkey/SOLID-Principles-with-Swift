# Interview · extension and compatibility

[Advanced lesson](README.md) · [Separate answer notes](INTERVIEW_NOTES.md)

Explain the constraint and alternative before naming a SOLID principle. Use a production example from your own experience when possible.

1. Where is this importer closed to modification?

2. When would you replace this registry with a switch?

3. Why dispatch on both type and version?

4. Why reject duplicate registration?

5. Why does the lab compose a new registry when toggled?

6. Does Sendable prove the extension is correct?

7. How is an unsupported record different from a rejected one?

8. Why can one invalid payload leave other rows readable?

9. Why does a failed payload still reserve its UUID?

10. Is row index a stable domain ID?

11. What happens if an extension throws or returns empty facts?

12. Can adding fields break compatibility?

13. How would you retain unknown payloads for a later app update?

14. How would you roll this into a production app?

15. What would make you change the fact projection?
