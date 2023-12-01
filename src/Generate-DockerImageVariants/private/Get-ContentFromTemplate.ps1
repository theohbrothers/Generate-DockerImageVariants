function Get-ContentFromTemplate {
    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        [string]$Path
    ,
        [ValidateRange(1,100)]
        [int]$PrependNewLines
    ,
        [Parameter(ParameterSetName='default')]
        [ValidateNotNull()]
        [string[]]
        $Functions
    )

    try {
        if (! (Test-Path $Path -PathType Leaf) ) {
            throw "No such file: $Path"
        }

        $content = & {
            foreach ($f in $Functions) {
                "Sourcing function: $f" | Write-Verbose
                . $f
            }
            & $Path
        }
        if ($PrependNewLines -gt 0) {
            $content = "$( "`n" * $PrependNewLines )$content"
        }
        $content
    }catch {
        throw
    }
}
