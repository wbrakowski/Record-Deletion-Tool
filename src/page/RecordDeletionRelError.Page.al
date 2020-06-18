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
                    ToolTip = 'Specifies the Entry No.';
                }
                field("Error"; Error)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the error text if an error occured';
                }
                field("Field Name"; "Field Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Field Name';
                }
                field("Field No."; "Field No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Field No.';
                }
                // field(SystemId; SystemId)
                // {
                //     ApplicationArea = All;
                // }
                field("Table ID"; "Table ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Table ID';
                }
            }
        }
    }

}
