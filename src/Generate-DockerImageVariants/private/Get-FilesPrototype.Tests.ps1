$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"


Describe "Get-FilesPrototype" -Tag 'Unit' {

    Context 'Behavior' {

        It 'Returns a prototype' {
            $result = Get-FilesPrototype

            $result | Should -Not -Be $null
        }

    }

}
