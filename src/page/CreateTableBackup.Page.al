page 50004 "Create Table Backup"
{
    ApplicationArea = All;
    Caption = 'Create Table Backup';
    PageType = StandardDialog;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'Backup Options';

                field(TableIDField; TableID)
                {
                    Caption = 'Table ID';
                    TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));
                    ToolTip = 'Specifies the ID of the table to backup.';

                    trigger OnValidate()
                    begin
                        UpdateTableName();
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        AllObjWithCaption: Record AllObjWithCaption;
                    begin
                        AllObjWithCaption.SetRange("Object Type", AllObjWithCaption."Object Type"::Table);
                        if Page.RunModal(Page::"Table Objects", AllObjWithCaption) = Action::LookupOK then begin
                            TableID := AllObjWithCaption."Object ID";
                            UpdateTableName();
                            exit(true);
                        end;
                        exit(false);
                    end;
                }
                field(TableNameField; TableName)
                {
                    Caption = 'Table Name';
                    Editable = false;
                    ToolTip = 'Specifies the name of the table to backup.';
                }
                field(BackupTypeField; BackupType)
                {
                    Caption = 'Backup Type';
                    ToolTip = 'Specifies the type of backup to create.';
                }
                field(DescriptionField; BackupDescription)
                {
                    Caption = 'Description';
                    ToolTip = 'Specifies a description for the backup.';
                }
                field(UseFilterField; UseFilter)
                {
                    Caption = 'Use Filter';
                    ToolTip = 'Specifies whether to backup only filtered records.';

                    trigger OnValidate()
                    begin
                        if not UseFilter then
                            Clear(FilterView);
                    end;
                }
                field(FilterViewField; FilterView)
                {
                    Caption = 'Filter View';
                    Editable = UseFilter;
                    MultiLine = true;
                    ToolTip = 'Specifies the filter to apply (only if Use Filter is enabled).';

                    trigger OnAssistEdit()
                    var
                        SelectTableFirstMsg: Label 'Please select a table first.';
                        EnterFilterManuallyMsg: Label 'Please enter the filter manually in the format: Field1=Value1,Field2=Value2';
                    begin
                        if TableID = 0 then begin
                            Message(SelectTableFirstMsg);
                            exit;
                        end;

                        Message(EnterFilterManuallyMsg);
                    end;
                }
            }
        }
    }



    var
        UseFilter: Boolean;
        BackupType: Enum "Backup Type";
        TableID: Integer;
        FilterView: Text;
        TableName: Text[249];
        BackupDescription: Text[250];

    trigger OnOpenPage()
    begin
        // Set default backup type to JSON Export
        BackupType := BackupType::"JSON Export";
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        TableBackupMgt: Codeunit "Table Backup Mgt.";
        BackupOperationType: Enum "Backup Operation Type";
        EntryNo: Integer;
        SuccessMsg: Label 'Backup created successfully. Entry No.: %1', Comment = '%1 = Entry No.';
        TableSelectionErr: Label 'Please select a table.';
    begin
        // Only create backup if user clicked OK
        if CloseAction <> Action::OK then
            exit(true);

        // Validate that a table is selected
        if TableID = 0 then
            Error(TableSelectionErr);

        // Create the backup
        if UseFilter and (FilterView <> '') then
            EntryNo := TableBackupMgt.CreateBackupWithFilter(TableID, BackupType, BackupOperationType::"Manual Backup", BackupDescription, FilterView)
        else
            EntryNo := TableBackupMgt.CreateBackup(TableID, BackupType, BackupOperationType::"Manual Backup", BackupDescription);

        Message(SuccessMsg, EntryNo);
        exit(true);
    end;

    local procedure UpdateTableName()
    var
        AllObjWithCaption: Record AllObjWithCaption;
    begin
        Clear(TableName);
        if TableID = 0 then
            exit;

        AllObjWithCaption.SetRange("Object Type", AllObjWithCaption."Object Type"::Table);
        AllObjWithCaption.SetRange("Object ID", TableID);
        if AllObjWithCaption.FindFirst() then
            TableName := AllObjWithCaption."Object Caption";
    end;
}
