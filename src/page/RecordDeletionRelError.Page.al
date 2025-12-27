page 50001 "Record Deletion Rel. Error"
{
    ApplicationArea = All;
    Caption = 'Record Deletion Rel. Error';
    PageType = List;
    SourceTable = "Record Deletion Rel. Error";
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
                field(Error; Rec.Error)
                {

                }
                field("Field Name"; Rec."Field Name")
                {

                }
                field("Field No."; Rec."Field No.")
                {

                }
                field("Table ID"; Rec."Table ID")
                {

                }
            }
        }
    }
}
