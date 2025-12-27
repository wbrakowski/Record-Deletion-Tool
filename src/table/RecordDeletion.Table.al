table 50000 "Record Deletion"
{
    Caption = 'Record Deletion';
    DataClassification = CustomerContent;
    DrillDownPageId = "Record Deletion";
    LookupPageId = "Record Deletion";

    fields
    {
        field(1; "Table ID"; Integer)
        {
            Caption = 'Table ID';
            Editable = false;
            ToolTip = 'Specifies the ID of the table.';
        }
        field(10; "Table Name"; Text[250])
        {
            CalcFormula = lookup(AllObjWithCaption."Object Name" where("Object Type" = const(Table), "Object ID" = field("Table ID")));
            Caption = 'Table Name';
            Editable = false;
            FieldClass = FlowField;
            ToolTip = 'Specifies the name of the table.';
        }
        // Field 20 removed - Table Information is OnPrem only, not Cloud compatible
        // Use RecordDeletionMgt.CalcRecordsInTable() on the page instead (already implemented)
        field(21; "No. of Table Relation Errors"; Integer)
        {
            CalcFormula = count("Record Deletion Rel. Error" where("Table ID" = field("Table ID")));
            Caption = 'No. of Table Relation Errors';
            Editable = false;
            FieldClass = FlowField;
            ToolTip = 'Specifies the number of table relation errors for this table.';
        }
        field(30; "Delete Records"; Boolean)
        {
            Caption = 'Delete Records';
            ToolTip = 'Specifies whether records should be deleted for this table.';
        }
        field(40; Company; Text[30])
        {
            Caption = 'Company';
            AllowInCustomizations = Never;
            ToolTip = 'Specifies the company name.';
        }
    }

    keys
    {
        key(PK; "Table ID")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Table ID", "Table Name")
        {
        }
        fieldgroup(Brick; "Table ID", "Table Name")
        {
        }
    }

    trigger OnInsert()
    begin
        Company := CopyStr(CompanyName(), 1, MaxStrLen(Company));
    end;
}