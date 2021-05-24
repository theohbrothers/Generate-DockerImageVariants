$script:MODULE_BASE_DIR = Split-Path $MyInvocation.MyCommand.Path -Parent
$script:MODULE_HELPER_DIR = Join-Path $MODULE_BASE_DIR 'helper'
$script:MODULE_PRIVATE_DIR = Join-Path $MODULE_BASE_DIR 'private'
$script:MODULE_PUBLIC_DIR = Join-Path $MODULE_BASE_DIR 'public'
$script:GENERATE_DOCKERIMAGEVARIANTS_VERSION = 'v0.2.0'

Get-ChildItem "$script:MODULE_HELPER_DIR/*.ps1" -exclude *.Tests.ps1 | % {
    . $_.FullName
}

Get-ChildItem "$script:MODULE_PRIVATE_DIR/*.ps1" -exclude *.Tests.ps1 | % {
    . $_.FullName
}

Get-ChildItem "$script:MODULE_PUBLIC_DIR/*.ps1" -exclude *.Tests.ps1 | % {
    . $_.FullName
}
