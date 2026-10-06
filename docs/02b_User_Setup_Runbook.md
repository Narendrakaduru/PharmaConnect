# PharmaConnect — User Setup & Persona Assignment Runbook

> **Reference:** [02. User Roles & Security Architecture](02_User_Roles_and_Security.md)  
> **Scripts:** [`scripts/apex/setup_user_assignments.apex`](../scripts/apex/setup_user_assignments.apex)  
> **Validation:** [`scripts/soql/validate_user_assignments.soql`](../scripts/soql/validate_user_assignments.soql)

---

## Why User Assignments Are Not Source-Controlled Metadata

Salesforce **User records**, **Role assignments**, and **Permission Set Assignments** are
**org-specific data records** — not deployable metadata. They are tied to user IDs that
differ between orgs. The correct DevOps approach is:

1. Deploy metadata first (`sf project deploy start`)
2. Run the Apex setup script to apply data-level assignments (`sf apex run --file scripts/apex/setup_user_assignments.apex`)

---

## Target State — Two-Persona Model

```
┌──────────────────────────────────────────────────────────────────┐
│                      PharmaConnect Dev Org                       │
│                                                                  │
│  USER 1 — System Administrator & Area Manager                    │
│  ┌──────────────────────────────────────────────┐                │
│  │  Username: kadurunarendra_dg5gsnkmbmdxcy...  │                │
│  │  Profile:  System Administrator              │                │
│  │  Role:     Area Sales Manager - Hyderabad    │                │
│  │  Perm Sets: Pharma_Product_Catalog_Admin     │                │
│  │             Pharma_Sample_Approver           │                │
│  │             Pharma_Executive_Analytics       │                │
│  └──────────────────────────────────────────────┘                │
│           ↑ Supervises & Approves ↓                              │
│  USER 2 — Medical Representative                                 │
│  ┌──────────────────────────────────────────────┐                │
│  │  Username: harishlankepalli555@gmail.com...  │                │
│  │  Profile:  Standard User                     │                │
│  │  Role:     Medical Representative - Hyderabad│                │
│  │  Manager:  User 1 (Narendra Kaduru)          │                │
│  │  Perm Sets: Pharma_Representative_Access     │                │
│  └──────────────────────────────────────────────┘                │
└──────────────────────────────────────────────────────────────────┘
```

---

## Step 1 — Create / Verify User 2 (Medical Representative)

In modern Salesforce security architecture, least-privilege personas are implemented using standard base profiles (such as `Standard User` or `Minimum Access - Salesforce`) augmented with custom Permission Sets (`Pharma_Representative_Access`).

User 2 has been created and verified in the org:
- **Name:** Harish Lankepalli
- **Username:** `harishlankepalli555@gmail.com.devbox1`
- **Email:** `harishlankepalli555@gmail.com`
- **License:** Salesforce
- **Profile:** `Standard User`
- **Role:** `Medical Representative - Hyderabad`
- **Manager:** User 1

---

## Step 2 — Run the Apex Assignment Script

Run the automated assignment script via SF CLI:

```powershell
sf apex run --target-org sf-ep-dev --file scripts/apex/setup_user_assignments.apex
```

The script is **idempotent** — safe to re-run anytime. It skips any assignment already in place.

**Expected output (Debug log):**
```
=== PharmaConnect User Assignment Script ===
✓ Roles loaded: ASM=... | MR=...
✓ Permission sets loaded: {Pharma_Executive_Analytics, Pharma_Product_Catalog_Admin, Pharma_Representative_Access, Pharma_Sample_Approver}
✓ Users loaded: User1=... | User2=...
→ Will assign ASM role to User 1
✓ User 2 already has MR role — skipping
✓ Role assignments saved
→ Will assign [Pharma_Product_Catalog_Admin] to User 1
→ Will assign [Pharma_Sample_Approver] to User 1
→ Will assign [Pharma_Executive_Analytics] to User 1
→ Will assign [Pharma_Representative_Access] to User 2
✓ 4 permission set assignment(s) created
=== Assignment Script Complete ===
```

---

## Step 3 — Validate Assignments

Run each of the SOQL validation queries:

**Query 1: Validate User Roles & Manager Hierarchy**
```powershell
sf data query --target-org sf-ep-dev --query "SELECT Id, Username, Profile.Name, UserRole.Name, Manager.Name FROM User WHERE IsActive = TRUE AND Profile.Name IN ('System Administrator', 'Standard User') ORDER BY Profile.Name ASC"
```

**Expected result:**

| Username | Profile | Role | Manager |
|---|---|---|---|
| `kadurunarendra...devbox1` | System Administrator | Area Sales Manager - Hyderabad | *(none)* |
| `harishlankepalli555...devbox1` | Standard User | Medical Representative - Hyderabad | Narendra kaduru |

**Query 2: Validate Permission Set Assignments**
```powershell
sf data query --target-org sf-ep-dev --query "SELECT Assignee.Username, PermissionSet.Name, PermissionSet.Label FROM PermissionSetAssignment WHERE PermissionSet.Name IN ('Pharma_Representative_Access', 'Pharma_Product_Catalog_Admin', 'Pharma_Sample_Approver', 'Pharma_Executive_Analytics') ORDER BY Assignee.Username, PermissionSet.Name ASC"
```

**Expected result:**

| Username | Permission Set |
|---|---|
| `kadurunarendra...devbox1` | Pharma_Executive_Analytics |
| `kadurunarendra...devbox1` | Pharma_Product_Catalog_Admin |
| `kadurunarendra...devbox1` | Pharma_Sample_Approver |
| `harishlankepalli555...devbox1` | Pharma_Representative_Access |

---

## Step 5 — Enable Login-As (Recommended for Dev Org)

To test the Medical Representative persona from User 1's session:

1. **Setup → Security → Session Settings**
2. Enable **"Administrators Can Log In as Any User"**
3. Go to **Setup → Users**, click **Login** next to User 2

---

## Final Access Matrix

| Capability | User 1 (Admin/ASM) | User 2 (Med Rep) |
|---|---|---|
| Org administration | ✅ (System Admin profile) | ❌ |
| View all PharmaConnect objects | ✅ (role hierarchy roll-up) | Own records only |
| Manage Product catalog | ✅ `Pharma_Product_Catalog_Admin` | Read-only |
| Approve sample requests | ✅ `Pharma_Sample_Approver` | Submit only |
| Executive dashboards & analytics | ✅ `Pharma_Executive_Analytics` | ❌ |
| Log doctor visits & discussions | ✅ | ✅ `Pharma_Representative_Access` |
| Submit sample requests | ✅ | ✅ `Pharma_Representative_Access` |
| Book sales orders | ✅ | ✅ `Pharma_Representative_Access` |
| Manage follow-ups | ✅ | ✅ `Pharma_Representative_Access` |

---

## Simulated Personas (Apex Test Classes Only)

Per the [security architecture](02_User_Roles_and_Security.md), the following personas
are **not created as active org users**. They are simulated using `System.runAs()` in
Apex test classes:

| Persona | Simulation Method |
|---|---|
| Regional Sales Manager | `System.runAs(rsmUser)` in test class |
| Sales Operations / Billing | Permission Set granted to User 1 for testing |

---

[← Back to Master Documentation Index](../PharmaConnect_Project_Documentation.md)
