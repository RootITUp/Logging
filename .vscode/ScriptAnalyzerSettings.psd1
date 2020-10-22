@{
    Severity = @('Error','Warning')

    ExcludeRules = @(
        'PSAvoidUsingWriteHost',
        'PSMissingModuleManifestField',
        'PSUseDeclaredVarsMoreThanAssignments',
        'PSUseShouldProcessForStateChangingFunctions',
        'PSAvoidOverwritingBuiltInCmdlets'
    )
}
