function Get-FilesPrototype {
    [CmdletBinding()]
    param ()

    # For validation of the $FILES object
    $FILES_PROTOTYPE = @( 'foo' )

    ,$FILES_PROTOTYPE
}
