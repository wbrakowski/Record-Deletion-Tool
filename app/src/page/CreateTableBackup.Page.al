namespace RecordDeletionTool;

using System.Reflection;

/// <summary>
/// Dialog page used to create a new table backup, optionally restricted by a filter.
/// </summary>
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
                        Clear(FilterView);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        AllObjWithCaption: Record AllObjWithCaption;
                    begin
                        AllObjWithCaption.SetRange("Object Type", AllObjWithCaption."Object Type"::Table);
                        if Page.RunModal(Page::"Table Objects", AllObjWithCaption) <> Action::LookupOK then
                            exit(false);

                        TableID := AllObjWithCaption."Object ID";
                        UpdateTableName();
                        Clear(FilterView);
                        exit(true);
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
                    ToolTip = 'Specifies the type of backup to create. Snapshot and Full Backup are currently stored in the same JSON format as JSON Export.';
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
                    AssistEdit = true;
                    Caption = 'Filter View';
                    Editable = UseFilter;
                    MultiLine = true;
                    ToolTip = 'Specifies the filter to apply (only if Use Filter is enabled). Choose the assist-edit button to set the filter on the fields of the selected table.';

                    trigger OnValidate()
                    var
                        TableBackupMgt: Codeunit "Table Backup Mgt.";
                        SelectTableFirstErr: Label 'Please select a table first.';
                    begin
                        if FilterView = '' then
                            exit;

                        if TableID = 0 then
                            Error(SelectTableFirstErr);

                        FilterView := TableBackupMgt.NormalizeFilterView(TableID, FilterView);
                    end;

                    trigger OnAssistEdit()
                    begin
                        SelectFilter();
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
        FilterMissingErr: Label 'Use Filter is enabled but no filter is set. Set a filter or disable Use Filter.';
    begin
        // Only create backup if user clicked OK
        if CloseAction <> Action::OK then
            exit(true);

        // Validate that a table is selected
        if TableID = 0 then
            Error(TableSelectionErr);

        if UseFilter and (FilterView = '') then
            Error(FilterMissingErr);

        // Create the backup
        if UseFilter then
            EntryNo := TableBackupMgt.CreateBackupWithFilter(TableID, BackupType, BackupOperationType::"Manual Backup", BackupDescription, FilterView, true)
        else
            EntryNo := TableBackupMgt.CreateBackup(TableID, BackupType, BackupOperationType::"Manual Backup", BackupDescription, true);

        // EntryNo = 0 means the user declined the BLOB/Media confirmation - keep the dialog open
        if EntryNo = 0 then
            exit(false);

        Message(SuccessMsg, EntryNo);
        exit(true);
    end;

    local procedure SelectFilter()
    var
        TableBackupMgt: Codeunit "Table Backup Mgt.";
        FilterPageBuilder: FilterPageBuilder;
        SelectTableFirstMsg: Label 'Please select a table first.';
    begin
        if (TableID = 0) or (TableName = '') then begin
            Message(SelectTableFirstMsg);
            exit;
        end;

        FilterPageBuilder.AddTable(TableName, TableID);
        if FilterView <> '' then
            FilterPageBuilder.SetView(TableName, FilterView);

        if not FilterPageBuilder.RunModal() then
            exit;

        FilterView := TableBackupMgt.NormalizeFilterView(TableID, FilterPageBuilder.GetView(TableName));
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
        AllObjWithCaption.SetLoadFields("Object Caption");
        if AllObjWithCaption.FindFirst() then
            TableName := AllObjWithCaption."Object Caption";
    end;
}
