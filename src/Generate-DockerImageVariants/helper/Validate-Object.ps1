# For validation of a given object, against its expected prototype
function Validate-Object {
    [CmdletBinding(DefaultParameterSetName='Default')]
    param (
        [Parameter(Mandatory=$true, ParameterSetName='Pipeline', Position=0)]
        [Parameter(Mandatory=$true, ParameterSetName='Default')]
        [object]$Prototype
    ,
        [Parameter(Mandatory=$true, ValueFromPipeline, ParameterSetName='Pipeline')]
        [Parameter(Mandatory=$true, ParameterSetName='Default')]
        [AllowNull()]
        [AllowEmptyString()]
        [AllowEmptyCollection()]
        [object]$TargetObject
    ,
        [Parameter(Mandatory=$true, ParameterSetName='Pipeline')]
        [Parameter(Mandatory=$false, ParameterSetName='Default')]
        [switch]$Mandatory
    )
    process {
        try {
            if ($null -ne $TargetObject) {
                "Validating TargetObject '$Targetobject' of type '$( $Targetobject.GetType().Name )' and basetype '$( $Targetobject.GetType().BaseType )'`tagainst Prototype '$Prototype' of type '$( $Prototype.GetType().Name )' and basetype '$( $Prototype.GetType().BaseType )'" | Write-Verbose
                if ( $Prototype.GetType().FullName -ne $TargetObject.GetType().FullName ) {
                    throw "Type $( $TargetObject.GetType().FullName ) is invalid! It should be of type '$( $Prototype.GetType().FullName )'"
                }
            }

            if ( $Prototype -is [string] ) {
                # Nothing
            }elseif ( $Prototype -is [array] -or $Prototype -is [System.Collections.ArrayList] ) {
                if ( $Prototype.Count -eq 0 -or $Prototype.Count -gt 1 ) {
                    throw "Invalid prototype! I must contain only one value. Prototype: `n$Prototype"
                }
                $_prototype = $Prototype[0]
                foreach ( $_targetObject in $TargetObject ) {
                    "`tValidating TargetObject '$_targetObject' of type '$( $_targetObject.GetType().Name )' and basetype '$( $_targetObject.GetType().BaseType )'`t`tagainst Prototype '$_prototype' of type '$( $_prototype.GetType().Name )' and basetype '$( $_prototype.GetType().BaseType )'" | Write-Verbose
                    if ($_prototype.GetType().FullName -ne $_targetObject.GetType().FullName) {
                        throw "Type $( $_targetObject.GetType().FullName ) is invalid! It should be of type '$( $_prototype.GetType().FullName )'"
                    }
                    if ( $_prototype -is [psobject] -or
                        $_prototype.GetType().FullName -match '^System\.Collections\.Hashtable$|^System\.Collections\.Specialized\.OrderedDictionary$'
                    ) {
                        Validate-Object -Prototype $_prototype -TargetObject $_targetObject -Mandatory:$Mandatory
                    }
                }
            }else {
                if ( $Prototype -is [bool] ) {
                    if (!$Mandatory) {
                        if ($null -eq $TargetObject) {
                            return
                        }
                    }
                    # Ensure we got all properties
                    if ($null -eq $TargetObject) {
                        throw "Value cannot be null"
                    }
                    if ( $TargetObject -isnot [bool] ) {
                        throw "Value should be of type [bool]"
                    }
                    return
                }elseif ( $Prototype -is [int] ) {
                    if (!$Mandatory) {
                        if ($null -eq $TargetObject) {
                            return
                        }
                    }
                    # Ensure we got all properties
                    if ($null -eq $TargetObject) {
                        throw "Value cannot be null"
                    }
                    if ( $TargetObject -isnot [int] ) {
                        throw "Value should be of type [int]"
                    }
                    return
                }
                elseif ( $Prototype -is [psobject] -or $Prototype -is [pscustomobject] ) {
                    foreach ($property in $Prototype.psobject.properties.name) {
                        $_prototype = $Prototype.$property
                        if ($Mandatory -and $TargetObject.psobject.properties.match($property).Count -eq 0) {
                            throw "Key '$property' is missing"
                        }
                        $_targetObject = $TargetObject.$property
                        if (!$Mandatory) {
                            if ($null -eq $TargetObject.$property) {
                                return
                            }
                        }

                        Validate-Object -Prototype $_prototype -TargetObject $_targetObject -Mandatory:$Mandatory
                    }
                }elseif ( $Prototype.GetType().FullName -match '^System\.Collections\.Hashtable$|^System\.Collections\.Specialized\.OrderedDictionary$') {
                    $Prototype.GetEnumerator() | % {
                        $Key = $_.Name
                        $_prototype = $Prototype[$Key]
                        if ($Mandatory -and ! $TargetObject.Contains($key)) {
                            # Ensure we got all properties
                            throw "Key '$Key' is missing"
                        }
                        $_targetObject = $TargetObject[$Key]
                        if (!$Mandatory) {
                            if ($null -eq $_targetObject) {
                                return
                            }
                        }

                        Validate-Object -Prototype $_prototype -TargetObject $_targetObject -Mandatory:$Mandatory
                    }
                }else {
                    throw "Type $( $Prototype.Gettype().FullName ) is invalid. It must be one of the following: bool, string, array, hashtable, psobject"
                }
            }
        }catch {
            Write-Error -ErrorRecord $_
        }
    }
}
