table 50000 "Record Deletion"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Table ID"; Integer)
        {
            Caption = 'Table ID';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(10; "Table Name"; Text[250])
        {
            Caption = 'Table Name';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = Lookup(AllObjWithCaption."Object Name" where("Object Type" = const(Table), "Object ID" = field("Table ID")));
        }
        field(20; "No. of Records"; Integer)
        {
            Caption = 'No. of Records';
            Editable = false;
            FieldClass = FlowField;
            //CalcFormula = lookup ("Table Information"."No. of Records" where("Company Name" = field(Company), "Table No." = field("Table ID")));
            //CalcFormula = lookup ("Table Information"."No. of Records" where("Company Name" = field(Company), "Table No." = field("Table ID")));
        }
        field(21; "No. of Table Relation Errors"; Integer)
        {
            Caption = 'No. of Table Relation Errors';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = Count("Record Deletion Rel. Error" where("Table ID" = field("Table ID")));
        }
        field(30; "Delete Records"; Boolean)
        {
            Caption = 'Delete Records';
            DataClassification = ToBeClassified;
        }
        field(40; Company; Text[30])
        {
            Caption = 'Company';
            DataClassification = ToBeClassified;
        }


    }

    keys
    {
        key(PK; "Table ID")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        Company := CopyStr(CompanyName, 1, MaxStrLen(Company));
    end;

}