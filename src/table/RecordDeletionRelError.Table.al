table 50001 "Record Deletion Rel. Error"
{
    Caption = 'Record Deletion Rel. Error';
    DataClassification = CustomerContent;
    DrillDownPageId = "Record Deletion Rel. Error";
    LookupPageId = "Record Deletion Rel. Error";
    fields
    {
        field(1; "Table ID"; Integer)
        {
            Caption = 'Table ID';
            Editable = false;
            ToolTip = 'Specifies the Table ID.';
        }
        field(2; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            Editable = false;
            ToolTip = 'Specifies the Entry No.';
        }
        field(10; "Field No."; Integer)
        {
            Caption = 'Field No.';
            Editable = false;
            ToolTip = 'Specifies the Field No.';
        }
        field(11; "Field Name"; Text[30])
        {
            CalcFormula = lookup(Field.FieldName where(TableNo = field("Table ID"), "No." = field("Field No.")));
            Caption = 'Field Name';
            Editable = false;
            FieldClass = FlowField;
            ToolTip = 'Specifies the Field Name.';
        }
        field(20; Error; Text[250])
        {
            Caption = 'Error';
            Editable = false;
            ToolTip = 'Specifies the error text if an error occured.';
        }
    }

    keys
    {
        key(PK; "Table ID", "Entry No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Table ID", "Entry No.", "Field Name")
        {
        }
        fieldgroup(Brick; "Table ID", "Entry No.", "Field Name")
        {
        }
    }
}