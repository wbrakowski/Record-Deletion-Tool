namespace RecordDeletionTool;

/// <summary>
/// List page showing which tables had records deleted by the Record Deletion Tool.
/// </summary>
page 50005 "Record Deletion Log"
{
    ApplicationArea = All;
    Caption = 'Record Deletion Log';
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    PageType = List;
    SourceTable = "Record Deletion Log";
    SourceTableView = sorting("Entry No.") order(descending);
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                }
                field("Deletion Date Time"; Rec."Deletion Date Time")
                {
                }
                field("Table ID"; Rec."Table ID")
                {
                }
                field("Table Name"; Rec."Table Name")
                {
                }
                field("No. of Records"; Rec."No. of Records")
                {
                }
                field("Run Trigger"; Rec."Run Trigger")
                {
                }
                field("User ID"; Rec."User ID")
                {
                }
                field("Company Name"; Rec."Company Name")
                {
                }
            }
        }
    }
}
