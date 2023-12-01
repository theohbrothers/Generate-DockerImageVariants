$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "Get-Definition" -Tag 'Unit' {

    BeforeEach {
        $drive = Convert-Path 'TestDrive:\'
        $definitionFile = Join-Path $drive 'foo.ps1'
    }

    Context 'Parameter' {

        It 'Should throw an exception if variableName is empty' {
            $path = $drive
            $variableName = ''
            { Get-Definition -Path $path -VariableName $variableName } | Should -Throw # 'null'
        }

    }

    Context 'Behavior' {

        It 'Should throw on errors' {
            '{' | Out-File $definitionFile -Encoding utf8 -Force -Append

            {
                Get-Definition -Path $template 2>$null
            } | Should -Throw
        }

        It 'Returns variable in definition file' {
            $definitionFileContent = '$foo = @()'
            $definitionFileContent | Out-File $definitionFile -Encoding utf8 -Force

            $result = Get-Definition -Path $definitionFile -VariableName foo

            $result | Should -Be @()

            $result = Get-Definition -Path $definitionFile -VariableName foo -Optional

            $result | Should -Be @()
        }

        It 'Throws if variable is undefined in definition file' {
            $definitionFileContent = ''
            $definitionFileContent | Out-File $definitionFile -Encoding utf8 -Force

            { Get-Definition -Path $definitionFile -VariableName foo 2>$null } | Should -Throw
        }

        It 'Returns variable if optional variable is undefined in definition file' {
            $definitionFileContent = ''
            $definitionFileContent | Out-File $definitionFile -Encoding utf8 -Force

            $result = Get-Definition -Path $definitionFile -VariableName foo -Optional

            $result | Should -Be $null
        }

        It 'throws exception on errors in definition file' {
            $definitionFileContent = 'zzz'
            $definitionFileContent | Out-File $definitionFile -Encoding utf8 -Force

            { Get-Definition -Path $definitionFile -VariableName foo 2>&1 } | Should -Throw # '*zzz*'
        }

    }

}
