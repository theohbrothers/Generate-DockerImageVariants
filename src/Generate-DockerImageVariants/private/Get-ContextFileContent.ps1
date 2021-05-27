function Get-ContextFileContent {
    [CmdletBinding()]
    param (
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [hashtable]$Template
    ,
        [Parameter()]
        [hashtable]$TemplatePassVariables
    )

    if (! (Test-Path $Template['templateDirectory'] -PathType Container) ) {
        throw "No such template directory: $( $Template['templateDirectory'] )"
    }

    # Make PASS_VARIABLES global variable available to the template script
    $global:PASS_VARIABLES = if ($TemplatePassVariables) { $TemplatePassVariables } else { @{} }

    $params = @{}
    if ( $Template['includeHeader'] ) {
        $templateFileAbsolutePath = [IO.Path]::Combine($Template['templateDirectory'], "$( $Template['file'] ).header.ps1")
        "Processing template file: $templateFileAbsolutePath" | Write-Verbose
        Get-ContentFromTemplate -Path $templateFileAbsolutePath

        # Spaces our header from body
        $params['PrependNewLines'] = 2
    }

    if ($Template.Contains('subTemplates') -and $Template['subTemplates'] -is [array] -and $Template['subTemplates'].Count -gt 0) {
        $Template['subTemplates'] | % {
            $templateFileAbsolutePath = [IO.Path]::Combine($Template['templateDirectory'], $_, "$_.ps1")
            "Processing template file: $templateFileAbsolutePath" | Write-Verbose
            Get-ContentFromTemplate -Path $templateFileAbsolutePath @params
        }
    }else {
        $templateFileAbsolutePath = [IO.Path]::Combine($Template['templateDirectory'], "$( $Template['file'] ).ps1")
        "Processing template file: $templateFileAbsolutePath" | Write-Verbose
        Get-ContentFromTemplate -Path $templateFileAbsolutePath @params
    }

    if ( $Template['includeFooter'] ) {
        $templateFileAbsolutePath = [IO.Path]::Combine($Template['templateDirectory'], "$( $Template['file'] ).footer.ps1")
        "Processing template file: $templateFileAbsolutePath" | Write-Verbose
        Get-ContentFromTemplate -Path $templateFileAbsolutePath @params
    }
}
