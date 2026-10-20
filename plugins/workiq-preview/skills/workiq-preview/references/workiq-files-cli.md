# Work IQ Files CLI

Use the CLI for WorkIQ file status, downloads, and uploads. Use entity tools for structured metadata queries. Require an authoritative WorkIQ file ID or reference; Graph drive-item IDs and signed storage URLs are not WorkIQ file IDs or references. Supported Graph file and attachment downloads still use [fetch_blob](fetch-blob-work-iq.md).

## Install

Requires Node.js 20+. Install only when needed:

```powershell
npm install --global @microsoft/workiq-files@0.1.1 --registry=https://packagefeedproxy.microsoft.io/npm/
workiq-files --help
```

## Review and accept the EULA

Show the terms:

```powershell
$eula = workiq-files eula show | ConvertFrom-Json
$eula.terms
```

Obtain **explicit user permission** before running the following separate command. It accepts immediately without a confirmation prompt. Installation or a transfer request is not consent; never automate acceptance, including after an error.

```powershell
workiq-files accept-eula
```

Authentication, status, and transfers require an accepted EULA. Do not repeat acceptance when the current terms are already accepted.

## Sign in and transfer

```powershell
workiq-files auth login
```

Use the intended account. Confirm the exact remote target and local path before uploading or overwriting files. Replace the placeholder with the returned WorkIQ file ID:

```powershell
workiq-files status --file-id "<workiq-file-id>"
workiq-files download --file-id "<workiq-file-id>" --out ".\downloads\report.pdf"
workiq-files upload --file-id "<workiq-file-id>" --in ".\report.pdf"
```

Alternatively, replace `--file-id ID` with `--reference ".\workiq-reference.json"` for a protected file containing the canonical WorkIQ reference. Paths are relative to CWD; see `workiq-files --help` for other options.

## Safety

Never expose tokens, signed URLs, reference secrets, or account-cache contents. Stop on authentication, consent, access, or policy denial; do not switch tools, accounts, or endpoints to bypass it. Verify the downloaded file exists and report uploads complete only from confirmed results; session creation is not a completed transfer. Do not blindly replay an ambiguous upload or execute downloaded content.
