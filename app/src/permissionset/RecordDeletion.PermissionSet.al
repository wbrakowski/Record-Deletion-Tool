namespace RecordDeletionTool;

/// <summary>
/// Grants access to all objects of the Record Deletion Tool extension.
/// </summary>
permissionset 50000 "Record Deletion"
{
    Assignable = true;
    Caption = 'Record Deletion', Locked = true;

    Permissions =
        table "Record Deletion" = X,
        tabledata "Record Deletion" = RIMD,
        table "Record Deletion Rel. Error" = X,
        tabledata "Record Deletion Rel. Error" = RIMD,
        table "Table Backup" = X,
        tabledata "Table Backup" = RIMD,
        codeunit "Record Deletion Mgt." = X,
        codeunit "Table Backup Mgt." = X,
        page "Create Table Backup" = X,
        page "Record Deletion" = X,
        page "Record Deletion Rel. Error" = X,
        page "Table Backup Card" = X,
        page "Table Backup List" = X;
}
