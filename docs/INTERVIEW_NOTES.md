# Interview discussion guide

## Two-minute project summary

> I built an isolated Windows Server infrastructure lab with two VirtualBox VMs. On the server, I configured AD DS and DNS, created a test forest, department OUs, user accounts and security groups, and linked a 10-minute inactivity-lock GPO to a workstation OU. I joined Windows 11 to the domain, then configured IT, HR and Finance file shares using both NTFS and SMB permissions. I tested domain logins, verified Group Policy application, and checked that employees could access their department's shares while being denied access to other departments. I also troubleshot domain-logon issues using PowerShell, DNS/domain-controller discovery tools, and Security events. It's a self-directed lab rather than production experience, but I can explain and demonstrate every stage.

## Common technical follow-ups

**Why an OU rather than a security group?** OUs organize objects and scope delegation/GPOs. Security groups bundle users/computers for permissions. A person can belong to an OU and multiple groups for different purposes.

**What did the GPO do?** Computer Security Options: machine inactivity limit `600` seconds. Lock workstation after inactivity; it does not log a user out. Verified `gpresult`, registry value and actual lock behavior.

**Why point client DNS to the DC?** AD clients use DNS records for domain-controller and service discovery. An unrelated public resolver may not have private AD service records.

**How did you restrict shares?** NTFS Modify for each department security group, SMB Change for corresponding share; retained admin access and removed broad user access. Then tested both allowed and denied cases with actual domain user sessions.

**Why both NTFS and SMB permissions?** Both apply to network access; effective access cannot exceed either set of permissions.

**What would you improve for production?** Dedicated file server, tested backup/restore, monitoring, redundancy, hardened administrative access, appropriate audit logging and documented change management.

**Most difficult issue?** Domain login trouble: narrowed possible causes with identity/account status, DNS/domain discovery, Windows event logs and validated corrected sign-in. Emphasize systematic checking and acknowledging partial failures.

## Honest experience boundary

Avoid claiming: production system administration, VMware/ESXi deployment, a working redundant domain, enterprise backup implementation, cloud infrastructure, full automation, or successful OVA restoration. They were **not** part of the verified lab.

## Suggested résumé entry

**Windows Server Enterprise Infrastructure Lab** | Windows Server, Active Directory, DNS, Group Policy, VirtualBox, PowerShell, SMB/NTFS

- Deployed a two-VM Windows domain with AD DS/DNS, organizational units and departmental security groups; joined a Windows 11 client and validated domain authentication.
- Configured and verified a 600-second workstation inactivity-lock Group Policy using `gpresult`, registry inspection and an observed lock-screen test.
- Implemented role-based file-share access with NTFS Modify and SMB Change permissions for IT, HR and Finance; verified authorized use and cross-department denials.
