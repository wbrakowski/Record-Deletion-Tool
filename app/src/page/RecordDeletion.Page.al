namespace RecordDeletionTool;

/// <summary>
/// List page used to select tables and manage the record deletion workflow.
/// </summary>
page 50000 "Record Deletion"
{
    ApplicationArea = All;
    Caption = 'Record Deletion';
    PageType = List;
    SourceTable = "Record Deletion";
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Table ID"; Rec."Table ID")
                {
                }
                field("Table Name"; Rec."Table Name")
                {
                }
                field(NoOfRecords; RecordDeletionMgt.CalcRecordsInTable(Rec."Table ID"))
                {
                    Caption = 'No. of Records';
                    ToolTip = 'Specifies the number of records in the table.';
                }
                field("No. of Table Relation Errors"; Rec."No. of Table Relation Errors")
                {
                }
                field("Delete Records"; Rec."Delete Records")
                {
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(InsertUpdateTables)
            {
                Caption = 'Insert/Update Tables';
                Image = Refresh;
                ToolTip = 'Adds all tables of the environment to the list that are not protected.';
                trigger OnAction()
                begin
                    RecordDeletionMgt.InsertUpdateTables();
                end;
            }
            action(SuggestsRecords)
            {
                Caption = 'Suggest Records to Delete';
                Image = Suggest;
                ToolTip = 'Flags the standard tables that usually contain transaction data for deletion.';
                trigger OnAction()
                begin
                    RecordDeletionMgt.SuggestRecordsToDelete();
                end;
            }
            action(SuggestsUnlicensedPartnerOrCustomRecords)
            {
                Caption = 'Suggest Unlicensed Partner or Custom Records to Delete';
                Image = Suggest;
                ToolTip = 'Flags custom tables that are not covered by your license for deletion.';
                trigger OnAction()
                begin
                    RecordDeletionMgt.SuggestUnlicensedPartnerOrCustomRecordsToDelete();
                end;
            }
            action(ClearRecords)
            {
                Caption = 'Clear Records to Delete';
                Image = ClearLog;
                ToolTip = 'Clears the Delete Records flag on all tables.';
                trigger OnAction()
                begin
                    RecordDeletionMgt.ClearRecordsToDelete();
                end;
            }
            action(DeleteRecords)
            {
                Caption = 'Delete Records (no trigger!)';
                Image = Delete;
                ToolTip = 'Deletes all records of the flagged tables without running the delete triggers. A backup can be created first.';
                trigger OnAction()
                begin
                    RecordDeletionMgt.DeleteRecords(false);
                end;
            }
            action(DeleteRecordsWithTrigger)
            {
                Caption = 'Delete Records (with trigger!)';
                Image = Delete;
                ToolTip = 'Deletes all records of the flagged tables and runs the delete triggers. A backup can be created first.';
                trigger OnAction()
                begin
                    RecordDeletionMgt.DeleteRecords(true);
                end;
            }
            action(CheckTableRelations)
            {
                Caption = 'Check Table Relations';
                Image = Relationship;
                ToolTip = 'Checks whether records point to related records that do not exist and lists the errors per table.';
                trigger OnAction()
                begin
                    RecordDeletionMgt.CheckTableRelations();
                end;
            }
            action(ViewRecords)
            {
                Caption = 'View Records';
                Image = Table;
                ToolTip = 'Opens the records of the selected table.';
                trigger OnAction()
                begin
                    RecordDeletionMgt.ViewRecords(Rec);
                end;
            }
            action(ManageBackups)
            {
                AboutText = 'View, create, restore and manage backups of your table data.';
                AboutTitle = 'Manage Table Backups';
                Caption = 'Manage Backups';
                Image = Archive;
                ToolTip = 'Opens the table backup management where you can view, create, restore and export/import backups.';

                trigger OnAction()
                begin
                    Page.Run(Page::"Table Backup List");
                end;
            }
            action(DeletionLog)
            {
                Caption = 'Deletion Log';
                Image = Log;
                ToolTip = 'Opens the log of the tables whose records were deleted with this tool.';

                trigger OnAction()
                begin
                    Page.Run(Page::"Record Deletion Log");
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Tables)
            {
                Caption = 'Tables';

                actionref(InsertUpdateTables_Promoted; InsertUpdateTables)
                {
                }
                actionref(CheckTableRelations_Promoted; CheckTableRelations)
                {
                }
                actionref(ViewRecords_Promoted; ViewRecords)
                {
                }
            }
            group(Category_Suggest)
            {
                Caption = 'Suggest';

                actionref(SuggestsRecords_Promoted; SuggestsRecords)
                {
                }
                actionref(SuggestsUnlicensedPartnerOrCustomRecords_Promoted; SuggestsUnlicensedPartnerOrCustomRecords)
                {
                }
            }
            group(Category_Deletion)
            {
                Caption = 'Deletion';

                actionref(ClearRecords_Promoted; ClearRecords)
                {
                }
                actionref(DeleteRecords_Promoted; DeleteRecords)
                {
                }
                actionref(DeleteRecordsWithTrigger_Promoted; DeleteRecordsWithTrigger)
                {
                }
            }
            group(Category_Backup)
            {
                Caption = 'Backup';

                actionref(ManageBackups_Promoted; ManageBackups)
                {
                }
                actionref(DeletionLog_Promoted; DeletionLog)
                {
                }
            }
        }
    }
    var
        RecordDeletionMgt: Codeunit "Record Deletion Mgt.";
}
