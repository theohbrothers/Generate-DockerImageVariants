$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "Get-ContentFromTemplate" -Tag 'Unit' {

    $drive = Convert-Path 'TestDrive:\'
    $templateFileContent = "12345"
    $templateFile = Join-Path $drive 'template.ps1'
    $templateFileContent | Out-File $templateFile -Encoding utf8 -Force

    Context 'Behavior' {

        It 'Gets content from a template' {
            $content = Get-ContentFromTemplate -Path $templateFile
            $content | Should -Be $templateFileContent

        }

        It 'Prepends newlines to content from a template' {
            $prependNewLines = 10

            $content = Get-ContentFromTemplate -Path $templateFile -PrependNewLines $prependNewLines

            $expectedContent = "$("`n" * $prependNewLines)$templateFileContent"
            $content | Should -Be $expectedContent
        }

    }

}
