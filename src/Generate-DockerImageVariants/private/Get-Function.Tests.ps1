$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "Get-Function" -Tag 'Unit' {

    BeforeEach {
        $drive = Convert-Path 'TestDrive:\'
        $definitionFile = Join-Path $drive 'foo.ps1'
        New-Item $definitionFile -ItemType File -Force
    }

    Context 'Behavior' {

        It 'Should throw on errors' {
            '{' | Out-File $definitionFile -Encoding utf8 -Force -Append

            {
                Get-Function -Path $definitionFile 2>$null
            } | Should -Throw
        }

        It 'Returns path of file' {
            $f = Get-Function -Path $definitionFile

            $f | Should -Be $definitionFile
        }

    }

}
