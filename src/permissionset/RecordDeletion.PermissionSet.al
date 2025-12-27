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
        page "Record Deletion" = X,
        page "Record Deletion Rel. Error" = X,
        page "Create Table Backup" = X,
        page "Table Backup Card" = X,
        page "Table Backup List" = X,
        codeunit "Record Deletion Mgt." = X,
        codeunit "Table Backup Mgt." = X;
}
