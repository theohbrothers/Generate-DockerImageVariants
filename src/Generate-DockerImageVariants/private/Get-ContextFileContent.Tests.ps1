$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "Get-ContextFileContent" -Tag 'Unit' {

    Context 'Parameters' {

        It 'Should throw an exception if template is empty' {
            $template = @{}

            { Get-ContextFileContent -Template $template } | Should -Throw # '*null*'
        }

        It 'Should not throw an exception if templatePassVariables is empty' {
            $template = @{
                includeHeader = $false
                templateDirectory = 'foo'
                includeFooter = $false
            }
            $templatePassVariables = @{}
            Mock Test-Path { $true }
            function Get-ContentFromTemplate {}

            { Get-ContextFileContent -Template $template -TemplatePassVariables $templatePassVariables } | Should -Not -Throw
        }

    }

    Context 'Behavior' {

        BeforeEach {
            function Get-ContentFromTemplate {
                param (
                    $Path
                )
                "Some content from $Path"
            }
            function Test-Path {}
        }

        It 'Returns header content' {
            $template = @{
                file = 'foo'
                templateDirectory = 'bar'
                includeHeader = $true
            }
            Mock Test-Path { $true }

            $content = Get-ContextFileContent -Template $template
            $content[0].Replace('\', '/') | Should -Match "Some content from bar/foo.header.ps1"
            $content[1].Replace('\', '/') | Should -Match "Some content from bar/foo.ps1"
        }

        It 'Returns body content (based on template)' {
            $template = @{
                file = 'foo'
                templateDirectory = 'bar'
            }
            Mock Test-Path { $true }

            $content = Get-ContextFileContent -Template $template
            $content.Replace('\', '/') | Should -Match "Some content from bar/foo.ps1"
        }

        It 'Returns body content (based on subtemplates)' {
            $template = @{
                file = 'foo'
                templateDirectory = 'bar'
                subTemplates = @(
                    'john'
                    'doe'
                )
            }
            Mock Test-Path { $true }

            $content = Get-ContextFileContent -Template $template
            $content[0].Replace('\', '/') | Should -Match "Some content from bar/john/john.ps1"
            $content[1].Replace('\', '/') | Should -Match "Some content from bar/doe/doe.ps1"
        }

        It 'Returns footer content' {
            $template = @{
                file = 'foo'
                templateDirectory = 'bar'
                includeFooter = $true
            }
            Mock Test-Path { $true }

            $content = Get-ContextFileContent -Template $template
            $content[0].Replace('\', '/') | Should -Match "Some content from bar/foo.ps1"
            $content[1].Replace('\', '/') | Should -Match "Some content from bar/foo.footer.ps1"
        }

        It 'Returns header, body (based on template), and footer content' {
            $template = @{
                file = 'foo'
                templateDirectory = 'bar'
                includeHeader = $true
                includeFooter = $true
            }
            Mock Test-Path { $true }

            $content = Get-ContextFileContent -Template $template
            $content[0].Replace('\', '/') | Should -Match "Some content from bar/foo.header.ps1"
            $content[1].Replace('\', '/') | Should -Match "Some content from bar/foo.ps1"
            $content[2].Replace('\', '/') | Should -Match "Some content from bar/foo.footer.ps1"
        }

        It 'Returns header, body (based on subtemplates), and footer content' {
            $template = @{
                file = 'foo'
                templateDirectory = 'bar'
                includeHeader = $true
                includeFooter = $true
                subTemplates = @(
                    'john'
                    'doe'
                )
            }
            Mock Test-Path { $true }

            $content = Get-ContextFileContent -Template $template
            $content[0].Replace('\', '/') | Should -Match "Some content from bar/foo.header.ps1"
            $content[1].Replace('\', '/') | Should -Match "Some content from bar/john/john.ps1"
            $content[2].Replace('\', '/') | Should -Match "Some content from bar/doe/doe.ps1"
            $content[3].Replace('\', '/') | Should -Match "Some content from bar/foo.footer.ps1"
        }

    }

}
