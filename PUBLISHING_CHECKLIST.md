# GitHub publishing checklist

1. Create a **new public repository** named `Windows-Server-Enterprise-Lab` (or another name you prefer), without initializing it with another README.
2. Download and extract the GitHub-ready ZIP; upload the *contents of the extracted folder*, not the containing ZIP or private OVA backups.
3. Inspect every screenshot under `evidence/` for private or incidental content before publishing. Remove/redact anything you'd rather not share publicly.
4. Confirm there are **no** `.ova`, `.vdi`, `.vbox`, `.iso`, Windows system files, passwords or key material staged.
5. Confirm README image links render and Markdown relative links open.
6. On GitHub, optionally add repo topics: `active-directory`, `windows-server`, `group-policy`, `smb`, `ntfs`, `powershell`, `homelab`.
7. Pin the finished repository to your GitHub profile if you want to showcase it.
8. Keep the two real OVA exports in private backup storage; test restoration separately when time permits.

**Git CLI alternative** (run from the extracted folder, after manual inspection):

```powershell
git init
git add README.md .gitignore PUBLISHING_CHECKLIST.md docs scripts evidence
git status
git commit -m "Document Windows Server enterprise infrastructure lab"
# Add your own repository remote URL from GitHub, then push.
```

Use GitHub's **Add file → Upload files** for a no-CLI alternative. Do not upload this entire ZIP *as a ZIP asset* if you want GitHub to render the README and evidence directly.
