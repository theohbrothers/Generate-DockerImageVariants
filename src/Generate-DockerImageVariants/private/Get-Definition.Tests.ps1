$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "Get-Definition" -Tag 'Unit' {

    Context 'Parameter' {

        $drive = Convert-Path 'TestDrive:\'

        It 'Should throw an exception if variableName is empty' {
            $path = $drive
            $variableName = ''
            { Get-Definition -Path $path -VariableName $variableName } | Should -Throw 'null'
        }

    }

    Context 'Behavior' {

        BeforeEach {
            $drive = Convert-Path 'TestDrive:\'
            $definitionFile = Join-Path $drive 'foo.ps1'
        }

        It 'Returns definition variable' {
            $definitionFileContent = '$VARIANTS = @()'
            $definitionFileContent | Out-File $definitionFile -Encoding utf8 -Force

            $result = Get-Definition -Path $definitionFile -VariableName VARIANTS

            $result | Should -Be @()
        }

        It 'throws exception on errors in definition file' {
            $definitionFileContent = 'zzz'
            $definitionFileContent | Out-File $definitionFile -Encoding utf8 -Force

            { Get-Definition -Path $definitionFile -VariableName VARIANTS 2>&1 } | Should -Throw 'zzz'
        }

    }

}
