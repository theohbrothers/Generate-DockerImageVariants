function Get-Definition {
    [CmdletBinding()]
    param (
        # Path to the definition file
        [Parameter()]
        [ValidateScript({ Test-Path $_ })]
        [object]
        $Path
    ,
        # Variable name to get
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]
        $VariableName
    )
    try {
        $definition = & {
            . $Path > $null

            # Send the variable down the pipeline
            Get-Variable -Name $VariableName -ValueOnly -ErrorAction Stop
        }
        if ($definition -is [array]) {
            ,$definition
        }else {
            $definition
        }
    }catch {
        Write-Error "There was an error in definition file $Path. Exception: " -ErrorAction Continue
        throw
    }
}
