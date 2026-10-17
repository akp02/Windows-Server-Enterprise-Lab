# Safe publication and restore precautions

## Public repository contents

Allowed: description, diagrams, configuration logic, **non-sensitive lab-only** IP addresses and domain names, read-only verification commands, curated screenshots.

Excluded: operating system disks (`.ova`, `.vdi`, `.vhd`, `.vmdk`), VirtualBox VM configurations, server backup archives, `ntds.dit`, SYSVOL backup exports, secrets, private keys, user passwords, recovery keys, security-token caches, personal files.

`corp.example.test` is a fictional reserved-domain test name. `192.168.10.0/24` is a private isolated-lab network. Never reuse the chat-visible demonstration passwords in any real environment.

## Private VM exports

The final lab was exported to **two separate OVA archives**, `LAB-DC01.ova` and `LAB-PC01.ova`, stored locally by the operator. VM archives can include sensitive AD account hashes and machine credentials. Store them privately, restrict access and preferably encrypt backups at rest.

An **export is not proof of a tested backup**. For a full restoration test, import onto a separate machine or into a non-overlapping isolated network, power on the restored DC first, verify its health, then start the client and re-test domain login, DNS, GPO and SMB access. Never connect a restored copy of the same DC to the original DC's running domain network; duplicated AD identities cause serious conflicts.

An OVA is a portability artifact, not a replacement for supported Active Directory system-state backup and domain-recovery procedures in production.

## Windows licensing

Windows Server and Windows 11 require valid licenses or properly used evaluation media. A GitHub repository should document procedures rather than redistribute Microsoft OS images or installations.

## Avoid accidental commit

The accompanying `.gitignore` excludes common VM archives and secrets. `.gitignore` only protects files not previously committed. Inspect `git status` and repository contents before pushing; use history rewrite and credential rotation if secret material was ever committed.
