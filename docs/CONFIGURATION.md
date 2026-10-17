# Configuration runbook

This is a narrative record of the manually built environment, **not** a fully automated installer. The paths and addresses below are specific to a fictional isolated network; adapt them when rebuilding.

## Prerequisites

- Oracle VirtualBox with sufficient RAM, CPU and disk space for two Windows VMs
- Windows Server and Windows 11 Pro/Enterprise/Education installation media and appropriate licenses/evaluation permissions
- One isolated VirtualBox **Internal Network** named `AD-LAB` connected to both VMs
- Two powered-on VMs for domain interactions; the DC needs to start before the client for domain services

## 1. Domain controller

- Set hostname to `LAB-DC01`.
- Configure a static IPv4 address `192.168.10.10/24` and DNS pointing to `192.168.10.10` on the isolated adapter.
- Install **Active Directory Domain Services** and **DNS Server**.
- Promote the machine to a new forest named `corp.example.test` (NetBIOS `CORP`), then restart.
- Verify `NTDS` and `DNS` services and examine the domain configuration via AD tools and PowerShell.

Representative non-mutating checks:

```powershell
Get-Service NTDS,DNS
Get-ADDomain
```

## 2. AD organization

Create the following organizational units using Active Directory Users and Computers:

```text
corp.example.test
├── Corp-Users
│   ├── IT
│   ├── HR
│   └── Finance
└── Corp-Workstations
```

Create three **global security groups**, one per department: `GG_IT_Staff`, `GG_HR_Staff`, `GG_Finance_Staff`. Provision example employees for IT (Marcus), HR (Sarah), and Finance (David), assign membership and use unique temporary passwords with a required change on first login as appropriate. **Do not commit any credentials to GitHub.**

## 3. Domain-joined Windows 11 client

- Configure VM `LAB-PC01` with an adapter on the same `AD-LAB` internal network.
- Configure `192.168.10.20/24`, DNS `192.168.10.10`. No default gateway is needed for isolated, same-subnet lab connectivity.
- Validate:

```powershell
ipconfig /all
ping 192.168.10.10
nslookup corp.example.test
nltest /dsgetdc:corp.example.test
```

- Join `corp.example.test` with authorized domain credentials, rename the Windows computer `LAB-PC01` if necessary, restart, and verify:

```powershell
Get-CimInstance Win32_ComputerSystem | Select-Object Name,Domain,PartOfDomain
```

- Move the `LAB-PC01` computer object into `Corp-Workstations` OU.

## 4. Workstation Group Policy

- Create GPO `GPO_Corp_Workstation_Security`, linked to **Corp-Workstations**, not the employee user OU.
- Edit: `Computer Configuration > Policies > Windows Settings > Security Settings > Local Policies > Security Options > Interactive logon: Machine inactivity limit`.
- Set `600` seconds. Update and test on the client:

```powershell
gpupdate /force
gpresult /r
Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Name InactivityTimeoutSecs
```

The last command should return `600`. Verify actual behavior by leaving the client idle: it should **lock** and request authentication, not end the session.

## 5. Departmental folders and NTFS permissions

Create folders on the server:

```powershell
New-Item -ItemType Directory -Path C:\CorpShares\IT,C:\CorpShares\HR,C:\CorpShares\Finance -Force
Get-ChildItem C:\CorpShares
```

For **each** departmental folder, open `Properties > Security > Advanced`, disable inheritance, **convert** inherited permissions to explicit entries, remove general `CORP\Users` entries and preserve `Administrators`, `SYSTEM`, and the original applicable `CREATOR OWNER` entry. Add the corresponding domain department group with **Modify** applied to this folder, subfolders and files. Inspect permissions before saving; never strip the administrator or SYSTEM ACEs.

| Folder | Intended department group / NTFS rights |
| --- | --- |
| `C:\CorpShares\IT` | `CORP\GG_IT_Staff`: Modify |
| `C:\CorpShares\HR` | `CORP\GG_HR_Staff`: Modify |
| `C:\CorpShares\Finance` | `CORP\GG_Finance_Staff`: Modify |

## 6. SMB sharing

For each folder, open `Properties > Sharing > Advanced Sharing` and enable sharing with the matching name (`IT`, `HR`, `Finance`). Replace default broad `Everyone` permissions with:

- `CORP\GG_<department>_Staff`: **Change** and **Read** (Change includes Read)
- `CORP\Administrators` / Administrators: **Full Control**

A sample share validation on the server:

```powershell
Get-SmbShare
Get-SmbShareAccess -Name IT
Get-SmbShareAccess -Name HR
Get-SmbShareAccess -Name Finance
```

Actual screenshot evidence shows the group `BUILTIN\Administrators` for share access. This resolves the local Administrators group on the domain controller; it is not a different departmental permission design.

## 7. Access tests

Sign into the client as each employee separately. Open the authorized `\\LAB-DC01\Department` share, confirm access, then attempt other departments and confirm denial. Create a test file in an authorized share to check write access. Record both allowed and denied scenarios, not just server-side ACL screenshots. See [VALIDATION.md](VALIDATION.md).

## 8. Private export

The completed environment was exported as two separate OVA files: `LAB-DC01.ova` and `LAB-PC01.ova`. These are **not public repository assets**. Keep originals and test import/restore in a **separate isolated** network before treating exports as verified recovery backups. Never boot an imported copy of LAB-DC01 alongside the original on the same network.
