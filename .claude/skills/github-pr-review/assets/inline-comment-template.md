<!--
Inline review comment rendered by render_review.sh for findings whose lines are inside the PR diff (github-pr-review).
Load ONLY when you need to see how an in-diff finding is posted. The agent writes report JSON; the platform renders this shape and attaches it to path / line / side (and start_line for ranges).
Language: headings, labels, severities, and the closing sentence stay English. Agent-written prose (title, impact) uses the response language: Constraints response_language > language of the PR title/body > English. Quotes, code, and paths stay verbatim.
-->

**#<number> [<Critical | Warning | Suggestion>]** <one-line summary>

- Evidence: [`<evidence-path>#L<start>-L<end>`](https://github.com/<owner>/<repo>/blob/<base-sha>/<evidence-path>#L<start>-L<end>) — "<verbatim quote>"
- Impact: <what happens if left as is>

To request a fix, reply to this comment with `@loop`.

<!--
  GOOD: **#1 [Warning]** Missing nil check on config
        Evidence quote is the exact rule sentence; Impact names the failing input.
  BAD:  **#1 [Warning]** Could be better
        Evidence missing or paraphrased; Impact says "might cause problems".
  A multi-line quote is rendered in a ````text fence under the Evidence item.
  A bug finding renders: - Evidence: <diff line and the concrete input or state that fails>
-->
