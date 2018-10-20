# Generate-DockerImageVariants

A Powershell Module to easily generate Docker image variants' build context files

It may also be used to generate other repository files.

## How to use

1. [Install](https://docs.microsoft.com/en-us/powershell/developer/module/installing-a-powershell-module#install-modules-in-psmodulepath) the `Generate-DockerImageVariants` Powershell Module

2. Create a generate folder in repo `C:/my-project/generate`, with definition files `VARIANTS.ps1` and `FILES.ps1` in the `definitions` folder.

3. Create your templates in the `templates` folder.

4. Run `Import-Module Generate-DockerImageVariants; Generate-DockerImageVariants C:/my-project` to generate the files.

## Prerequisite files / folders

`definitions` - the folder contains the `VARIANTS.ps1` and the `FILES.ps1` generation definitions
   -  `VARIANTS.ps1` - a generation definition file containing definitions of the image variants and defintions of the template of each file to be included in the image build context.
   - `FILES.ps1` - a generation definition file containing definitions of the project files you want to generate.

`templates` - the folder where you store your templates used for generating files according to your generation definitions

## Variables available during generation of image build context files and repository files

`$VARIANT` object will contain these properties. The useful properties are the variant metadata:

```powershell
$VARIANT = @{
    # Variant Metadata
    tag = 'sometag'
    distro = 'somedistro'
    tag_without_distro = 'sometag'
    build_dir_rel = './variants/distro/builddirectory'
    build_dir = '/full/path/to/variants/distro/builddirectory'
    version = $VARIANTS_VERSION

    # Variants Build context template definition
    buildContextFiles = @{
        templates = @{
            'Dockerfile' = @{
                common = $false     #
                includeHeader = $true
                includeFooter = $true
                passes = @(
                    @{
                        variables = @{
                            maintainer = 'foo'
                        }
                    }
                    @{
                        variables = @{
                            zzz = 'bar'
                        }
                        generatedFileNameOverride = 'Dockerfile.zzz'
                    }
                )
            }
        }
        copies = @(
            '/app'
        )
    }
}
```

Also, the `$PASS_VARIABLES` hashtable in available in each template-pass (i.e. the processing of a template). Based on the above template definition for `Dockerfile`, the `$PASS_VARIABLE` object for the first template-pass is:

```powershell
@{
    maintainer = 'foo'
}
```

To access the `maintainer` variable, simply use `$PASS_VARIABLES['maintainer']`.

Note: The `$PASS_VARIABLES` hashtable is only available during build-context files generation, and not for repository files generation

## Template file definitions

- `common` -  Specifies whether this file is shared by all distros ( If yes, has to be present in `./templates`. If not, has to be present in `./templates/<file>/<distro>/` if there's a variant distro defined, or else has to be present in `./templates/<file>/` )

- `includeHeader` - Specifies to include file called `<file>.header.ps1`. Location determined by `common`

- `includeFooter` - Specifies to include file called `<file>.footer.ps1`. Location determined by `common`

- `passes` - An array of passes that the template will go through. Each pass will generate a single file.

### Template-pass configuration of a template file

Each pass processes a `<file>.ps1` template and generates a single file.  Configuration for that pass is specified by properties.

```powershell
@{
    variables = @{
        'foo' = 'bar'
    }
    generatedFileNameOverride = 'Dockerfile.dev'
}
```

During each pass, a hashtable called `$PASS_VARIABLES` will contain the above-defined variables. For instance, the value of `$PASS_VARIABLES['foo']` will be `bar`. The final generated file will be called `Dockerfile.dev`.

## Copy files instead of Template-passing

Generation of a build context might not always involve processing templates.

To copy a file, simply use the property `copies`

```powershell
    buildContextFiles = @{
        copies = @(
            '/app'
        )
    }
```

This will copy all descending files/folders of the `/app` folder located at the base of the project into the image build directory.

## Generate project files (instead of build-context files)

The generation of files from templates is not limited to populating a build context with files. Whereas the `$VARIANTS` definition object in `VARIANTS.ps1` is used for the generation of build contexts files, the `$FILES` definition object in `FILES.ps1` is used for generation of any file in the project repository.

The `$FILES` definition object may be defined as such:

```powershell
# Files' definition
$FILES = @(
    '.gitlab-ci.yml'
    'README.md'
)

```

Two files need to reside in `./templates` directory:

- `.gitlab-ci.yml.ps1`

- `README.md.ps1`

The generation results in two files, relative to the base of the project:

- `/.gitlab-ci.yml`
- `/README.md`