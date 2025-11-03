# 🧩 Contributing Guide – PowerShell Module

Thank you for your interest in contributing to this PowerShell project 💙
This guide explains how to submit a **Pull Request (PR)** in a clean, consistent, and effective way.

---

## 🚀 Setting Up Your Environment

Before starting:

1. **Fork** the repository on GitHub.
2. **Clone** your fork locally:
   ```bash
   git clone https://github.com/arnaudcharles/PSWEE.git
   cd PSWEE
   ```
3. **Create** a new branch for your changes:
    ```bash
    git checkout -b feature/short-description
    ```
## ✍️ Function Naming Rules

Use approved PowerShell verbs (Get, Set, Invoke, etc.)

Avoid abbreviations in function names.

Short aliases can be added directly in the function via **[Alias()]**:

```powershell
function Invoke-MySuperDuperFunction {
    [Alias("IMSDF")]
    [CmdletBinding()]
    param()
    # ...
}
```

## 🧪 Testing

Before submitting your PR:

Add or update Pester tests for any new or changed functionality.

Test file example: **tests/Invoke-MySuperDuperFunction.Tests.ps1**

Run all tests locally:

```powershell
Invoke-Pester
```

Make sure all tests pass with no errors.


## 🧹 Code Style Guidelines

Use 4 spaces for indentation.

Follow PowerShell best practices:

**[CmdletBinding()]** for public functions.

Parameter validation **([ValidateNotNullOrEmpty()], [ValidateSet()], etc.)**

Prefer inline comments that explain why code exists:

```powershell
# This comment explains why this line is necessary.
```

## 💡 You can run PSScriptAnalyzer

To check your code style:

```powershell
Invoke-ScriptAnalyzer -Path .\Public -Recurse
````

## 🧭 Creating a Pull Request (PR)

Once your branch is ready:

Push your branch:

```bash
git push origin feature/short-description
```

Open a Pull Request on GitHub against the main (or dev) branch, depending on the project workflow.

## 📝 PR Description Template

Please include:

A summary of your change.

What was added, changed, or fixed.

Test details and potential impacts.

Example:

```powershell
### 🧩 Description
Added a new `Get-ModuleStatus` function to check module health.

### ✅ Changes
- New public function added
- Pester test created
- Documentation updated

### 🧪 Tests
- All Pester tests passed ✅
```

## 🔍 Review & Approval

After opening your PR:

The team will perform a code review.

Be ready to discuss comments and update your code if needed.

Once approved, your PR will be merged 🎉