$ErrorActionPreference = "STOP"

$repoPath = (Join-Path $PSScriptRoot ".\repo")

# lint
helm lint (Join-Path $PSScriptRoot ".\charts\sitecore930-xm") --values (Join-Path $PSScriptRoot ".\charts\sitecore930-xm\ci\values.yaml") --strict

$LASTEXITCODE -ne 0 | Where-Object { $_ } | ForEach-Object { throw "Failed." }

# package
helm package (Join-Path $PSScriptRoot ".\charts\sitecore930-xm") --version 1.0.0 --destination $repoPath

$LASTEXITCODE -ne 0 | Where-Object { $_ } | ForEach-Object { throw "Failed." }

# update index
helm repo index $repoPath --merge (Join-Path $repoPath "\index.yaml")

$LASTEXITCODE -ne 0 | Where-Object { $_ } | ForEach-Object { throw "Failed." }