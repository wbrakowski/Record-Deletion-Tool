namespace RecordDeletionTool.Test;

permissionset 60000 "Record Deletion Test"
{
    Assignable = true;
    Caption = 'Record Deletion Tests', Locked = true;

    Permissions =
        table "Test Buffer" = X,
        tabledata "Test Buffer" = RIMD,
        codeunit "TableBackupMgt Test" = X;
}
