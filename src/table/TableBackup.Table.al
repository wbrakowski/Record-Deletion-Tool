table 50002 "Table Backup"
{
    Caption = 'Table Backup';
    DataClassification = SystemMetadata;
    DrillDownPageId = "Table Backup List";
    LookupPageId = "Table Backup List";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            ToolTip = 'Specifies the entry number of the backup.';
        }
        field(2; "Table ID"; Integer)
        {
            Caption = 'Table ID';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));
            ToolTip = 'Specifies the table ID of the backup.';
        }
        field(3; "Table Name"; Text[249])
        {
            CalcFormula = lookup(AllObjWithCaption."Object Caption" where("Object Type" = const(Table), "Object ID" = field("Table ID")));
            Caption = 'Table Name';
            Editable = false;
            FieldClass = FlowField;
            ToolTip = 'Specifies the table name of the backup.';
        }
        field(4; "Backup Type"; Enum "Backup Type")
        {
            Caption = 'Backup Type';
            ToolTip = 'Specifies the type of backup.';
        }
        field(5; "Backup Date Time"; DateTime)
        {
            Caption = 'Backup Date Time';
            Editable = false;
            ToolTip = 'Specifies when the backup was created.';
        }
        field(6; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
            Editable = false;
            ToolTip = 'Specifies who created the backup.';
        }
        field(7; "No. of Records"; Integer)
        {
            Caption = 'No. of Records';
            Editable = false;
            ToolTip = 'Specifies the number of records in the backup.';
        }
        field(8; "Backup Data"; Blob)
        {
            Caption = 'Backup Data';
        }
        field(9; "Snapshot Table ID"; Integer)
        {
            AllowInCustomizations = AsReadOnly;
            Caption = 'Snapshot Table ID';
            Editable = false;
        }
        field(10; "Operation Type"; Enum "Backup Operation Type")
        {
            Caption = 'Operation Type';
            InitValue = "Manual Backup";
            ToolTip = 'Specifies how the backup was created.';

            trigger OnValidate()
            begin
                if "Operation Type" = "Operation Type"::" " then
                    "Operation Type" := "Operation Type"::"Manual Backup";
            end;
        }
        field(11; "File Name"; Text[250])
        {
            Caption = 'File Name';
            ToolTip = 'Specifies the file name for the backup.';
        }
        field(12; "Compression Enabled"; Boolean)
        {
            AllowInCustomizations = AsReadWrite;
            Caption = 'Compression Enabled';
            InitValue = true;
            ToolTip = 'Specifies whether compression is enabled for the backup.';
        }
        field(13; "Backup Size (KB)"; Decimal)
        {
            Caption = 'Backup Size (KB)';
            DecimalPlaces = 2 : 2;
            Editable = false;
            ToolTip = 'Specifies the size of the backup in kilobytes.';
        }
        field(14; Description; Text[250])
        {
            Caption = 'Description';
            ToolTip = 'Specifies a description of the backup.';
        }
        field(15; "Company Name"; Text[30])
        {
            Caption = 'Company Name';
            Editable = false;
            ToolTip = 'Specifies the company name where the backup was created.';
        }
        field(16; "Restore Date Time"; DateTime)
        {
            Caption = 'Restore Date Time';
            Editable = false;
            ToolTip = 'Specifies when the backup was restored.';
        }
        field(17; Restored; Boolean)
        {
            Caption = 'Restored';
            Editable = false;
            ToolTip = 'Specifies whether the backup has been restored.';
        }
        field(18; "Filter View"; Text[250])
        {
            Caption = 'Filter View';
            ToolTip = 'Specifies the filter that was applied when creating the backup.';
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(TableDate; "Table ID", "Backup Date Time")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Entry No.", "Table ID", "Table Name", "Backup Date Time", "No. of Records")
        {
        }
        fieldgroup(Brick; "Entry No.", "Table Name", "Backup Date Time", "No. of Records", "Backup Type")
        {
        }
    }

    trigger OnInsert()
    begin
        "Backup Date Time" := CurrentDateTime();
        "User ID" := CopyStr(UserId(), 1, MaxStrLen("User ID"));
        "Company Name" := CopyStr(CompanyName(), 1, MaxStrLen("Company Name"));
    end;

    trigger OnDelete()
    begin
        DeleteSnapshotTable();
    end;

    local procedure DeleteSnapshotTable()
    var
        TableBackupMgt: Codeunit "Table Backup Mgt.";
    begin
        if "Snapshot Table ID" <> 0 then
            TableBackupMgt.DeleteSnapshotTable("Snapshot Table ID");
    end;

    procedure ExportToFile()
    var
        TableBackupMgt: Codeunit "Table Backup Mgt.";
    begin
        TableBackupMgt.ExportBackupToFile(Rec);
    end;

    procedure RestoreBackup()
    var
        TableBackupMgt: Codeunit "Table Backup Mgt.";
    begin
        TableBackupMgt.RestoreBackup(Rec);
    end;

    procedure ViewBackupData()
    var
        TableBackupMgt: Codeunit "Table Backup Mgt.";
    begin
        TableBackupMgt.ViewBackupData(Rec);
    end;
}
