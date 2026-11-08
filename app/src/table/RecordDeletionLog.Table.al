namespace RecordDeletionTool;

using System.Reflection;

/// <summary>
/// Logs every table whose records were deleted by the Record Deletion Tool.
/// </summary>
table 50003 "Record Deletion Log"
{
    Caption = 'Record Deletion Log';
    DataClassification = SystemMetadata;
    DrillDownPageId = "Record Deletion Log";
    LookupPageId = "Record Deletion Log";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            Editable = false;
            ToolTip = 'Specifies the entry number of the log entry.';
        }
        field(2; "Table ID"; Integer)
        {
            Caption = 'Table ID';
            Editable = false;
            ToolTip = 'Specifies the ID of the table whose records were deleted.';
        }
        field(3; "Table Name"; Text[249])
        {
            CalcFormula = lookup(AllObjWithCaption."Object Caption" where("Object Type" = const(Table), "Object ID" = field("Table ID")));
            Caption = 'Table Name';
            Editable = false;
            FieldClass = FlowField;
            ToolTip = 'Specifies the name of the table whose records were deleted.';
        }
        field(4; "Deletion Date Time"; DateTime)
        {
            Caption = 'Deletion Date Time';
            Editable = false;
            ToolTip = 'Specifies when the records were deleted.';
        }
        field(5; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
            Editable = false;
            ToolTip = 'Specifies who deleted the records.';
        }
        field(6; "Company Name"; Text[30])
        {
            Caption = 'Company Name';
            Editable = false;
            ToolTip = 'Specifies the company in which the records were deleted.';
        }
        field(7; "No. of Records"; Integer)
        {
            Caption = 'No. of Records';
            Editable = false;
            ToolTip = 'Specifies the number of records that were deleted.';
        }
        field(8; "Run Trigger"; Boolean)
        {
            Caption = 'Run Trigger';
            Editable = false;
            ToolTip = 'Specifies whether the delete triggers of the table were executed.';
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Entry No.", "Table ID", "Table Name", "Deletion Date Time", "No. of Records")
        {
        }
        fieldgroup(Brick; "Entry No.", "Table Name", "Deletion Date Time", "No. of Records")
        {
        }
    }

    trigger OnInsert()
    begin
        "Deletion Date Time" := CurrentDateTime();
        "User ID" := CopyStr(UserId(), 1, MaxStrLen("User ID"));
        "Company Name" := CopyStr(CompanyName(), 1, MaxStrLen("Company Name"));
    end;
}
