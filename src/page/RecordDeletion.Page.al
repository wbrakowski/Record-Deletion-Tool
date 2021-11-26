page 50000 "Record Deletion"
{

    PageType = List;
    SourceTable = "Record Deletion";
    Caption = 'Record Deletion';
    ApplicationArea = All;
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Table ID"; Rec."Table ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Table ID field.';
                }
                field("Table Name"; Rec."Table Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Table Name field.';
                }
                field(NoOfRecords; RecordDeletionMgt.CalcRecordsInTable(Rec."Table ID"))
                {
                    CaptionML = ENU = 'No. of Records';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the CalcRecordsInTable(Rec.Table ID) field.';

                }
                field("No. of Table Relation Errors"; Rec."No. of Table Relation Errors")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. of Table Relation Errors field.';
                }
                field("Delete Records"; Rec."Delete Records")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Delete Records field.';
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
        area(Navigation)
        {

        }
        area(Processing)
        {
            action(InsertUpdateTables)
            {
                ApplicationArea = All;
                CaptionML = ENU = 'Insert/Update Tables';
                Promoted = true;
                PromotedIsBig = true;
                Image = Refresh;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Executes the InsertUpdateTables action.';
                trigger OnAction()
                begin
                    RecordDeletionMgt.InsertUpdateTables();
                end;
            }
            action(SuggestsRecords)
            {
                ApplicationArea = All;
                CaptionML = ENU = 'Suggest Records to Delete';
                Promoted = true;
                PromotedIsBig = true;
                Image = Suggest;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Executes the SuggestsRecords action.';
                trigger OnAction()
                begin
                    RecordDeletionMgt.SuggestRecordsToDelete();
                end;
            }
            action(SuggestsUnlicensedPartnerOrCustomRecords)
            {
                ApplicationArea = All;
                CaptionML = ENU = 'Suggest Unlicensed Partner or Custom Records to Delete';
                Promoted = true;
                PromotedIsBig = true;
                Image = Suggest;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Executes the SuggestsUnlicensedPartnerOrCustomRecords action.';
                trigger OnAction()
                begin
                    RecordDeletionMgt.SuggestUnlicensedPartnerOrCustomRecordsToDelete();
                end;
            }
            action(ClearRecords)
            {
                ApplicationArea = All;
                CaptionML = ENU = 'Clear Records to Delete';
                Promoted = true;
                PromotedIsBig = true;
                Image = Delete;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Executes the ClearRecords action.';
                trigger OnAction()
                begin
                    RecordDeletionMgt.ClearRecordsToDelete();
                end;
            }
            action(DeleteRecords)
            {
                ApplicationArea = All;
                CaptionML = ENU = 'Delete Records (no trigger!)';
                Promoted = true;
                PromotedIsBig = true;
                Image = Delete;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Executes the DeleteRecords action.';
                trigger OnAction()
                begin
                    RecordDeletionMgt.DeleteRecords(false);
                end;
            }
            action(DeleteRecordsWithTrigger)
            {
                ApplicationArea = All;
                CaptionML = ENU = 'Delete Records (with trigger!)';
                Promoted = true;
                PromotedIsBig = true;
                Image = Delete;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Executes the DeleteRecordsWithTrigger action.';
                trigger OnAction()
                begin
                    RecordDeletionMgt.DeleteRecords(true);
                end;
            }
            action(CheckTableRelations)
            {
                ApplicationArea = All;
                CaptionML = ENU = 'Check Table Relations';
                Promoted = true;
                PromotedIsBig = true;
                Image = Relationship;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Executes the CheckTableRelations action.';
                trigger OnAction()
                begin
                    RecordDeletionMgt.CheckTableRelations();
                end;
            }
            action(ViewRecords)
            {
                ApplicationArea = All;
                CaptionML = ENU = 'View Records';
                Promoted = true;
                PromotedIsBig = true;
                Image = Table;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Executes the ViewRecords action.';
                trigger OnAction()
                begin
                    RecordDeletionMgt.ViewRecords(Rec);
                end;
            }
        }

    }
    var
        RecordDeletionMgt: Codeunit "Record Deletion Mgt.";

}
