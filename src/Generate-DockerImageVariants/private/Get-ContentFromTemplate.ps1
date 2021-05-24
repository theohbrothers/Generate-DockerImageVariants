function Get-ContentFromTemplate {
    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        [string]$Path
    ,
        [ValidateRange(1,100)]
        [int]$PrependNewLines
    )
    if (! (Test-Path $Path -PathType Leaf) ) {
        throw "No such file: $Path"
    }

    $content = & $Path
    if ($PrependNewLines -gt 0) {
        $content = "$( "`n" * $PrependNewLines )$content"
    }
    $content
}
