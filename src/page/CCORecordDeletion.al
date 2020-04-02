page 50100 "Record Deletion"
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
                field("Delete Records"; "Delete Records")
                {
                    ApplicationArea = All;
                }
                field("No. of Table Relation Errors"; "No. of Table Relation Errors")
                {
                    ApplicationArea = All;
                }
                field("Table ID"; "Table ID")
                {
                    ApplicationArea = All;
                }
                field("Table Name"; "Table Name")
                {
                    ApplicationArea = All;
                }
                field(Company; Company)
                {
                    ApplicationArea = All;
                }
                field(NoOfRecords; RecordDeletionMgt.CalcRecordsInTable("Table ID"))
                {
                    CaptionML = ENU = 'No. of Records';
                    ApplicationArea = All;

                }

                // field(SystemId; SystemId)
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
                trigger OnAction()
                begin
                    RecordDeletionMgt.SuggestRecordsToDelete();
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
                trigger OnAction()
                begin
                    RecordDeletionMgt.ClearRecordsToDelete();
                end;
            }
            action(DeleteRecords)
            {
                ApplicationArea = All;
                CaptionML = ENU = 'Delete Records';
                Promoted = true;
                PromotedIsBig = true;
                Image = Delete;
                PromotedCategory = Process;
                trigger OnAction()
                begin
                    RecordDeletionMgt.DeleteRecords();
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
