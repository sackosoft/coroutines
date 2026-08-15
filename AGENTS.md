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
