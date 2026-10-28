<!--
Review body rendered by render_review.sh from the report JSON (github-pr-review).
Load ONLY when you need to see how the report becomes the posted review body. The agent does not write this file's output directly; it writes the report JSON and the platform renders this shape.
Language: headings, labels, severities, fixed phrases, and the marker stay English. Agent-written prose (summary, titles, impact, premises) uses the response language: Constraints response_language > language of the PR title/body > English. Quotes, code, and paths stay verbatim.
-->

<!-- github-pr-review:v1 -->

## Code review

Findings: <N> (Critical: <a> / Warning: <b> / Suggestion: <c>)

<!--
  Only when findings were dropped for unverifiable evidence, a paragraph follows:
  Dropped: <k> (evidence could not be verified)
  Only when more than 20 findings remain, the most severe 20 are posted and a paragraph follows:
  Omitted: <m> (over the limit of 20 findings)
-->

<summary: what the PR does and the overall assessment; say explicitly when there are no findings>

<!--
  GOOD: Adds retry handling to the uploader. One rule violation and one boundary bug found; the rest follows the repository rules.
  BAD:  Looks good overall, some issues.
-->

### Premises checked

- PR body: <what the body states, or none>
- Linked Issue / spec: <#number or path, or none>

<!--
  GOOD: PR body: retry failed uploads up to 3 times. Linked Issue / spec: #120
  BAD:  PR body: ok. Linked Issue / spec: n/a
-->

### Findings

<!--
  The "### Findings" heading is omitted when there are zero findings.
  In-diff findings (inline) appear as one line; the detail is in the inline comment.
-->

1. **[Critical]** <one-line summary> — inline: [`<path>#L<start>-L<end>`](https://github.com/<owner>/<repo>/pull/<n>/files)
2. **[Warning]** <one-line summary for a finding outside the diff>
   - Evidence: [`<evidence-path>#L<start>-L<end>`](https://github.com/<owner>/<repo>/blob/<base-sha>/<evidence-path>#L<start>-L<end>) — "<verbatim quote>"
   - Location: https://github.com/<owner>/<repo>/blob/<head-sha>/<path>#L<start>-L<end>
   - Impact: <what happens if left as is>

<!--
  Multi-line quotes use a fenced block, indented under the item:
     - Evidence: [`<evidence-path>#L<start>-L<end>`](...) —
       ````text
       <verbatim multi-line quote>
       ````
  A bug finding has no evidence link; its evidence line is:
     - Evidence: <diff line and the concrete input or state that fails>
  GOOD: Evidence quote copied exactly from the base file; Location uses the head SHA.
  BAD:  Evidence paraphrased, or linking a branch name instead of a SHA.
-->
