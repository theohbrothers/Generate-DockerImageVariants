$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "Validate-Object" -Tag 'Unit' {

    Context 'Successful validation of types' {

        $ErrorActionPreference = 'Stop'

        It 'boolean' {
            $prototype = $true
            $object = $false

            Validate-Object -Prototype $prototype -TargetObject $object
        }

        It 'string' {
            $prototype = 'foo'
            $object = 'bar'

            Validate-Object -Prototype $prototype -TargetObject $object
        }

        It 'array' {
            $prototype = @(1)
            $object = @(2)

            Validate-Object -Prototype $prototype -TargetObject $object
        }

        It 'arraylist' {
            $prototype = [System.Collections.ArrayList]@(1)
            $object = [System.Collections.ArrayList]@(2)

            Validate-Object -Prototype $prototype -TargetObject $object
        }

        It 'pscustomobject' {
            $prototype = [pscustomobject]@{ 'foo' = 'bar' }
            $object = [pscustomobject]@{ 'foo' = 'baz' }

            Validate-Object -Prototype $prototype -TargetObject $object
        }

        It 'hashtable' {
            $prototype = @{ 'foo' = @() }
            $object = @{ 'bar' = @() }

            Validate-Object -Prototype $prototype -TargetObject $object
        }

        It 'ordered hashtable' {
            $prototype = [ordered]@{ 'foo' = @() }
            $object = [ordered]@{ 'bar' = @() }

            Validate-Object -Prototype $prototype -TargetObject $object
        }
    }

    Context 'Failed validation of types' {

        $ErrorActionPreference = 'Stop'

        It 'integer' {
            $prototype = 1
            $object = 'bar'

            { Validate-Object -Prototype $prototype -TargetObject $object } | Should -Throw "It should be of type 'System.Int32'"
        }

        It 'string' {
            $prototype = 'foo'
            $object = 1

            { Validate-Object -Prototype $prototype -TargetObject $object } | Should -Throw "It should be of type 'System.String'"
        }

        It 'array' {
            $prototype = @( 'foo' )
            $object = 1

            { Validate-Object -Prototype $prototype -TargetObject $object } | Should -Throw "It should be of type 'System.Object[]'"
        }

        It 'arraylist' {
            $prototype = [System.Collections.ArrayList]@( 'foo' )
            $object = 1

            { Validate-Object -Prototype $prototype -TargetObject $object } | Should -Throw "It should be of type 'System.Collections.ArrayList'"
        }

        It 'pscustomobject' {
            $prototype = [pscustomobject]@{ 'foo' = @() }
            $object = 1

            { Validate-Object -Prototype $prototype -TargetObject $object } | Should -Throw "It should be of type 'System.Management.Automation.PSCustomObject'"
        }

        It 'hashtable' {
            $prototype = @{ 'foo' = @() }
            $object = 1

            { Validate-Object -Prototype $prototype -TargetObject $object } | Should -Throw "It should be of type 'System.Collections.Hashtable'"
        }

        It 'ordered hashtable' {
            $prototype = [ordered]@{ 'foo' = @() }
            $object = 1

            { Validate-Object -Prototype $prototype -TargetObject $object } | Should -Throw "It should be of type 'System.Collections.Specialized.OrderedDictionary'"
        }

    }

    Context 'Successful recursive validation of types' {

        $ErrorActionPreference = 'Stop'

        It 'hashtable' {
            $prototype = @{
                'foo' = @{
                    'bar' = 1
                }
            }
            $object = @{
                'foo' = @{
                    'bar' = 2
                }
            }

            Validate-Object -Prototype $prototype -TargetObject $object
        }

        It 'ordered hashtable' {
            $prototype = [ordered]@{
                'foo' = [ordered]@{
                    'bar' = 1
                }
            }
            $object = [ordered]@{
                'foo' = [ordered]@{
                    'bar' = 2
                }
            }

            Validate-Object -Prototype $prototype -TargetObject $object
        }

        It 'array of hashtable' {
            $prototype = @(
                @{
                    'foo' = 1
                }
            )
            $object = @(
                @{
                    'foo' = 2
                }
            )

            Validate-Object -Prototype $prototype -TargetObject $object
        }

        It 'array of ordered hashtable' {
            $prototype = @(
                [ordered]@{
                    'foo' = 1
                }
            )
            $object = @(
                [ordered]@{
                    'foo' = 2
                }
            )

            Validate-Object -Prototype $prototype -TargetObject $object
        }
    }

    Context 'Failed recursive validation of types' {

        $ErrorActionPreference = 'Stop'

        It 'hashtable' {
            $prototype = @{
                'foo' = @{
                    'bar' = 1
                }
            }
            $object = @{
                'foo' = 1
            }

            { Validate-Object -Prototype $prototype -TargetObject $object } | Should -Throw "It should be of type 'System.Collections.Hashtable'"
        }

        It 'ordered hashtable' {
            $prototype = [ordered]@{
                'foo' = [ordered]@{
                    'bar' = 1
                }
            }
            $object = [ordered]@{
                'foo' = @()
            }

            { Validate-Object -Prototype $prototype -TargetObject $object } | Should -Throw "It should be of type 'System.Collections.Specialized.OrderedDictionary'"
        }

        It 'array of hashtable' {
            $prototype = @(
                @{
                    'foo' = 1
                }
            )
            $object = @(
                1
            )

            { Validate-Object -Prototype $prototype -TargetObject $object } | Should -Throw "It should be of type 'System.Collections.Hashtable'"
        }

        It 'array of ordered hashtable' {
            $prototype = @(
                [ordered]@{
                    'foo' = 1
                }
            )
            $object = @(
                1
            )

            { Validate-Object -Prototype $prototype -TargetObject $object } | Should -Throw "It should be of type 'System.Collections.Specialized.OrderedDictionary'"
        }
    }

    Context 'Failed validation of mandatory value' {

        $ErrorActionPreference = 'Stop'

        It 'integer' {
            $prototype = 1
            $object = $null
            $mandatory = $true

            { Validate-Object -Prototype $prototype -TargetObject $object -Mandatory:$mandatory } | Should -Throw "Value cannot be null"
        }

        It 'boolean' {
            $prototype = $false
            $object = $null
            $mandatory = $true

            { Validate-Object -Prototype $prototype -TargetObject $object -Mandatory:$mandatory } | Should -Throw "Value cannot be null"
        }

        It 'pscustomobject' {
            $prototype = [pscustomobject]@{
                'foo' = 1
            }
            $object = [pscustomobject]@{
                'foo' = $null
            }
            $mandatory = $true

            { Validate-Object -Prototype $prototype -TargetObject $object -Mandatory:$mandatory } | Should -Throw "Value cannot be null"
        }

        It 'hashtable' {
            $prototype = @{
                'foo' = 1
            }
            $object = @{
                'foo' = $null
            }
            $mandatory = $true

            { Validate-Object -Prototype $prototype -TargetObject $object -Mandatory:$mandatory } | Should -Throw "Value cannot be null"
        }

        It 'ordered hashtable' {
            $prototype = [ordered]@{
                'foo' = 1
            }
            $object = [ordered]@{
                'foo' = $null
            }
            $mandatory = $true

            { Validate-Object -Prototype $prototype -TargetObject $object -Mandatory:$mandatory } | Should -Throw "Value cannot be null"
        }
    }

    Context 'Failed validation of mandatory object key' {

        $ErrorActionPreference = 'Stop'

        It 'pscustomobject' {
            $prototype = [pscustomobject]@{
                'foo' = 1
            }
            $object = [pscustomobject]@{
                'bar' = 1
            }
            $mandatory = $true

            { Validate-Object -Prototype $prototype -TargetObject $object -Mandatory:$mandatory } | Should -Throw "Key 'foo' is missing"
        }

        It 'hashtable' {
            $prototype = @{
                'foo' = 1
            }
            $object = @{
                'bar' = 1
            }
            $mandatory = $true

            { Validate-Object -Prototype $prototype -TargetObject $object -Mandatory:$mandatory } | Should -Throw "Key 'foo' is missing"
        }

        It 'ordered hashtable' {
            $prototype = [ordered]@{
                'foo' = 1
            }
            $object = [ordered]@{
                'bar' = 1
            }
            $mandatory = $true

            { Validate-Object -Prototype $prototype -TargetObject $object -Mandatory:$mandatory } | Should -Throw "Key 'foo' is missing"
        }

    }

}
