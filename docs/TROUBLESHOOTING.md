# Troubleshooting cases and lessons

## Domain login difficulties

**Symptom:** User could not log in and repeated resets did not initially solve the problem.

**Investigation:** Checked user account state in Active Directory (`Enabled`, `LockedOut`, `PasswordExpired`), account logon name and legacy pre-Windows 2000 logon name. Inspected Security log Event ID **4625** (failed logon) on the workstation, along with account-credential validation events on the DC. Tested user logon after updating a password.

**Resolution observed:** A successful domain logon was eventually demonstrated with `whoami` returning `corp\mjohnson`. The accepted sign-in format was the correct domain account name; incorrectly specifying the identity caused confusion. **Caution:** `CORP\mjohnson` is a valid Windows down-level name syntax if entered correctly; the observed failure should not be generalized into a rule that a domain prefix is invalid. The domain also supports the UPN style `mjohnson@corp.example.test`.

**Takeaway:** Distinguish identity-format problems from account status and password issues. An account may be recognized while still requiring a password change. Use event evidence rather than reset credentials repeatedly.

## Windows client domain discovery

**Symptoms explored:** Domain join / rename confusion, DNS timeout / unknown DNS server label.

**Checks:** `ping 192.168.10.10` returned replies, `nslookup corp.example.test` resolved the domain to `192.168.10.10` despite a reverse-name timeout, and `nltest /dsgetdc:corp.example.test` successfully located `LAB-DC01`.

**Interpretation:** Failure to identify the *DNS server's own reverse lookup name* does not automatically mean forward domain DNS resolution has failed. Check both forward DNS and domain-controller discovery independently.

**Post-join rename:** An `Add-Computer` call reported successful domain join but a rename error. After reboot, checks confirmed domain membership, and the renamed hostname appeared in a subsequent verification. Do not assume an operation wholly failed when a multipart command reports a partial error; verify each result.

## Group Policy targeting

**Problem caught during build:** The workstation computer policy was initially linked to a user OU.

**Correction:** Created `Corp-Workstations`, placed `LAB-PC01` there and linked the computer-side GPO to it. `gpresult` subsequently listed the applied policy, the registry reported `600`, and an actual idle lock was observed.

**Takeaway:** Computer settings are applied based on the *computer object's* applicable GPO scope. Configuration screens alone do not prove policy processing or effective behavior.

## SMB and NTFS authorization

**Risk:** Inherited `CORP\Users` ACLs could expose data to unintended departments.

**Correction:** Disabled inheritance on each child department folder, converted ACEs to explicit entries, removed broad user entries, retained essential admin/SYSTEM access, added individual department group NTFS Modify and SMB Change rights.

**Evidence:** Group ACL listings plus allowed and denied tests from `LAB-PC01`. See [VALIDATION.md](VALIDATION.md).

## Next exercises (not represented as completed)

- Repeat verification after changes to group membership and sign-in token refresh.
- Introduce a deliberately broken permission in a **snapshot/copy**, troubleshoot with `Get-Acl`, then roll back.
- Validate OVA re-import/restore on a duplicate isolated VirtualBox network.
- Implement a dedicated file server and test recoverable backups.
