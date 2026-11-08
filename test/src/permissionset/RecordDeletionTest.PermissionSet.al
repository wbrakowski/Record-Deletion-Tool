namespace RecordDeletionTool.Test;

permissionset 60000 "Record Deletion Test"
{
    Assignable = true;
    Caption = 'Record Deletion Tests', Locked = true;

    Permissions =
        table "Test Buffer" = X,
        tabledata "Test Buffer" = RIMD,
        table "Test PK Target" = X,
        tabledata "Test PK Target" = RIMD,
        codeunit "RecordDeletionMgt Test" = X,
        codeunit "TableBackupMgt Test" = X;
}
