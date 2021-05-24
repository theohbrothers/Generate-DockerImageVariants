# Generate-DockerImageVariants

[![github-actions](https://github.com/theohbrothers/Generate-DockerImageVariants/workflows/ci-master-pr/badge.svg)](https://github.com/theohbrothers/Generate-DockerImageVariants/actions)
[![github-release](https://img.shields.io/github/v/release/theohbrothers/Generate-DockerImageVariants?style=flat-square)](https://github.com/theohbrothers/Generate-DockerImageVariants/releases/)
[![powershell-gallery-release](https://img.shields.io/powershellgallery/v/Generate-DockerImageVariants?logo=powershell&logoColor=white&label=PSGallery&labelColor=&style=flat-square)](https://www.powershellgallery.com/packages/Generate-DockerImageVariants/)

Easily generate a repository populated with Docker image variants.

## Agenda

It is very common to need to have multiple variants of a docker image. This module solves this problem by creating a simple templating framework to generate a full repository containing:

- `Dockerfile` build contexts for variants
- Continuous integration (CI) configuration files to build and push variants' images to a docker registry, and the `README.md` containing the variants' image tags.

Here are some real repositories generated by using this module:

- https://github.com/theohbrothers/docker-ansible
- https://github.com/theohbrothers/docker-alpine
- https://github.com/theohbrothers/docker-easyrsa
- https://github.com/theohbrothers/docker-kubectl
- https://github.com/theohbrothers/docker-openvpn
- https://github.com/theohbrothers/docker-powershell
- https://github.com/theohbrothers/docker-php
- https://github.com/theohbrothers/docker-varnish-agent

## Install

Open [`powershell`](https://docs.microsoft.com/en-us/powershell/scripting/windows-powershell/install/installing-windows-powershell?view=powershell-5.1) or [`pwsh`](https://github.com/powershell/powershell#-powershell) and type:

```powershell
Install-Module -Name Generate-DockerImageVariants -Repository PSGallery -Scope CurrentUser -Verbose
```

If prompted to trust the repository, hit `Y` and `enter`.

## Usage

1. Initialize your repository.

    ```sh
    mkdir -p /path/to/my-project
    ```

2. Initialize the `/generate` folder

    ```powershell
    Import-Module Generate-DockerImageVariants
    cd /path/to/my-project
    Generate-DockerImageVariants . -Init
    ```

   Definition and template files are generated in the `/generate` folder.

    ```sh
    .
    ├── generate
    │   ├── definitions
    │   │   ├── FILES.ps1
    │   │   └── VARIANTS.ps1
    │   └── templates
    │       ├── .gitlab-ci.ps1
    │       ├── Dockerfile.ps1
    │       └── README.md.ps1
    ```

3. Edit the definitions and template files in `/generate`:

4. Generate the variants:

    ```powershell
    cd /path/to/my-project
    Generate-DockerImageVariants .
    ```

   Build contexts of variants are generated in `/variants`.

   The repository tree now looks like:

    ```sh
    .
    ├── generate
    │   ├── definitions
    │   │   ├── FILES.ps1
    │   │   └── VARIANTS.ps1
    │   └── templates
    │       ├── .gitlab-ci.ps1
    │       ├── Dockerfile.ps1
    │       └── README.md.ps1
    ├── README.md
    └── variants
        └── some-tag-of-variant
            └── Dockerfile
    ```

## Generation definitions and templates

A single folder named `/generate` at the base of the repository will hold all the definition and template files.

- `/generate/definitions` is the definitions folder containing two files `VARIANTS.ps1` and `FILES.ps1` populated with definitions
- `/generate/templates` is the templates folder and create template files. E.g. `/generate/templates/Dockerfile.ps1` or `/generate/templates/README.md.ps1`

```sh
.
├── generate
│   ├── definitions         # This is the definitions folder. It contains the `VARIANTS.ps1` and the `FILES.ps1` generation definitions
│   │   ├── FILES.ps1       # An *optional* generation definition file containing definitions of the repository files you want to generate.
│   │   └── VARIANTS.ps1    # A generation definition file containing definitions of the image variants and definitions of the template of each file to be included in the image build context.
│   └── templates           # This is the templates folder.  with your templates (`.ps1` files) used for generating files according to your generation definitions
│       ├── Dockerfile.ps1  # Dockerfile template (shared among variants across all distros)
│       └── README.md.ps1   # README.md template
```

At minimum, the `/generate/definitions/VARIANTS.ps1` definition file should contain the `$VARIANTS` definition like this:

```powershell
# Docker image variants' definitions
$VARIANTS = @(
    # Our first variant
    @{
        # Specifies the docker image tag
        # When the tag contains words delimited by '-', it known as component-chaining.
        # E.g. 'curl' means only the 'curl.ps1' template will be processed.
        # E.g. 'curl-git'  means the 'curl.ps1' and 'git.ps1' templates will be processed.
        tag = 'curl'
        # Specifies a distro (optional). If you dont define a distro, templates will be sourced from /generate/templates/<file> folder
        # In contrast, if a distro is specified, templates will be sourced from /generate/templates/<file>/<distro> folder
        distro = 'alpine'
        # Specifies an list of components to process. If undefined, the components will be determined from the tag.
        # If unspecified, this is automatically populated
        # components = @( 'foo' )

        # Our Build context definition
        buildContextFiles = @{
            templates = @{
                # We want to generate the file 'Dockerfile'
                'Dockerfile' = @{
                    # Specifies that the template file is shared across distros
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

The `FILES.ps1` definition file is optional, but if used, at minimum it should look like:

```powershell
# Files' definition
$FILES = @(
    # Paths are relative to the base of the project
    'README.md'
)
```

Upon generation, a file `/variants/curl/Dockerfile` is generated in the `curl` variant's build context in `/variants/curl`, as well as a file `/README.md`, both relative to the base of the project.

```sh
.
├── README.md
└── variants
|   └── curl
|       └── Dockerfile
```

See the [`/docs/examples/basic-distro`](examples/basic-distro) example.

## Generation of a variant's built context file(s) through template processing

Use the `buildContextFiles` property of the `$VARIANT` object. It includes these properties:

- `common` - (Optional, defaults to `$false`) Specifies whether this file is shared by all distros ( If value is `$true`, template has to be present in `/generate/templates/<template>.ps1`. If value is `$false`, and if a variant `distro` is defined, it has to be present in `/generate/templates/<file>/<distro>/`, or if a variant `distro` is omitted, has to be present in  `/generate/templates/<template>/<template>.ps1`.)
- `includeHeader` - (Optional, defaults to `$false`) Specifies to process a template `<file>.header.ps1`. Location determined by `common`
- `includeFooter` - (Optional, defaults to `$false`) Specifies to iprocess a template `<file>.footer.ps1`. Location determined by `common`
- `passes` - (Mandatory) An array of pass definitions that the template will undergo. Each pass will generate a single file.

Each template pass processes a template file `<file>.ps1` template and generates a single file named `<file>` in the variant's build context.

A pass can be configured with the `variables` and `generatedFileNameOverride` properties:

```powershell
$VARIANTS = @(
    # Our first variant
    @{
        # Specifies the docker image tag
        tag = 'curl'
        # Specifies a distro (optional). If you dont define a distro, templates will be sourced from /generate/templates/<file> folder
        # In contrast, if a distro is specified, templates will be sourced from /generate/templates/<file>/<distro> folder
        distro = 'alpine'
        # Specifies an list of components to process. If undefined, the components will be determined from the tag.
        # If unspecified, this is automatically populated
        # components = @( 'foo' )

        buildContextFiles = @{
            templates = @{
                # The path of the template to process, relative to the templates directory, omitting the '.ps1' extension
                'Dockerfile' = @{
                    # Specifies whether the template is common (shared) across distros
                    common = $false
                    # Specifies a list of passes the template will be undergo, where each pass generates a file
                    passes = @(
                        # The first pass. The Generated file name will be 'Dockerfile'
                        @{
                            # These variables will be available in $PASS_VARIABLES hashtable when this template is processed
                            variables = @{
                                'foo' = 'bar'
                            }
                            # The generated file will be 'Dockerfile'
                        }
                        # The second pass. The Generated file name will be 'Dockerfile.dev'
                        @{
                            # These variables will be available in $PASS_VARIABLES hashtable when this template is processed
                            variables = @{
                                'foo2' = 'bar2'
                            }
                            # The generated file will be 'Dockerfile.dev'
                            generatedFileNameOverride = 'Dockerfile.dev'
                        }
                    )
                }
            }
        }
    }
}
```

Then, the following variables are now available in the scope of the `<file>.ps1` file:

- `$VARIANT` - the variant object
- `$PASS_VARIABLES` - a hashtable containing the custom variables defined in the Variant's Build context template pass definition

During each pass, a hashtable called `$PASS_VARIABLES` will be in the scope of the processed `Dockerfile.ps1` template. For instance, in the first pass, the value of `$PASS_VARIABLES['foo']` will be `bar`, and the file `Dockerfile` will be generated in the variant's build context. In the second pass, the value of `$PASS_VARIABLES['foo2']` will be `bar2`, and the file `Dockerfile.dev` will be generated in the same build context.

See the [`/docs/examples/basic-distro-variables`](examples/basic-distro-variables) example for using variables.

## Generation of a variant's built context through file copying

Populating a build context might not always involve processing templates. Sometimes we simply want to copy a file into the build context.

To copy a file, simply use the property `copies` in `buildContextFiles`:

```powershell
$VARIANTS = @(
    # Our first variant
    @{
        tag = 'curl'
        # Specifies a distro (optional). If you dont define a distro, templates will be sourced from /generate/templates/<file> folder
        # In contrast, if a distro is specified, templates will be sourced from /generate/templates/<file>/<distro> folder
        distro = 'alpine'
        # Specifies an list of components to process. If undefined, the components will be determined from the tag.
        # If unspecified, this is automatically populated
        # components = @( 'foo' )

        buildContextFiles = @{
            # Specifies the paths, relative to the root of the repository, to recursively copy into each variant's build context
            copies = @(
                '/app'
            )
        }
    }
}
```

This will recursively copy all descending files/folders of the `/app` folder located relative to the *base* of the parent repository into the to-be-generated `curl` variant's build directory `/variants/curl` as `/variants/curl/app`.

See the [`/docs/examples/advanced-component-chaining-copies-variables`](examples/advanced-component-chaining-copies-variables) example.

## Advanced: Generation of a single variant's built context file(s) using Component-chaining

When a variant's `tag` contains words delimited by `-`, it known as **Component-chaining**. The final generated file will be a concatanation of the product of processing the template of each component specified in this chain.

For instance, suppose you want a variant that generates a `Dockerfile` that installs `curl` and `git`, in `DEFINITIONS.ps1`:

```powershell
$VARIANTS = @(
    # Our first variant
    @{
        # Specifies the docker image tag
        # When the tag contains words delimited by '-', it known as component-chaining. This means the 'curl' and 'git' templates will be processed.
        tag = 'curl-git'
        # Specifies a distro (optional). If you dont define a distro, templates will be sourced from /generate/templates/<file> folder
        # In contrast, if a distro is specified, templates will be sourced from /generate/templates/<file>/<distro> folder
        distro = 'alpine'
        # Specifies an list of components to process. If undefined, the components will be determined from the tag.
        # If unspecified, this is automatically populated
        # components = @( 'foo' )

        buildContextFiles = @{
            templates = @{
                # The path of the template to process, relative to the templates directory, omitting the '.ps1' extension
                'Dockerfile' = @{
                    # Specifies whether the template is common (shared) across distros
                    common = $false
                    # Specifies a list of passes the template will be undergo, where each pass generates a file
                    passes = @(
                        @{
                            # These variables will be available in $PASS_VARIABLES hashtable when this template file is processed
                            variables = @{}
                        }
                    )
                }
            }
        }
        ...
    }
)
```

The template pass to generate the variant's build context `Dockerfile` proceeds as such:

1. The file `/generate/templates/Dockerfile/alpine/Dockerfile.header.ps1` is processed

2. Now the files `/generate/templates/Dockerfile/alpine/curl/curl.ps1` and `/generate/templates/Dockerfile/alpine/git/git.ps1` are processed, in the left-to-right order as specified in the chain

3. The file `/generate/templates/Dockerfile/alpine/Dockerfile.footer.ps1` is processed

The file `/variants/curl-git/Dockerfile` is generated along with the variant `curl-git` build context: `/variants/curl-git`

See the [`/docs/examples/basic-component-chaining`](examples/basic-component-chaining) example and the [`/docs/examples/basic-distro-component-chaining`](examples/basic-distro-component-chaining) example.

**Note: If the variant's `tag` consist of a word that matches the variant's `distro`, like in the above example, there will not be a component called `distro`.** For instance, in the above example, if the `tag` is `curl-git-alpine`, there will still only be two components `curl` and `git`. `alpine` will not be considered a component.

To specify that only certain components be processed, independent of the `tag` property, ensure to define the `components` property. See these examples:

- [`/docs/examples/basic-custom-components`](examples/basic-custom-components) example.
- [`/docs/examples/basic-custom-components-distro`](examples/basic-custom-components-distro) example.

## Advanced: Generation of a multiple variants' built context file(s) using Component-chaining

To generate multiple build context variants, all sharing a common `buildContextFiles` template, declare this in `DEFINITIONS.ps1`, declaring `buildContextFiles` property in a special hashtable `$VARIANTS_SHARED`.

```powershell
# Docker image variants' definitions
$VARIANTS = @(
    # Our first variant
    @{
        # Specifies the docker image tag
        # When the tag contains words delimited by '-', it known as component-chaining. This means the 'curl' and 'git' templates will be processed.
        tag = 'curl-git'
        # Specifies a distro (optional). If you dont define a distro, templates will be sourced from /generate/templates/<file> folder
        # In contrast, if a distro is specified, templates will be sourced from /generate/templates/<file>/<distro> folder
        distro = 'alpine'
        # Specifies an list of components to process. If undefined, the components will be determined from the tag.
        # If unspecified, this is automatically populated
        # components = @( 'foo' )
    }
    # Our second variant
    @{
        # Specifies the docker image tag
        # When the tag contains words delimited by '-', it known as component-chaining. This means the 'curl' and 'git' templates will be processed.
        tag = 'curl'
        # Specifies a distro (optional). If you dont define a distro, templates will be sourced from /generate/templates/<file> folder
        # In contrast, if a distro is specified, templates will be sourced from /generate/templates/<file>/<distro> folder
        distro = 'alpine'
        # Specifies an list of components to process. If undefined, the components will be determined from the tag.
        # If unspecified, this is automatically populated
        # components = @( 'foo' )
    }
    # Our third variant
    @{
        # Specifies the docker image tag
        # When the tag contains words delimited by '-', it known as component-chaining. This means the 'curl' and 'git' templates will be processed.
        tag = 'git'
        # Specifies a distro (optional). If you dont define a distro, templates will be sourced from /generate/templates/<file> folder
        # In contrast, if a distro is specified, templates will be sourced from /generate/templates/<file>/<distro> folder
        distro = 'alpine'
        # Specifies an list of components to process. If undefined, the components will be determined from the tag.
        # If unspecified, this is automatically populated
        # components = @( 'foo' )
    }
}

# This is a special variable that sets a common buildContextFiles definition for all variants
# Docker image variants' definitions (shared)
$VARIANTS_SHARED = @{
    buildContextFiles = @{
        templates = @{
            # The path of the template to process, relative to the templates directory, omitting the '.ps1' extension
            'Dockerfile' = @{
                # Specifies whether the template is common (shared) across distros
                common = $false
                # Specifies a list of passes the template will be undergo, where each pass generates a file
                passes = @(
                    @{
                        # These variables will be available in $PASS_VARIABLES hashtable when this template file is processed
                        variables = @{}
                    }
                )
            }
        }
    }
}
```

Note that properties defined in the `$VARIANTS_SHARED` will override their corresponding local properties in the `$VARIANT` object.

Upon generation, **three** variants build contexts for variants `curl-git`, `curl`, and `git` are generated:

```sh
.
└── variants
|   └── curl-git
|       └── Dockerfile
|   └── curl
|       └── Dockerfile
|   └── git
|       └── Dockerfile
```

See the [`/docs/examples/advanced-component-chaining-copies-variables`](examples/advanced-component-chaining-copies-variables) example.

To specify that only certain components be processed, independent of the `tag` property, ensure to define the `components` property. See these examples:

- [`/docs/examples/basic-custom-components`](examples/basic-custom-components) example.
- [`/docs/examples/basic-custom-components-distro`](examples/basic-custom-components-distro) example.

## Optional: Generate other repository files

This module can generate generate a complete repository consisting of:

1. variants build contexts (as covered above)
2. other repository files unrelated to variants build contexts

To populate a repository other repository files, first, define the `$FILES` array in the `FILES.ps1`file:

```powershell
# Files' definition
$FILES = @(
    '.gitlab-ci.yml'
    'README.md'
)
```

Next, create two template files in the `/generate/templates` directory:

```sh
.
├── generate
│   └── templates               # This is the templates folder.  with your templates (`.ps1` files) used for generating files according to your generation definitions
│       ├── gitlab-ci.yml.ps1   # gitlab-ci.yml template (shared among variants across all distros)
│       └── README.md.ps1       # README.md template
```

Now, the generation results in two files, relative to the base of the project:

```sh
.
├── .gitlab-ci.yml
└── .README.md
```

The variables `$VARIANTS` will be available during the processing of the template files `/generate/templates/.gitlab-ci.yml.ps1` and `/generate/templates/README.md.ps1`.

See the [`/docs/examples/advanced-component-chaining-copies-variables`](examples/advanced-component-chaining-copies-variables) example.

## Appendix

### Variant object properties

A `$VARIANT` definition will contain these properties.

```powershell
$VARIANT = @{
    # Specifies the docker image tag
    # When the tag contains words delimited by '-', it known as component-chaining. This means the 'curl' and 'git' templates will be processed.
    tag = 'somepackageversion-somecomponent1-somecomponent2-somedistro'
    # Specifies a distro (optional). If you dont define a distro, templates will be sourced from /generate/templates/<file> folder
    # In contrast, if a distro is specified, templates will be sourced from /generate/templates/<file>/<distro> folder
    distro = 'somedistro'
    # Specifies that this variant should be tagged ':latest'. This property will be useful in generation of content in README.md or ci files. Automatically populated as $false if unspecified
    tag_as_latest = $false
    # Automatically populated
    tag_without_distro = 'somecomponent1-somecomponent2'
    # Specifies an list of components to process. If undefined, the components will be determined from the tag.
    # If unspecified, this is automatically populated
    components = @( 'somecomponent1'
                    'somecomponent2' )
    # Automatically populated
    build_dir_rel = './variants/distro/<tag_without_distro>'
    # Automatically populated
    build_dir = '/full/path/to/variants/distro/<tag_without_distro>'

    # Build context template definition
    buildContextFiles = @{
        templates = @{
            'Dockerfile' = @{
                # Specifies whether the template is common (shared) across distros
                common = $false     #
                # Specifies whether the template <file>.header.ps1 will be processed. Useful for Dockerfiles
                includeHeader = $true
                # Specifies whether the template <file>.footer.ps1 will be processed. Useful for Dockerfiles
                includeFooter = $true
                # Specifies a list of passes the template will be undergo, where each pass generates a file
                passes = @(
                    @{
                        # These variables will be available in $PASS_VARIABLES hashtable when this template is processed
                        variables = @{
                            maintainer = 'foo'
                        }
                    }
                    @{
                        # These variables will be available in $PASS_VARIABLES hashtable when this template is processed
                        variables = @{
                            foo = 'bar'
                        }
                        # The name of the second file to generate
                        generatedFileNameOverride = 'Dockerfile.dev'
                    }
                )
            }
        }
        # Specifies the paths, relative to the root of the repository, to recursively copy into each variant's build context
        copies = @(
            '/app'
        )
    }
}
```

### Debugging

Use the `-Verbose` switch. This gives a detail trace of:

- Validation of `$VARIANTS` definition
- Validation of `$FILES` definition
- Template files or to-be-copied repository files for the build context generation
- Template files for repository files generation

This is particularly useful when the module is throwing errors about definitions, or about missing template or to-be-copied files.

#### Validation of `$VARIANTS` and `$FILES` definitions

For instance, if a variant was defined with an incorrect type (expected to be `hashtable`):

```powershell
$VARIANTS = @(
    1
    @{
        tag = 'curl'
        distro = 'alpine'
    }
}
```

Example of a validation trace:

```powershell
PS > cd /path/to/my-repo
PS > Generate-DockerImageVariants . -Verbose
VERBOSE: Validating $VARIANTS definition
VERBOSE: Validating TargetObject '1 System.Collections.Hashtable System.Collections.Hashtable System.Collections.Hashtable System.Collections.Hashtable System.Collections.Hashtable System.Collections.Hashtable' of type 'Object[]' and basetype 'array'       against Prototype 'System.Collections.Hashtable' of type 'Object[]' and basetype 'array'
VERBOSE:        Validating TargetObject '1' of type 'Int32' and basetype 'System.ValueType'             against Prototype 'System.Collections.Hashtable' of type 'Hashtable' and basetype 'System.Object'
WARNING: Failed with errors. Exception: Type System.Int32 is invalid! It should be of type 'System.Collections.Hashtable'.
```

This demonstrates that a variant definition has to be of type `hashtable`. The value `1` is of type `int32`, and hence is invalid.

#### Validation of template files or to-be-copied files

Example of a validation trace:

```powershell
PS > cd /path/to/my-repo
PS > Generate-DockerImageVariants . -Init
PS > Generate-DockerImageVariants . -Verbose
VERBOSE: Validating $VARIANTS definition
...
VERBOSE: Validating $FILES definition
...
Generating build context of variant 'curl': /path/to/my-repo/variants/curl
VERBOSE: Generating build context file: /path/to/my-repo/variants/curl/Dockerfile
VERBOSE: Processing template file: /path/to/my-repo/generate/templates/Dockerfile.ps1
Generating build context of variant 'curl-git': /path/to/my-repo/variants/curl-git
VERBOSE: Generating build context file: /path/to/my-repo/variants/curl-git/Dockerfile
VERBOSE: Processing template file: /path/to/my-repo/generate/templates/Dockerfile.ps1
Generating build context of variant 'my-cool-variant': /path/to/my-repo/variants/my-cool-variant
VERBOSE: Generating build context file: /path/to/my-repo/variants/my-cool-variant/Dockerfile
VERBOSE: Processing template file: /path/to/my-repo/generate/templates/Dockerfile.ps1
Generating repository file: /path/to/my-repo/.gitlab-ci.yml
VERBOSE: Processing template file: /path/to/my-repo/generate/templates/.gitlab-ci.yml.ps1
Generating repository file: /path/to/my-repo/README.md
VERBOSE: Processing template file: /path/to/my-repo/generate/templates/README.md.ps1
```
