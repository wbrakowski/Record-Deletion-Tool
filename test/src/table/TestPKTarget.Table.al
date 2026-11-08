namespace RecordDeletionTool.Test;

table 60001 "Test PK Target"
{
    Caption = 'Test PK Target';
    DataClassification = SystemMetadata;

    fields
    {
#pragma warning disable LC0092
        // The name deliberately contains characters that are special in filter expressions: ( ) &
        field(1; "Code & No. (Key)"; Code[20])
        {
            Caption = 'Code & No. (Key)';
            NotBlank = true;
            ToolTip = 'Specifies the primary key, whose name contains filter special characters to test relation checks against such tables.';
        }
#pragma warning restore LC0092
    }

    keys
    {
        key(PK; "Code & No. (Key)")
        {
            Clustered = true;
        }
    }
}
