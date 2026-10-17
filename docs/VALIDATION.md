# Test plan and observed results

## Verified behavior

| ID | Action | Expected outcome | Recorded outcome | Evidence quality |
| --- | --- | --- | --- | --- |
| T01 | Find DC from LAB-PC01 (`nltest /dsgetdc:corp.example.test`) | DC located | LAB-DC01 returned | Screenshot observed during build |
| T02 | Check workstation domain membership | `PartOfDomain = True`, domain `corp.example.test` | Confirmed | Screenshot observed during build |
| T03 | Run `gpresult` on LAB-PC01 | Workstation security GPO applied | `GPO_Corp_Workstation_Security` listed | Screenshot observed during build |
| T04 | Read inactivity-lock registry value | `600` | `600` | Screenshot observed during build |
| T05 | Leave workstation idle | Lock screen / password required | Observed | User report plus lock-screen screenshot |
| T06 | Enumerate SMB shares | IT, HR and Finance present | Confirmed | [Evidence 04](../evidence/04_SMB_shares_and_access.jpeg) |
| T07 | Inspect SMB ACLs | Department Change; Administrators Full | Confirmed for all three | [Evidence 04](../evidence/04_SMB_shares_and_access.jpeg) |
| T08 | Marcus opens IT share | Allowed | Opened | [Evidence 05](../evidence/05_Marcus_IT_access.jpeg) |
| T09 | Marcus opens HR and Finance | Denied | Both denied | [Evidence 06](../evidence/06_Marcus_Finance_denied.jpeg) documents Finance; HR denial also screenshot-observed |
| T10 | Sarah creates `HR-Test` file in HR share | Allowed | Created | [Evidence 07](../evidence/07_Sarah_HR_test_file.jpeg) |
| T11 | Sarah opens IT and Finance | Denied | Both denied | [Evidence 08](../evidence/08_Sarah_IT_denied.jpeg), [09](../evidence/09_Sarah_Finance_denied.jpeg) |
| T12 | David opens Finance and attempts HR/IT | Finance allowed; other folders denied | User reported pass | No dedicated David evidence screenshot included |
| T13 | Marcus creates IT test file | Allowed | **Not independently confirmed** | Do not mark complete |
| T14 | Import and boot exported OVA backups | Restored environment works | **Not yet performed** | Exports exist, restoration not verified |

## How to repeat access testing

Use `LAB-PC01` joined to `corp.example.test`, and **sign out** between tests so credentials aren't accidentally reused from another domain account. For each test user, validate the current identity with:

```powershell
whoami
```

Open Explorer and enter these share paths in the address bar:

```text
\\LAB-DC01\IT
\\LAB-DC01\HR
\\LAB-DC01\Finance
```

Record successful opening and test-file creation for the designated department; test denied access to other departments. A folder's existence on the server is **not** proof of effective access restrictions; test from the workstation with intended user credentials.

## Read-only server verification

```powershell
Get-SmbShare | Where-Object Name -in @('IT','HR','Finance') | Select-Object Name,Path
Get-SmbShareAccess -Name IT
Get-SmbShareAccess -Name HR
Get-SmbShareAccess -Name Finance
Get-Acl 'C:\CorpShares\IT' | Select-Object -ExpandProperty Access
Get-Acl 'C:\CorpShares\HR' | Select-Object -ExpandProperty Access
Get-Acl 'C:\CorpShares\Finance' | Select-Object -ExpandProperty Access
```

Expected department security groups have SMB **Change** and NTFS **Modify**, while Administrators retain Full Control. All commands above are read-only.
