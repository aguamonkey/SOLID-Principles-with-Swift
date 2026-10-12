# Interview · responsibility and change ownership

[Advanced lesson](README.md) · [Separate answer notes](INTERVIEW_NOTES.md)

Explain the concrete request, affected owner and protected behaviour. Then challenge one assumption using your own production experience.

1. What is the reason to change each boundary?

2. Why is a model with refresh, failure and cancellation still cohesive?

3. Why move wording out of the domain model here?

4. Why validate before either consumer projects?

5. Does one shared edition remove all coupling?

6. Why do the previews avoid independent fetches?

7. What proves a wording change leaves export intact?

8. Why is the export DTO separate from GuideFigure?

9. Is sorted JSON a canonical format?

10. What should happen when refresh fails?

11. What prevents an older request from publishing?

12. Why not create formatter protocols now?

13. How would localisation change this design?

14. How would you add file sharing?

15. How would you introduce these boundaries into a shipping app?
