$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "Get-VariantsPrototype" -Tag 'Unit' {

    Context 'Behavior' {

        It 'Returns a prototype' {
            $result = Get-VariantsPrototype

            $result | Should -Not -Be $null
        }

    }

}
