# Generate-DockerImageVariants

A Powershell Module to easily generate a repository populated with Docker image variants.

### Command line

```powershell
NAME
    Generate-DockerImageVariants

SYNTAX
    Generate-DockerImageVariants [[-ProjectPath] <string>] [-Version]  [<CommonParameters>]


PARAMETERS
    -ProjectPath <string>

    -Version

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).
```

## How to use

1. [Install](https://docs.microsoft.com/en-us/powershell/developer/module/installing-a-powershell-module#install-modules-in-psmodulepath) the `Generate-DockerImageVariants` Powershell Module

2. Create a folder called `/generate` in a repo

3. Create a definitions folder `/generate/definitions`, containing two files `VARIANTS.ps1` and `FILES.ps1` populated with definitions.

4. Create a templates folder called `/generate/templates` and create  template files. E.g. `/generate/templates/Dockerfile.ps1`

5. Run the following to generate the files.

    ```powershell
    Generate-DockerImageVariants C:/my-variants-project
    ```
6. Result:
    - Build Context files are generated in `/variants/<distro>`
    - Project files are generated in the same directory structure as defined in `$FILES.ps1`

## Prerequisite files / folders

A single folder named `/generate` at the base of the repository will hold all the definition and template files. The folder stucture looks like this:

`/generate/definitions` - the folder contains the `VARIANTS.ps1` and the `FILES.ps1` generation definitions
   - `VARIANTS.ps1` - a generation definition file containing definitions of the image variants and definitions of the template of each file to be included in the image build context.
   - `FILES.ps1` - an *optional* generation definition file containing definitions of the repository files you want to generate.

`/generate/templates` - the folder with your templates (`.ps1` files) used for generating files according to your generation definitions

At minimum, the `VARIANTS.ps1` definition file should contain the `$VARIANTS` definition like this:

```powershell
# Docker image variants' definitions
$VARIANTS = @(
    # Our first variant
    @{
        # The tag is the Docker Image tag.
        # When the tag contains words delimited by '-', it known as component-chaining. This means the 'perl' and 'git' templates
        # will be processed.
        tag = 'perl-git'
        # Defining a distro is optional. If you dont define a distro, you assume all your variants use the same distro.
        # In contrast, if you do define a distro, variants will be generated in their respective distro folder, in this case, 'alpine'
        distro = 'alpine'

        # Our Build context definition
        buildContextFiles = @{
            templates = @{
                # We want to generate the file 'Dockerfile'
                'Dockerfile' = @{
                    # Specifies that the template file should not be shared among distros
                    common = $false
                    passes = @(
                        # The first template-pass
                        @{
                            # Customize the pass here
                        }
                    )
                }
            }
        }
    }
}
```

Using the `FILES.ps1` definition file is optional, but if used, at minimum it should look like:

```powershell
# Files' definition
$FILES = @(
    'README.md'
)
```

With these files, execute the following
```powershell
Generate-DockerImageVariants C:/my-variants-project`
```

This will produce a generated variant build context in `/variants/alpine/perl-git` and a file `README.md`, both at the base of the project.

Two examples have been included in `examples` folder: one generates a simple repo with few variants, and the other generates a more complex repo with more variants.

## Customizing a Variant's Build Context file's generation

This is the `buildContextFiles` property of the `$VARIANT` object. It includes these properties:

- `common` - (Optional) Specifies whether this file is shared by all distros ( If yes, has to be present in `/generate/templates`. If not, has to be present in `/generate/templates/<file>/<distro>/` if there's a variant `distro` defined, or has to be present in  `/generate/templates/<file>/` if no variant `distro` is defined.)

- `includeHeader` - (Optional) Specifies to include file called `<file>.header.ps1`. Location determined by `common`

- `includeFooter` - (Optional) Specifies to include file called `<file>.footer.ps1`. Location determined by `common`

- `passes` - (Mandatory) An array of passes that the template will go through. Each pass will generate a single file.

Each pass processes a `<file>.ps1` template and generates a single file. A pass can be configured with the `variables` and `generatedFileNameOverride` properties:

```powershell
$VARIANTS = @(
    # Our first variant
    @{
        tag = 'perl-git'
        distro = 'alpine'

        buildContextFiles = @{
            templates = @{
                'Dockerfile' = @{
                    common = $false
                    passes = @(
                        # The first pass. The Generated file name will be 'Dockerfile'
                        @{
                            # Customize the pass here
                            variables = @{
                                'foo' = 'bar'
                            }
                        }
                        # The second pass. The Generated file name will be 'Dockerfile.dev'
                        @{
                            # Customize the pass here
                            variables = @{
                                'foo2' = 'bar2'
                            }
                            generatedFileNameOverride = 'Dockerfile.dev'
                        }
                    )
                }
            }
        }
    }
}
```

During each pass, a hashtable called `$PASS_VARIABLES` will be in the scope of the processed `Dockerfile.ps1` template. For instance, in the first pass, the value of `$PASS_VARIABLES['foo']` will be `bar`, and the file `Dockerfile` will be generated in the variant's build context. In the second pass, the value of `$PASS_VARIABLES['foo2']` will be `bar2`, and the file `Dockerfile.dev` will be generated in the same build context.

## Variables available during a template-pass (generation of a file)

Each pass processes a `<file>.ps1` template and generates a single file. The following variables are available in the scope of the `<file>.ps1` file:
- `$VARIANT` - the variant object
- `$PASS_VARIABLES` - a hashtable containing the custom variables defined in the Variant's Build context template definition

## Copy files instead of Template-passing

The generation of a build context might not always involve processing templates. Sometimes we simply want to copy a file into the build context.

To copy a file, simply use the property `copies` in `buildContextFiles`:

```powershell
$VARIANTS = @(
    # Our first variant
    @{
        tag = 'perl-git'
        distro = 'alpine'

        buildContextFiles = @{
            # An array of files to copy to the Build Context
            copies = @(
                '/app'
            )
        }
    }
}
```

This will copy all descending files/folders of the `/app` folder located relative to the *base* of the repository into the to-be-generated `perl-git` variant's build directory (`/variants/alpine/perl-git`) as `/variants/alpine/perl-git/app`.

## Advanced: Generate a single variant with Component-chaining

When a variant's `tag` contains words delimited by `-`, it known as **component-chaining**. The result of processing each component template will be concatanated to form the final generated file. For instance, suppose you want a variant that generates a Dockerfile that installs `perl` and `git`, in `DEFINITIONS.ps1`:

```powershell
$VARIANTS = @(
    # Our first variant
    @{
        # The tag is the Docker Image tag.
        # When the tag contains words delimited by '-', it known as component-chaining. This means the 'perl' and 'git' templates
        # will be processed.
        tag = 'perl-git'
        distro = 'alpine'

        buildContextFiles = @{
            templates = @{
                # We want to generate the file 'Dockerfile'
                'Dockerfile' = @{
                    # Specifies that the template file should not be shared among distros
                    common = $false
                    passes = @(
                        # The first template-pass
                        @{
                            # Customize the pass here
                        }
                    )
                }
            }
        }
        ...
    }
)
```

The template pass to generate `Dockerfile` proceeds as such:
1. The file `/generate/templates/Dockerfile/alpine/Dockerfile.header.ps1` is processed
2. Now the files `/generate/templates//Dockerfile/alpine/perl/perl.ps1` and `/generate/templates/Dockerfile/alpine/git/git.ps1` are processed in the left-to-right order.
3. The file `/generate/templates//Dockerfile/alpine/Dockerfile.footer.ps1` is processed

**Note: If a variant's `tag` consist of a word that matches the variant's `distro`, there will not be a component called `distro`.** For instance, in the above example, if the `tag` is `perl-git-alpine`, there will still only be two components `perl` and `git`. `alpine` will not be considered a component. This will then allow variants to be tagged with the `distro` keyword without having to process a 'phantom' distro template file.

Upon generation, **one** variant namely `perl-git` will have its build context generated in its corresponding folder, relative to the base of the project: `/variants/alpine/perl-git`

See the `examples` folder of this module's repository for a real example.

### Generate multiple variants

The previous example shows show to generate a single variant.

This example shows how to generate three variants.

To generate multiple image variants, all sharing a common `buildContextFiles` template, declare this in `DEFINITIONS.ps1`, declaring `buildContextFiles` property in a special hashtable `$VARIANTS_SHARED`

```powershell
# Docker image variants' definitions
$VARIANTS = @(
    # Our first variant
    @{
        tag = 'perl-git'
        distro = 'alpine'
    }
    # Our second variant
    @{
        tag = 'perl'
        distro = 'alpine'
    }
    # Our third variant
    @{
        tag = 'git'
        distro = 'alpine'
    }
}

# This is a special variable that sets a common buildContextFiles definition for all variants
# Docker image variants' definitions (shared)
$VARIANTS_SHARED = @{
    buildContextFiles = @{
        templates = @{
            # We want to generate the file 'Dockerfile'
            'Dockerfile' = @{
                # Specifies that the template file should not be shared among distros
                common = $false
                passes = @(
                    # The first template-pass
                    @{
                        # Customize the pass here
                    }
                )
            }
        }
    }
}
```

Upon generation, **three** variants namely `perl-git`, `perl`, and `git` will have their build contexts generated in their corresponding folders, relative to the base of the project:

- `/variants/alpine/perl-git`
- `/variants/alpine/perl`
- `/variants/alpine/git`

See the `examples` folder of this module's repository for a real example.

## Optional: Generate repository files

As described in the present repository's description, this module is able to generate a complete repository:
1) the Docker Image variants which has been covered above
2) other repository files.

To generate the other repository files, first, define the `$FILES` array in the `FILES.ps1`file:

```powershell
# Files' definition
$FILES = @(
    '.gitlab-ci.yml'
    'README.md'
)
```

Next, create two template files in the `/generate/templates` directory:

- `.gitlab-ci.yml.ps1`
- `README.md.ps1`

Now, the generation results in two files, relative to the base of the project:

- `/.gitlab-ci.yml`
- `/README.md`

The variables `$VARIANTS` will be available during the processing of the template files `/generate/templates/.gitlab-ci.yml.ps1` and `/generate/templates/README.md.ps1`.

## Appendix

### Variant object properties

A `$VARIANT` definition will contain these properties.

```powershell
$VARIANT = @{
    # Variant Metadata
    tag = 'somecomponent1-somecomponent2-somedistro'
    distro = 'somedistro'
    tag_as_latest = $true                                   # Automatically populated if unspecified
    tag_without_distro = 'somecomponent1-somecomponent2'    # Automatically populated
    components = @( 'somecomponent1'                        # Automatically populated
                    'somecomponent2' )
    build_dir_rel = './variants/distro/builddirectory'      # Automatically populated
    build_dir = '/full/path/to/variants/distro/builddirectory'   # Automatically populated

    # Build context template definition
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
                            foo = 'bar'
                        }
                        generatedFileNameOverride = 'Dockerfile.dev'
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

### Debugging the variants / file definitions

If any definitions in `/generate/definitions/VARIANTS.ps1` or `/generate/definitions/FILES.ps1` are incorrect, the module will throw a terminating error.

To find out which part of your defintion is wrong, use the `-Verbose` switch. It gives a trace of the validation steps, for instance, if a variant was defined with an incorrect type (expected to be `hashtable`):

```powershell
$VARIANTS = @(
    1
    @{
        tag = 'perl'
        distro = 'alpine'
    }
}
```

the validation trace will be like this:

```powershell
Generate-DockerImageVariants C:/my-variants-project -Verbose
VERBOSE: Validating TargetObject '1 System.Collections.Hashtable System.Collections.Hashtable System.Collections.Hashtable System.Collections.Hashtable System.Collections.Hashtable System.Collections.Hashtable' of type 'Object[]' and basetype 'array'       against Prototype 'System.Collections.Hashtable' of type 'Object[]' and basetype 'array'
VERBOSE:        Validating TargetObject '1' of type 'Int32' and basetype 'System.ValueType'             against Prototype 'System.Collections.Hashtable' of type 'Hashtable' and basetype 'System.Object'
WARNING: Failed with errors. Exception: Type System.Int32 is invalid! It should be of type 'System.Collections.Hashtable'.
```

This demonstrates that a variant definition has to be of type `hashtable`. The value `1` is of type `int32`, and hence is invalid.
