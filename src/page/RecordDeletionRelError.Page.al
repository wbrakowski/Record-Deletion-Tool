page 50101 "Record Deletion Rel. Error"
{

    PageType = List;
    SourceTable = "Record Deletion Rel. Error";
    Caption = 'Record Deletion Rel. Error';
    ApplicationArea = All;
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {

                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                }
                field(Error; Error)
                {
                    ApplicationArea = All;
                }
                field("Field Name"; "Field Name")
                {
                    ApplicationArea = All;
                }
                field("Field No."; "Field No.")
                {
                    ApplicationArea = All;
                }
                // field(SystemId; SystemId)
                // {
                //     ApplicationArea = All;
                // }
                field("Table ID"; "Table ID")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

}
