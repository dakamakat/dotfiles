# Knowledge base

| Hotkey | Does |
| --- | --- |
| `Super+N` | Quick capture, prefilled from the clipboard. A URL becomes an article note (full text pulled in), anything else a note. Copied files are offered as attachments. |
| `Super+F` | Pick files to add (PDFs, images, docs, `.md` notes). |
| `Super+O` | Open this vault. |

From a terminal: `kb add <url | file | text>`, `echo … | kb add -`.
Telegram Saved Messages: export them as JSON from Telegram Desktop, then run `kb telegram`.

Everything lands with a title, type, tags and a summary written by Claude; the original content
is kept below the properties.

## Workflow

1. **Capture** without thinking: everything goes to `Inbox/` (or `Telegram/`).
2. **Review** the Inbox view below every few days: fix the title or tags, add your own thoughts, link it to related notes with `[[…]]`, move it into a topic folder or delete it.
3. **Write** your own notes (`Ctrl+N` creates one in the Inbox, `Templates/` has a note template), and link generously.

![[Knowledge.base]]
