$GENERATE_DOCKERIMAGEVARIANTS_VERSION = 'v0.2.0'
function Get-ContentFromTemplate {
    param (
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $_ })]
        [string]$Path
    ,
        [ValidateRange(1,100)]
        [int]$PrependNewLines
    )
    $content = & $Path
    if ($PrependNewLines -gt 0) {
        1..($PrependNewLine) | % {
            $content = "`n$content"
        }
    }
    $content
}

function Get-ContextFileContent {
    param (
        [ValidateNotNullOrEmpty()]
        [string]$TemplateFile
    ,
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $_ })]
        [string]$TemplateDirectory
    ,
        [switch]$Header
    ,
        [array]$SubTemplates
    ,
        [switch]$Footer
    ,
        [hashtable]$TemplatePassVariables
    )

    # This special variable will be used throughout templates
    $PASS_VARIABLES = if ($TemplatePassVariables) { $TemplatePassVariables } else { @{} }

    $params = @{}
    if ( $Header ) {
        Get-ContentFromTemplate -Path "$TemplateDirectory/$TemplateFile.header.ps1"
        $params['PrependNewLines'] = 2
    }

    if ( $SubTemplates -is [array] -and $SubTemplates.Count -gt 0) {
        $SubTemplates | % {
            Get-ContentFromTemplate -Path "$TemplateDirectory/$_/$_.ps1" @params
        }
    }else {
        Get-ContentFromTemplate -Path "$TemplateDirectory/$TemplateFile.ps1" @params
    }

    if ( $Footer ) {
        Get-ContentFromTemplate -Path "$TemplateDirectory/$TemplateFile.footer.ps1" @params
    }
}

# For validation of the $VARIANTS object
$VARIANTS_PROTOTYPE = @(
    @{
        tag = ""
        distro = ""
        tag_as_latest = $false
        submodules = @{
            foo = "some_git_url"
        }
        tag_without_distro = ""
        components = @( 'foo' )
        build_dir_rel = ""
        build_dir = ""
        buildContextFiles = @{
            templates = @{
                'foo' = @{
                    common = $false
                    includeHeader = $false
                    includeFooter = $false
                    passes = @(
                        @{
                            variables = @{
                                foo = 'bar'
                            }
                        }
                    )
                }
            }
        }
    }
)
# For validation of the $FILES object
$FILES_PROTOTYPE = @( 'foo' )

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
        [object]$TargetObject
    ,
        [Parameter(Mandatory=$true, ParameterSetName='Pipeline')]
        [Parameter(Mandatory=$false, ParameterSetName='Default')]
        [switch]$Mandatory
    )
    process {
        "Validating TargetObject '$Targetobject' of type '$( $Targetobject.GetType().Name )' and basetype '$( $Targetobject.GetType().BaseType )'`tagainst Prototype '$Prototype' of type '$( $Prototype.GetType().Name )' and basetype '$( $Prototype.GetType().BaseType )'" | Write-Verbose
        if ( $Prototype.GetType().FullName -ne $TargetObject.GetType().FullName ) {
            throw "Type $( $TargetObject.GetType().FullName ) is invalid! It should be of type '$( $Prototype.GetType().FullName )'"
        }

        if ( $Prototype -is [string] ) {
            # Nothing
        }elseif ( $Prototype -is [array] ) {
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
                    if ($_targetObject -eq $null) {
                        return
                    }
                }
                # Ensure we got all properties
                if ($_targetObject -eq $null) {
                    throw "'$Key' is missing"
                }
                if ( $TargetObject -isnot [bool] ) {
                    throw "'$Key' should be of type [bool]"
                }
                return
            }elseif ( $Prototype -is [psobject] -or
                 $Prototype.GetType().FullName -match '^System\.Collections\.Hashtable$|^System\.Collections\.Specialized\.OrderedDictionary$'
               ) {
                # Cov
                $tmpPrototype = if ( $Prototype -is [psobject] ) {
                                    $hash = @{}
                                    $Prototype.psobject.properties | % { $hash[$_.Name] = $_.Value }
                                    $hash
                                }else {
                                    $Prototype
                                }
                $tmpPrototype.GetEnumerator() | % {
                    $Key = $_.Name
                    $_prototype = $tmpPrototype[$Key]
                    $_targetObject = $TargetObject[$Key]

                    if (!$Mandatory) {
                        if ($_targetObject -eq $null) {
                            return
                        }
                    }

                    # Ensure we got all properties
                    if ($_targetObject -eq $null) {
                        throw "'$Key' is missing"
                    }

                    Validate-Object -Prototype $_prototype -TargetObject $_targetObject -Mandatory:$Mandatory
                }
            }else {
                throw "Type $( $Prototype.Gettype().FullName ) is invalid. It must be one of the following: bool, string, array, hashtable, psobject"
            }
        }
    }
}

function New-GenerationFolder {
    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $_ })]
        [string]$ProjectPath
    )

    # Create definitions and templates folders
    $GENERATE_BASE_DIR, $GENERATE_DEFINITIONS_DIR, $GENERATE_TEMPLATES_DIR | % {
        $destinationFullName = $_
        if (Test-Path -LiteralPath $destinationFullName) {
            "Not creating folder $destinationFullName because a file or folder already exists with that name." | Write-Host -ForegroundColor Magenta
        }else {
            "Creating folder $destinationFullName" | Write-Host -ForegroundColor Green
            $item = New-Item $destinationFullName -ItemType Container -Force
        }
    }

    # Create definition files
    Get-ChildItem $MODULE_SAMPLES_GENERATE_DEFINITIONS_DIR -Include '*.ps1' -Recurse | % {
        $sourceItem = $_
        $destinationFullName = Join-Path $GENERATE_DEFINITIONS_DIR $sourceItem.Name
        if (Test-Path -LiteralPath $destinationFullName) {
            "Not creating definition file $destinationFullName because a file or folder already exists with that name." | Write-Host -ForegroundColor Magenta
        }else {
            "Creating definition file $destinationFullName" | Write-Host -ForegroundColor Green
            if ($item = New-Item $destinationFullName -ItemType File) {
                Get-Content $sourceItem.FullName | Out-File $item.FullName -Encoding utf8
            }
        }
    }

    # Create template files
    Get-ChildItem $MODULE_SAMPLES_GENERATE_TEMPLATES_DIR -Include '*.ps1' -Recurse | % {
        $sourceItem = $_
        $destinationFullName = Join-Path $GENERATE_TEMPLATES_DIR $sourceItem.Name
        if (Test-Path -LiteralPath $destinationFullName) {
            "Not creating template file $destinationFullName because a file or folder already exists with that name." | Write-Host -ForegroundColor Magenta
        }else {
            "Creating template file $destinationFullName" | Write-Host -ForegroundColor Green
            if ($item = New-Item $destinationFullName -ItemType File) {
                Get-Content $sourceItem.FullName | Out-File $item.FullName -Encoding utf8
            }
        }
    }
}

# This function generates the each Docker image variants' build context files' in ./variants/<variant>, or if a distro is specified, in ./variants/<distro>/<variant>
function Generate-DockerImageVariants {
    [CmdletBinding(DefaultParameterSetName='Generate')]
    param (
        [Parameter(ParameterSetName='Init',Position=0)]
        [ValidateNotNullOrEmpty()]
        [switch]$Init
    ,
        [Parameter(ParameterSetName='Init',Position=1)]
        [Parameter(ParameterSetName='Generate',Position=0)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $_ })]
        [string]$ProjectPath
    ,
        [Parameter(ParameterSetName='Version')]
        [switch]$Version
    )
    begin {
        # PS Defaults
        $PSDefaultParameterValues['Get-Content:Force'] = $true
        $PSDefaultParameterValues['Get-Item:Force'] = $true
        $PSDefaultParameterValues['Get-ChildItem:Force'] = $true
        $PSDefaultParameterValues['Out-File:Force'] = $true
    }
    process {
        if ($PSCmdlet.ParameterSetName -eq 'Version') {
            $GENERATE_DOCKERIMAGEVARIANTS_VERSION
            return
        }
        try {
            $PROJECT_BASE_DIR = Resolve-Path $ProjectPath | Select-Object -ExpandProperty Path
            $GENERATE_BASE_DIR = Join-Path $PROJECT_BASE_DIR 'generate'
            $GENERATE_DEFINITIONS_DIR = Join-Path $GENERATE_BASE_DIR "definitions"
            # $GENERATE_DEFINITIONS_FILES = Join-Path $GENERATE_DEFINITIONS_DIR 'FILES.ps1'
            # $GENERATE_DEFINITIONS_VARIANTS = Join-Path $GENERATE_DEFINITIONS_DIR 'VARIANTS.ps1'
            $GENERATE_TEMPLATES_DIR = Join-Path $GENERATE_BASE_DIR "templates"

            $MODULE_BASE_DIR = $PSScriptRoot
            $MODULE_SAMPLES_DIR = Join-Path $MODULE_BASE_DIR 'samples'
            $MODULE_SAMPLES_GENERATE_DIR = Join-Path $MODULE_SAMPLES_DIR 'generate'
            $MODULE_SAMPLES_GENERATE_DEFINITIONS_DIR = Join-Path $MODULE_SAMPLES_GENERATE_DIR 'definitions'
            # $MODULE_SAMPLES_GENERATE_DEFINITIONS_FILES = Join-Path $MODULE_SAMPLES_GENERATE_DEFINITIONS_DIR 'FILES.ps1'
            # $MODULE_SAMPLES_GENERATE_DEFINITIONS_VARIANTS = Join-Path $MODULE_SAMPLES_GENERATE_DEFINITIONS_DIR 'VARIANTS.ps1'
            $MODULE_SAMPLES_GENERATE_TEMPLATES_DIR = Join-Path $MODULE_SAMPLES_GENERATE_DIR 'templates'

            if ($PSCmdlet.ParameterSetName -eq 'Init') {
                New-GenerationFolder -ProjectPath $PROJECT_BASE_DIR
            }

            if ($PSCmdlet.ParameterSetName -eq 'Generate') {

                # Get variants' definition
                . ( Join-Path $GENERATE_DEFINITIONS_DIR "VARIANTS.ps1" ) > $null

                # Get files' definition (optional)
                if ( Test-Path ( Join-Path $GENERATE_DEFINITIONS_DIR "FILES.ps1" ) ) {
                    . ( Join-Path $GENERATE_DEFINITIONS_DIR "FILES.ps1" ) > $null
                }

                # Normalize globals
                $VARIANTS = if ( $VARIANTS -isnot [array] ) { @() } else { ,$VARIANTS }
                $VARIANTS_SHARED = if ( $VARIANTS_SHARED -isnot [hashtable] ) { @{} } else { $VARIANTS_SHARED }
                $FILES = if ( $FILES -isnot [array] ) { ,@() } else { ,$FILES }

                # Validate the VARIANTS and FILES defintion objects
                Validate-Object -Prototype $VARIANTS_PROTOTYPE -TargetObject $VARIANTS -Mandatory:$false
                if ($FILES) {
                    Validate-Object -Prototype $FILES_PROTOTYPE -TargetObject $FILES -Mandatory:$false
                }

                # Intelligently add properties
                $VARIANTS | % {
                    $VARIANT = $_
                    $VARIANTS_SHARED.GetEnumerator() | % {
                        $VARIANT[$_.Name] =  $_.Value
                    }
                    $VARIANT['tag_as_latest'] = if ($VARIANT.Contains('tag_as_latest')) { $variant['tag_as_latest'] } else { $false }
                    $VARIANT['submodules'] = if ( $VARIANT['submodules'] -is [hashtable] -and ($VARIANT['submodules'].Values | % { $_ -is [string] }) ) {
                                                $VARIANT['submodules']
                                            } else { @{} }
                    $VARIANT['tag_without_distro'] = if ( $VARIANT['distro'] ) {
                                                        # The variant's build directory name, stripped of the distro name if present
                                                        # E.g. ':git-perl-alpine' or 'alpine-git-perl' becomes ':git-perl'
                                                        $variant_distro_regex = [regex]::Escape( $VARIANT['distro'] )
                                                        if ( $VARIANT['tag'] -match "^(.*)$variant_distro_regex(.*)$" ) {
                                                            "$( $matches[1] )-$( $matches[2] )".Trim('-')
                                                        }else {
                                                            $VARIANT['tag']
                                                        }
                                                    }else {
                                                            $VARIANT['tag']
                                                    }
                    # Dynamically determine the components from the tag of the variant. (E.g. 'foo-bar' have 2 componets: 'foo' and 'bar')
                    $VARIANT['components'] = @(
                                                $VARIANT['tag_without_distro'] -split '-' | % { $_.Trim() } | ? { $_ }
                                            )
                    $VARIANT['build_dir_rel'] = if ( $VARIANT['distro'] ) {
                                                "variants/$( $VARIANT['distro'] )/$( $VARIANT['tag_without_distro'] )"
                                            }else {
                                                "variants/$($VARIANT['tag'])"
                                            }
                    $VARIANT['build_dir'] = Join-Path "$PROJECT_BASE_DIR" $VARIANT['build_dir_rel']
                }

                # Generate each Docker image variant's build context files
                $VARIANTS | % {
                    $VARIANT = $_

                    "Generating variant of name $( $VARIANT['tag'] ), variant dir: $( $VARIANT['build_dir'] )" | Write-Host -ForegroundColor Green
                    "Generating variant of name $( $VARIANT['tag'] ), variant dir: $( $VARIANT['build_dir'] )" | Write-Host -ForegroundColor Green
                    if ( ! (Test-Path $VARIANT['build_dir']) ) {
                        New-Item -Path $VARIANT['build_dir'] -ItemType Directory -Force > $null
                    }

                    # Generate Docker build context files
                    if ( $VARIANT['buildContextFiles'] ) {
                        # Templates
                        if ( $VARIANT['buildContextFiles']['templates'] -and $VARIANT['buildContextFiles']['templates'] -is [hashtable] ) {
                            $VARIANT['buildContextFiles']['templates'].GetEnumerator() | % {
                                $templateFile = $_.Key
                                $templateFileConfig = $_.Value
                                $templateObject = @{
                                    TemplateFile = $templateFile
                                    TemplateDirectory = if ( $templateFileConfig['common'] ) {
                                                            $GENERATE_TEMPLATES_DIR
                                                        }else {
                                                            if ( $VARIANT['distro'] ) {
                                                                "$GENERATE_TEMPLATES_DIR/$templateFile/$( $VARIANT['distro'] )"
                                                            }else {
                                                                "$GENERATE_TEMPLATES_DIR/$templateFile/"
                                                            }
                                                        }
                                    Header = if ( $templateFileConfig['includeHeader'] ) { $true } else { $false }
                                    # Dynamically determine the sub templates from the name of the variant. (E.g. 'foo-bar' will comprise of foo and bar variant sub templates for this template file)
                                    SubTemplates =  if ( ! $templateFileConfig['common'] ) {
                                                        $VARIANT['components']
                                                    }else { @() }
                                    Footer = if ( $templateFileConfig['includeFooter'] ) { $true } else { $false }
                                }

                                $generatedFile = "$( $VARIANT['build_dir'] )/$templateFile"
                                $templateFileConfig['passes'] | % {
                                    $pass = $_
                                    $templateObject['TemplatePassVariables'] = if ( $pass['variables'] ) { $pass['variables'] } else { @() }
                                    $generatedFile = if ( $pass['generatedFileNameOverride'] ) { "$( $VARIANT['build_dir'] )/$( $pass['generatedFileNameOverride'] )" } else { $generatedFile }
                                    $generatedFileContent = Get-ContextFileContent @templateObject
                                    New-Item $generatedFile -ItemType File -Force > $null
                                    $generatedFileContent | Out-File $generatedFile -Encoding Utf8 -Force -NoNewline
                                }
                            }
                        }

                        # Copies
                        if ( $VARIANT['buildContextFiles']['copies'] ) {
                            $VARIANT['buildContextFiles']['copies'] | % {
                                $blob = $_.Trim()
                                # Any blob starting with '/' means we will
                                if ($blob -match '^\/') {
                                    $fullPathBlob = Join-Path $PROJECT_BASE_DIR $blob
                                }else {
                                    $fullPathBlob = "$GENERATE_TEMPLATES_DIR/variants/$( $VARIANT['tag'] )/$blob"
                                }
                                Copy-Item -Path $fullPathBlob -Destination $VARIANT['build_dir'] -Force -Recurse
                            }
                        }
                    }

                }

                # Generate other repo files. E.g. README.md
                foreach ($file in $FILES) {
                    $fileAbsolutePath = [io.path]::Combine($PROJECT_BASE_DIR, $file)
                    $fileParentAbsolutePath = Split-Path $fileAbsolutePath -Parent
                    if ( ! (Test-Path $fileParentAbsolutePath -PathType Container) ) {
                        New-Item $fileParentAbsolutePath -ItemType Directory -Force > $null
                    }
                    Get-ContentFromTemplate -Path (Join-Path $GENERATE_TEMPLATES_DIR "$file.ps1") | Out-File $fileAbsolutePath -Encoding utf8 -NoNewline
                }
            }
        }catch {
            if ($ErrorActionPreference = 'Stop') {
                throw
            }else {
                "Failed with errors. Exception: $( $_.Exception.Message ). Stacktrace: $( $_.ScriptStackTrace )"
            }
        }
    }
}

Export-ModuleMember -Function 'Generate-DockerImageVariants'
