# Project rules

## Read-only by default

Do not create, edit, delete, or otherwise modify any file in this
repository (code, config, docs, generated artifacts, etc.) unless the
user has explicitly asked for that change in the current conversation.

This applies even when a fix, refactor, or cleanup seems obvious or
low-risk. Default to investigation and explanation only:

- Reading files, running read-only shell commands (e.g. `ls`, `grep`,
  `zig build-exe` for compilation checks, running the program) is fine.
- Proposing a diff, patch, or code snippet in your reply is fine.
- Actually writing that change to disk (via file-edit/write tools or
  shell redirection/`sed -i`/etc.) is NOT fine until the user says
  something like "make that change", "apply it", "go ahead", "fix it",
  or similarly requests the edit be performed.

If you're unsure whether the user is asking for an explanation/analysis
versus asking for the change to be applied, ask for clarification
before touching any files.

## Code comments

Keep comments minimal. A comment should explain something a reader
cannot get from the code itself: why a choice was made, an invariant
that must hold, a non-obvious constraint (ABI, hardware, platform),
or a gotcha that would otherwise cause a bug.

Do not write comments that only restate what the code obviously does,
and do not write comments that exist purely to visually separate or
label sections/groups of code (e.g. banner comments introducing "the
next part" of a file). Prefer expressing structure through naming,
functions, and file organization instead of comments.

## Markdown formatting

When creating or authoring `.md` files, wrap prose and other raw text at
approximately 120 characters per line so the source can be read without
horizontal scrolling. Apply this to new and modified content; avoid
reflowing unrelated existing content.
