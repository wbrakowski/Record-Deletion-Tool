page 50000 "Record Deletion"
{
    ApplicationArea = All;
    Caption = 'Record Deletion';
    PageType = List;
    SourceTable = "Record Deletion";
    UsageCategory = Lists;
    PromotedActionCategories = 'New,Process,Report,Tables,Suggest,Deletion,Backup';

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
                    CaptionML = ENU = 'No. of Records';
                    ToolTip = 'Specifies the value of the CalcRecordsInTable(Rec.Table ID) field.';
                }
                field("No. of Table Relation Errors"; Rec."No. of Table Relation Errors")
                {
                }
                field("Delete Records"; Rec."Delete Records")
                {
                }
                // field(Company; Company)
                // {
                //     ApplicationArea = All;
                // }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(InsertUpdateTables)
            {
                CaptionML = ENU = 'Insert/Update Tables';
                Image = Refresh;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Executes the InsertUpdateTables action.';
                trigger OnAction()
                begin
                    RecordDeletionMgt.InsertUpdateTables();
                end;
            }
            action(SuggestsRecords)
            {
                CaptionML = ENU = 'Suggest Records to Delete';
                Image = Suggest;
                Promoted = true;
                PromotedCategory = Category5;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Executes the SuggestsRecords action.';
                trigger OnAction()
                begin
                    RecordDeletionMgt.SuggestRecordsToDelete();
                end;
            }
            action(SuggestsUnlicensedPartnerOrCustomRecords)
            {
                CaptionML = ENU = 'Suggest Unlicensed Partner or Custom Records to Delete';
                Image = Suggest;
                Promoted = true;
                PromotedCategory = Category5;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Executes the SuggestsUnlicensedPartnerOrCustomRecords action.';
                trigger OnAction()
                begin
                    RecordDeletionMgt.SuggestUnlicensedPartnerOrCustomRecordsToDelete();
                end;
            }
            action(ClearRecords)
            {
                CaptionML = ENU = 'Clear Records to Delete';
                Image = Delete;
                Promoted = true;
                PromotedCategory = Category6;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Executes the ClearRecords action.';
                trigger OnAction()
                begin
                    RecordDeletionMgt.ClearRecordsToDelete();
                end;
            }
            action(DeleteRecords)
            {
                CaptionML = ENU = 'Delete Records (no trigger!)';
                Image = Delete;
                Promoted = true;
                PromotedCategory = Category6;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Executes the DeleteRecords action.';
                trigger OnAction()
                begin
                    RecordDeletionMgt.DeleteRecords(false);
                end;
            }
            action(DeleteRecordsWithTrigger)
            {
                CaptionML = ENU = 'Delete Records (with trigger!)';
                Image = Delete;
                Promoted = true;
                PromotedCategory = Category6;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Executes the DeleteRecordsWithTrigger action.';
                trigger OnAction()
                begin
                    RecordDeletionMgt.DeleteRecords(true);
                end;
            }
            action(CheckTableRelations)
            {
                CaptionML = ENU = 'Check Table Relations';
                Image = Relationship;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Executes the CheckTableRelations action.';
                trigger OnAction()
                begin
                    RecordDeletionMgt.CheckTableRelations();
                end;
            }
            action(ViewRecords)
            {
                CaptionML = ENU = 'View Records';
                Image = Table;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Executes the ViewRecords action.';
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
                Promoted = true;
                PromotedCategory = Category7;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Opens the table backup management where you can view, create, restore and export/import backups.';

                trigger OnAction()
                begin
                    Page.Run(Page::"Table Backup List");
                end;
            }
        }
    }
    var
        RecordDeletionMgt: Codeunit "Record Deletion Mgt.";
}
