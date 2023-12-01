function Get-Function {
    [CmdletBinding()]
    param (
        # Path to the function file
        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path $_ })]
        [object]
        $Path
    )
    try {
        & {
            # Test the syntax and throw on errors
            "Reading file: $Path" | Write-Verbose
            . $Path *> $null

            # Normalize path
            Convert-Path $Path
        }
    }catch {
        Write-Error "There was an error in function file $Path. Exception: $( $_.Exception.Message )" -ErrorAction Continue
        throw
    }
}
