namespace RecordDeletionTool.Test;

table 60000 "Test Buffer"
{
    Caption = 'Test Buffer';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            NotBlank = true;
            ToolTip = 'Specifies the number of the test buffer record.';
        }
        field(2; "Description"; Text[100])
        {
            Caption = 'Description';
            ToolTip = 'Specifies the description of the test buffer record.';
        }
        field(3; "Integer Value"; Integer)
        {
            Caption = 'Integer Value';
            ToolTip = 'Specifies an integer value used for round-trip testing.';
        }
        field(4; "Decimal Value"; Decimal)
        {
            Caption = 'Decimal Value';
            ToolTip = 'Specifies a decimal value used for round-trip testing.';
        }
        field(5; "Boolean Value"; Boolean)
        {
            Caption = 'Boolean Value';
            ToolTip = 'Specifies a boolean value used for round-trip testing.';
        }
        field(6; "Date Value"; Date)
        {
            Caption = 'Date Value';
            ToolTip = 'Specifies a date value used for round-trip testing.';
        }
    }

    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
    }
}
