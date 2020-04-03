table 50101 "CCO Record Deletion Rel. Error"
{
    DataClassification = ToBeClassified;
    LookupPageId = "CCO Record Deletion Rel. Error";
    DrillDownPageId = "CCO Record Deletion Rel. Error";
    fields
    {
        field(1; "Table ID"; Integer)
        {
            Caption = 'Table ID';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(2; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(10; "Field No."; Integer)
        {
            Caption = 'Field No.';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(11; "Field Name"; Text[30])
        {
            Caption = 'Field Name';
            FieldClass = FlowField;
            CalcFormula = Lookup (Field.FieldName where(TableNo = field("Table ID"), "No." = field("Field No.")));
            Editable = false;
        }
        field(20; "Error"; Text[250])
        {
            Caption = 'Error';
            DataClassification = ToBeClassified;
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Table ID", "Entry No.")
        {
            Clustered = true;
        }
    }

}