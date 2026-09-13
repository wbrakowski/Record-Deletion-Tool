namespace RecordDeletionTool;

using System.Reflection;
using System.Utilities;

/// <summary>
/// Creates, restores, exports and imports backups of table data.
/// </summary>
codeunit 50001 "Table Backup Mgt."
{
    Permissions = tabledata "Table Backup" = rimd;

    internal procedure CreateBackup(TableID: Integer; BackupType: Enum "Backup Type"; OperationType: Enum "Backup Operation Type"; BackupDescription: Text[250]; ConfirmUnsupportedFields: Boolean): Integer
    var
        TableBackup: Record "Table Backup";
        RecordRef: RecordRef;
        ProgressDialog: Dialog;
        BackupTypeToUse: Enum "Backup Type";
    begin
        // AL does not short-circuit "and" - ConfirmBackupWithBlobFields must only be called (it has the
        // side effect of showing a dialog) when ConfirmUnsupportedFields is actually true.
        if ConfirmUnsupportedFields then
            if not ConfirmBackupWithBlobFields(TableID) then
                exit(0);

        BackupTypeToUse := GetBackupTypeToUse(BackupType);

        TableBackup.Init();
        TableBackup.Validate("Table ID", TableID);
        TableBackup.Validate("Backup Type", BackupTypeToUse);
        TableBackup.Validate("Operation Type", OperationType);
        TableBackup.Validate(Description, BackupDescription);
        TableBackup.Insert(true);

        RecordRef.Open(TableID);
        TableBackup.Validate("No. of Records", RecordRef.Count());
        RecordRef.Close();

        OpenBackupProgressDialog(ProgressDialog, TableBackup, 'Converting data to backup format...');
        ExportBackupData(TableBackup, BackupTypeToUse, ProgressDialog);
        CloseProgressDialogIfAllowed(ProgressDialog);

        TableBackup.Modify(true);
        exit(TableBackup."Entry No.");
    end;

    internal procedure CreateBackupWithFilter(TableID: Integer; BackupType: Enum "Backup Type"; OperationType: Enum "Backup Operation Type"; BackupDescription: Text[250]; FilterView: Text; ConfirmUnsupportedFields: Boolean): Integer
    var
        TableBackup: Record "Table Backup";
        RecordRef: RecordRef;
        ProgressDialog: Dialog;
        BackupTypeToUse: Enum "Backup Type";
    begin
        // AL does not short-circuit "and" - ConfirmBackupWithBlobFields must only be called (it has the
        // side effect of showing a dialog) when ConfirmUnsupportedFields is actually true.
        if ConfirmUnsupportedFields then
            if not ConfirmBackupWithBlobFields(TableID) then
                exit(0);

        BackupTypeToUse := GetBackupTypeToUse(BackupType);

        TableBackup.Init();
        TableBackup.Validate("Table ID", TableID);
        TableBackup.Validate("Backup Type", BackupTypeToUse);
        TableBackup.Validate("Operation Type", OperationType);
        TableBackup.Validate(Description, BackupDescription);
        TableBackup.Validate("Filter View", CopyStr(FilterView, 1, MaxStrLen(TableBackup."Filter View")));
        TableBackup.Insert(true);

        RecordRef.Open(TableID);
        RecordRef.SetView(FilterView);
        TableBackup.Validate("No. of Records", RecordRef.Count());
        RecordRef.Close();

        OpenBackupProgressDialog(ProgressDialog, TableBackup, 'Converting filtered data to backup format...');
        ExportBackupDataWithFilter(TableBackup, BackupTypeToUse, FilterView, ProgressDialog);
        CloseProgressDialogIfAllowed(ProgressDialog);

        TableBackup.Modify(true);
        exit(TableBackup."Entry No.");
    end;

    local procedure GetBackupTypeToUse(BackupType: Enum "Backup Type"): Enum "Backup Type"
    begin
        // Ensure a valid backup type is used (fallback to JSON Export if 0)
        if BackupType.AsInteger() = 0 then
            exit(BackupType::"JSON Export");
        exit(BackupType);
    end;

    local procedure OpenBackupProgressDialog(var ProgressDialog: Dialog; TableBackup: Record "Table Backup"; StatusText: Text)
    var
        CreatingBackupTxt: Label 'Creating Backup...\\Table ID: #1######\\Records: #2######\\Status: #3##################', Comment = '%1 = Table ID, %2 = No. of Records, %3 = Status';
    begin
        if not GuiAllowed() then
            exit;
        ProgressDialog.Open(CreatingBackupTxt);
        ProgressDialog.Update(1, TableBackup."Table ID");
        ProgressDialog.Update(2, TableBackup."No. of Records");
        ProgressDialog.Update(3, StatusText);
    end;

    local procedure CloseProgressDialogIfAllowed(var ProgressDialog: Dialog)
    begin
        if GuiAllowed() then
            ProgressDialog.Close();
    end;

    local procedure ExportBackupData(var TableBackup: Record "Table Backup"; BackupTypeToUse: Enum "Backup Type"; var ProgressDialog: Dialog)
    begin
        case BackupTypeToUse of
            BackupTypeToUse::"JSON Export":
                ExportTableToJSON(TableBackup, ProgressDialog);
            BackupTypeToUse::Snapshot:
                CreateSnapshotTable(TableBackup, ProgressDialog);
            BackupTypeToUse::"Full Backup":
                CreateFullBackup(TableBackup, ProgressDialog);
        end;
    end;

    local procedure ExportBackupDataWithFilter(var TableBackup: Record "Table Backup"; BackupTypeToUse: Enum "Backup Type"; FilterView: Text; var ProgressDialog: Dialog)
    begin
        case BackupTypeToUse of
            BackupTypeToUse::"JSON Export":
                ExportTableToJSONWithFilter(TableBackup, FilterView, ProgressDialog);
            BackupTypeToUse::Snapshot:
                CreateSnapshotTableWithFilter(TableBackup, FilterView, ProgressDialog);
            BackupTypeToUse::"Full Backup":
                CreateFullBackupWithFilter(TableBackup, FilterView, ProgressDialog);
        end;
    end;

    local procedure ExportTableToJSON(var TableBackup: Record "Table Backup"; var ProgressDialog: Dialog)
    var
        RecordRef: RecordRef;
        OutStream: OutStream;
        JSONText: Text;
    begin
        if GuiAllowed() then
            ProgressDialog.Update(3, 'Reading table data...');

        RecordRef.Open(TableBackup."Table ID");
        JSONText := ConvertTableToJSON(RecordRef, ProgressDialog);
        RecordRef.Close();

        if GuiAllowed() then
            ProgressDialog.Update(3, 'Saving backup data...');

        TableBackup."Backup Data".CreateOutStream(OutStream, TextEncoding::UTF8);
        OutStream.WriteText(JSONText);
        TableBackup.Validate("Backup Size (KB)", Round(StrLen(JSONText) / 1024, 0.01));
        TableBackup.Validate("File Name", CopyStr(GetBackupFileName(TableBackup), 1, MaxStrLen(TableBackup."File Name")));

        if GuiAllowed() then
            ProgressDialog.Update(3, 'Backup completed');
    end;

    local procedure ExportTableToJSONWithFilter(var TableBackup: Record "Table Backup"; FilterView: Text; var ProgressDialog: Dialog)
    var
        RecordRef: RecordRef;
        OutStream: OutStream;
        JSONText: Text;
    begin
        if GuiAllowed() then
            ProgressDialog.Update(3, 'Reading filtered table data...');

        RecordRef.Open(TableBackup."Table ID");
        RecordRef.SetView(FilterView);
        JSONText := ConvertTableToJSON(RecordRef, ProgressDialog);
        RecordRef.Close();

        if GuiAllowed() then
            ProgressDialog.Update(3, 'Saving backup data...');

        TableBackup."Backup Data".CreateOutStream(OutStream, TextEncoding::UTF8);
        OutStream.WriteText(JSONText);
        TableBackup.Validate("Backup Size (KB)", Round(StrLen(JSONText) / 1024, 0.01));
        TableBackup.Validate("File Name", CopyStr(GetBackupFileName(TableBackup), 1, MaxStrLen(TableBackup."File Name")));

        if GuiAllowed() then
            ProgressDialog.Update(3, 'Backup completed');
    end;

    local procedure ConvertTableToJSON(var RecordRef: RecordRef; var ProgressDialog: Dialog): Text
    var
        JSONArray: JsonArray;
        JSONText: Text;
    begin
        JSONArray := BuildJSONArrayFromRecords(RecordRef, ProgressDialog);

        if GuiAllowed() then
            ProgressDialog.Update(3, 'Finalizing JSON...');

        JSONArray.WriteTo(JSONText);
        exit(JSONText);
    end;

    local procedure BuildJSONArrayFromRecords(var RecordRef: RecordRef; var ProgressDialog: Dialog): JsonArray
    var
        TempExportField: Record Field temporary;
        JSONArray: JsonArray;
        CurrentRecord: Integer;
        RecordCount: Integer;
    begin
        CollectTableFields(RecordRef.Number(), TempExportField);

        RecordCount := RecordRef.Count();
        CurrentRecord := 0;

        if RecordRef.FindSet() then
            repeat
                CurrentRecord += 1;
                UpdateProgressIfNeeded(ProgressDialog, CurrentRecord, RecordCount);
                JSONArray.Add(ConvertRecordToJSON(RecordRef, TempExportField));
            until RecordRef.Next() = 0;

        exit(JSONArray);
    end;

    // Loads the field metadata once per table instead of re-querying the Field system table for every
    // single data record (major performance gain on large tables). Shared by export and restore.
    local procedure CollectTableFields(TableID: Integer; var TempCachedField: Record Field temporary)
    var
        Field: Record Field;
    begin
        Field.SetRange(TableNo, TableID);
        Field.SetRange(Class, Field.Class::Normal);
        Field.SetRange(ObsoleteState, Field.ObsoleteState::No);

        if Field.FindSet() then
            repeat
                TempCachedField := Field;
                TempCachedField.Insert(false);
            until Field.Next() = 0;
    end;

    local procedure UpdateProgressIfNeeded(var ProgressDialog: Dialog; CurrentRecord: Integer; RecordCount: Integer)
    var
        ProcessingRecordLbl: Label 'Processing record %1 of %2...', Comment = 'DEU="Verarbeite Datensatz %1 von %2...",ESP="Procesando registro %1 de %2...",PLACEHOLDER="%1 = Current record number, %2 = Total records"';
    begin
        if not GuiAllowed() then
            exit;

        if (CurrentRecord mod 100 = 0) or (CurrentRecord = RecordCount) then
            ProgressDialog.Update(3, StrSubstNo(ProcessingRecordLbl, CurrentRecord, RecordCount));
    end;

    local procedure ConvertRecordToJSON(var RecordRef: RecordRef; var TempExportField: Record Field temporary): JsonObject
    var
        JSONObject: JsonObject;
    begin
        Clear(JSONObject);

        if TempExportField.FindSet() then
            repeat
                AddRecordFieldToJSON(RecordRef, TempExportField, JSONObject);
            until TempExportField.Next() = 0;

        exit(JSONObject);
    end;

    local procedure AddRecordFieldToJSON(var RecordRef: RecordRef; Field: Record Field; var JSONObject: JsonObject)
    var
        FieldRef: FieldRef;
    begin
        // Only field types with a known-safe, round-trippable text representation are exported - anything
        // else (BLOB, Media, MediaSet, RecordID, etc.) is skipped entirely, both here and on restore.
        if not IsFieldTypeSupportedForBackup(Field.Type) then
            exit;

        FieldRef := RecordRef.Field(Field."No.");
        AddFieldToJSON(JSONObject, Field.FieldName, GetFieldValueAsText(FieldRef, Field.Type));
    end;

#pragma warning disable LC0010, LC0088
    local procedure IsFieldTypeSupportedForBackup(FieldType: Option): Boolean
    var
        Field: Record Field;
    begin
        exit(FieldType in [
            Field.Type::Integer, Field.Type::BigInteger, Field.Type::Decimal, Field.Type::Boolean,
            Field.Type::Date, Field.Type::Time, Field.Type::DateTime, Field.Type::GUID,
            Field.Type::Option, Field.Type::Text, Field.Type::Code]);
    end;
#pragma warning restore LC0010, LC0088

#pragma warning disable LC0010, LC0088
    local procedure GetFieldValueAsText(var FieldRef: FieldRef; FieldType: Option): Text
    var
        Field: Record Field;
    begin
        // Options/enums are stored as their culture-invariant ordinal (standard Format 9) so restore does
        // not depend on the caption language that was active when the backup was created.
        if FieldType = Field.Type::Option then
            exit(Format(FieldRef.Value(), 0, 9));
        exit(Format(FieldRef.Value()));
    end;
#pragma warning restore LC0010, LC0088

    local procedure AddFieldToJSON(var JSONObject: JsonObject; FieldName: Text; FieldValue: Text)
    var
        JSONValue: JsonValue;
    begin
        JSONValue.SetValue(FieldValue);
        JSONObject.Add(FieldName, JSONValue);
    end;

    local procedure CreateSnapshotTable(var TableBackup: Record "Table Backup"; var ProgressDialog: Dialog)
    var
        SnapshotTableId: Integer;
    begin
        // Create temporary copy using a naming convention
        SnapshotTableId := GetNextSnapshotTableId();
        TableBackup.Validate("Snapshot Table ID", SnapshotTableId);

        // For simplicity, we store snapshots as JSON too (snapshot tables are complex to manage;
        // in a real implementation, you might use temp tables or external storage instead)
        ExportTableToJSON(TableBackup, ProgressDialog);
    end;

    local procedure CreateSnapshotTableWithFilter(var TableBackup: Record "Table Backup"; FilterView: Text; var ProgressDialog: Dialog)
    begin
        // For filtered snapshots, store as JSON with filter info
        ExportTableToJSONWithFilter(TableBackup, FilterView, ProgressDialog);
    end;

    local procedure CreateFullBackup(var TableBackup: Record "Table Backup"; var ProgressDialog: Dialog)
    begin
        // Full backup is the same as JSON export for now
        ExportTableToJSON(TableBackup, ProgressDialog);
    end;

    local procedure CreateFullBackupWithFilter(var TableBackup: Record "Table Backup"; FilterView: Text; var ProgressDialog: Dialog)
    begin
        ExportTableToJSONWithFilter(TableBackup, FilterView, ProgressDialog);
    end;

    internal procedure RestoreBackup(var TableBackup: Record "Table Backup")
    var
        ConfirmManagement: Codeunit "Confirm Management";
        RestoreConfirmQst: Label 'Do you want to restore %1 records to table %2? This will INSERT the backed up records.\\Warning: This may create duplicate records if they still exist!', Comment = '%1 = No. of Records, %2 = Table ID';
    begin
        TableBackup.CalcFields("Table Name");
        if not ConfirmManagement.GetResponseOrDefault(StrSubstNo(RestoreConfirmQst, TableBackup."No. of Records", TableBackup."Table Name"), false) then
            exit;

        case TableBackup."Backup Type" of
            TableBackup."Backup Type"::"JSON Export", TableBackup."Backup Type"::"Full Backup":
                RestoreFromJSON(TableBackup);
            TableBackup."Backup Type"::Snapshot:
                RestoreFromSnapshot(TableBackup);
        end;

        // RestoreFromJSON already shows the appropriate result message (success or partial, via
        // ValidateRestoreResult) - showing another one here would just duplicate it.
        TableBackup.Validate(Restored, true);
        TableBackup.Validate("Restore Date Time", CurrentDateTime());
        TableBackup.Modify(true);
    end;

#pragma warning disable LC0010, LC0090
    // internal (not local) so the test app can exercise the restore logic directly, bypassing the interactive confirm dialog
    internal procedure RestoreFromJSON(var TableBackup: Record "Table Backup")
    var
        TempRestoreField: Record Field temporary;
        RecordRef: RecordRef;
        InStream: InStream;
        i: Integer;
        InsertedCount: Integer;
        FailedCount: Integer;
        JSONArray: JsonArray;
        JSONText: Text;
        ProgressDialog: Dialog;
        RestoringTxt: Label 'Restoring records...\\Processed: #1######\\Inserted: #2######\\Failed: #3######', Comment = '#1 = Processed count, #2 = Inserted count, #3 = Failed count';
        NoRecordsInBackupErr: Label 'No records found in backup data.';
    begin
        TableBackup.CalcFields("Backup Data");
        TableBackup."Backup Data".CreateInStream(InStream, TextEncoding::UTF8);
        InStream.ReadText(JSONText);

        if not JSONArray.ReadFrom(JSONText) then
            Error(InvalidJSONErr);

        if JSONArray.Count() = 0 then
            Error(NoRecordsInBackupErr);

        RecordRef.Open(TableBackup."Table ID");
        CollectTableFields(TableBackup."Table ID", TempRestoreField);

        if GuiAllowed() then
            InitializeProgressDialog(ProgressDialog, RestoringTxt);

        InsertedCount := 0;
        FailedCount := 0;

        for i := 0 to JSONArray.Count() - 1 do
            ProcessRestoreRecord(RecordRef, TempRestoreField, JSONArray, i, InsertedCount, FailedCount, ProgressDialog);

        RecordRef.Close();

        if GuiAllowed() then
            FinalizeProgressDialog(ProgressDialog, JSONArray.Count(), InsertedCount, FailedCount);

        ValidateRestoreResult(InsertedCount, FailedCount, JSONArray.Count(), TableBackup."Table Name");
    end;
#pragma warning restore LC0010, LC0090

    local procedure InitializeProgressDialog(var ProgressDialog: Dialog; ProgressText: Text)
    begin
        ProgressDialog.Open(ProgressText);
        ProgressDialog.Update(1, 0);
        ProgressDialog.Update(2, 0);
        ProgressDialog.Update(3, 0);
    end;

    local procedure ProcessRestoreRecord(var RecordRef: RecordRef; var TempRestoreField: Record Field temporary; var JSONArray: JsonArray; Index: Integer; var InsertedCount: Integer; var FailedCount: Integer; var ProgressDialog: Dialog)
    var
        JSONToken: JsonToken;
    begin
        JSONArray.Get(Index, JSONToken);
        if not JSONToken.IsObject() then
            exit;

        if InsertRecordFromJSON(RecordRef, TempRestoreField, JSONToken.AsObject()) then
            InsertedCount += 1
        else
            FailedCount += 1;

        if GuiAllowed() and ((Index mod 10) = 0) then
            UpdateProgressDialog(ProgressDialog, Index + 1, InsertedCount, FailedCount);
    end;

    local procedure UpdateProgressDialog(var ProgressDialog: Dialog; Processed: Integer; Inserted: Integer; Failed: Integer)
    begin
        ProgressDialog.Update(1, Processed);
        ProgressDialog.Update(2, Inserted);
        ProgressDialog.Update(3, Failed);
    end;

    local procedure FinalizeProgressDialog(var ProgressDialog: Dialog; TotalCount: Integer; InsertedCount: Integer; FailedCount: Integer)
    begin
        UpdateProgressDialog(ProgressDialog, TotalCount, InsertedCount, FailedCount);
        ProgressDialog.Close();
    end;

    local procedure ValidateRestoreResult(InsertedCount: Integer; FailedCount: Integer; TotalCount: Integer; TableName: Text)
    var
        AllInsertFailedErr: Label 'No records could be inserted. All %1 attempts failed.', Comment = '%1 = Number of failed attempts';
        PartialRestoreMsg: Label 'Restored %1 of %2 records. %3 records failed to insert (possibly due to duplicates or validation errors).', Comment = '%1 = Inserted count, %2 = Total count, %3 = Failed count';
    begin
        if InsertedCount = 0 then
            Error(AllInsertFailedErr, FailedCount);

        if FailedCount > 0 then
            Message(PartialRestoreMsg, InsertedCount, TotalCount, FailedCount)
        else
            Message(StrSubstNo(BackupRestoredMsg, InsertedCount, TableName));
    end;

    local procedure InsertRecordFromJSON(var RecordRef: RecordRef; var TempRestoreField: Record Field temporary; JSONObject: JsonObject): Boolean
    var
        InsertResult: Boolean;
    begin
        RecordRef.Init();

        // A single field with a value that cannot be parsed into its target type (e.g. a malformed
        // GUID/RecordID) must fail only this one record, not abort the whole restore operation.
        if not TryPopulateRecordFieldsFromJSON(RecordRef, TempRestoreField, JSONObject) then
            exit(false);

        // Use Insert(true) to ensure system fields like SystemId are properly set
        InsertResult := RecordRef.Insert(true);

        exit(InsertResult);
    end;

    // Wrapped as a TryFunction: field-by-field population is pure in-memory work on RecordRef (no DB
    // write happens until the caller's later Insert()), so catching failures here is safe on SaaS.
    [TryFunction]
    local procedure TryPopulateRecordFieldsFromJSON(var RecordRef: RecordRef; var TempRestoreField: Record Field temporary; JSONObject: JsonObject)
    begin
        PopulateRecordFieldsFromJSON(RecordRef, TempRestoreField, JSONObject);
    end;

    local procedure PopulateRecordFieldsFromJSON(var RecordRef: RecordRef; var TempRestoreField: Record Field temporary; JSONObject: JsonObject): Integer
    var
        FieldsSet: Integer;
    begin
        FieldsSet := 0;

        if TempRestoreField.FindSet() then
            repeat
                SetFieldValueFromJSON(RecordRef, TempRestoreField, JSONObject);
                FieldsSet += 1;
            until TempRestoreField.Next() = 0;

        exit(FieldsSet);
    end;

    local procedure SetFieldValueFromJSON(var RecordRef: RecordRef; Field: Record Field; JSONObject: JsonObject)
    var
        JSONToken: JsonToken;
        FieldValue: Text;
    begin
        if not JSONObject.Get(Field.FieldName, JSONToken) then
            exit;

        if JSONToken.AsValue().IsNull() then
            exit;

        FieldValue := JSONToken.AsValue().AsText();
        if FieldValue = '' then
            exit;

        // Only field types with a known-safe assignment path are handled - see IsFieldTypeSupportedForBackup.
        // A failed FieldRef.Value() call for an unsupported type can corrupt the whole record buffer, so
        // such values must never be attempted at all rather than merely being caught after the fact.
        if not IsFieldTypeSupportedForBackup(Field.Type) then
            exit;

        AssignFieldValueToRecord(RecordRef, Field, FieldValue);
    end;

    local procedure AssignFieldValueToRecord(var RecordRef: RecordRef; Field: Record Field; FieldValue: Text)
    var
        FieldRef: FieldRef;
    begin
        FieldRef := RecordRef.Field(Field."No.");
        AssignFieldValue(FieldRef, FieldValue, Field.Type);
    end;

#pragma warning disable LC0010, LC0088
    local procedure AssignFieldValue(var FieldRef: FieldRef; FieldValue: Text; FieldType: Option)
    var
        Field: Record Field;
    begin
        // Skip empty values to avoid errors
        if FieldValue = '' then
            exit;

        case FieldType of
            Field.Type::Integer, Field.Type::BigInteger:
                AssignIntegerValue(FieldRef, FieldValue);
            Field.Type::Decimal:
                AssignDecimalValue(FieldRef, FieldValue);
            Field.Type::Boolean:
                AssignBooleanValue(FieldRef, FieldValue);
            Field.Type::Date:
                AssignDateValue(FieldRef, FieldValue);
            Field.Type::Time:
                AssignTimeValue(FieldRef, FieldValue);
            Field.Type::DateTime:
                AssignDateTimeValue(FieldRef, FieldValue);
            Field.Type::GUID:
                AssignGuidValue(FieldRef, FieldValue);
            Field.Type::Option:
                AssignOptionValue(FieldRef, FieldValue);
            else
                AssignTextValue(FieldRef, FieldValue);
        end;
    end;
#pragma warning restore LC0010, LC0088

    local procedure AssignIntegerValue(var FieldRef: FieldRef; FieldValue: Text)
    var
        IntegerValue: Integer;
    begin
        if Evaluate(IntegerValue, FieldValue) then
            FieldRef.Value(IntegerValue);
    end;

    local procedure AssignDecimalValue(var FieldRef: FieldRef; FieldValue: Text)
    var
        DecimalValue: Decimal;
    begin
        if Evaluate(DecimalValue, FieldValue) then
            FieldRef.Value(DecimalValue);
    end;

    local procedure AssignBooleanValue(var FieldRef: FieldRef; FieldValue: Text)
    var
        BooleanValue: Boolean;
    begin
        if Evaluate(BooleanValue, FieldValue) then
            FieldRef.Value(BooleanValue);
    end;

    local procedure AssignDateValue(var FieldRef: FieldRef; FieldValue: Text)
    var
        DateValue: Date;
    begin
        if Evaluate(DateValue, FieldValue) then
            FieldRef.Value(DateValue);
    end;

    local procedure AssignTimeValue(var FieldRef: FieldRef; FieldValue: Text)
    var
        TimeValue: Time;
    begin
        if Evaluate(TimeValue, FieldValue) then
            FieldRef.Value(TimeValue);
    end;

    local procedure AssignDateTimeValue(var FieldRef: FieldRef; FieldValue: Text)
    var
        DateTimeValue: DateTime;
    begin
        if Evaluate(DateTimeValue, FieldValue) then
            FieldRef.Value(DateTimeValue);
    end;

    local procedure AssignGuidValue(var FieldRef: FieldRef; FieldValue: Text)
    var
        GuidValue: Guid;
    begin
        if Evaluate(GuidValue, FieldValue) then
            FieldRef.Value(GuidValue);
    end;

    local procedure AssignOptionValue(var FieldRef: FieldRef; FieldValue: Text)
    var
        OptionOrdinal: Integer;
    begin
        // Options/enums are exported as their culture-invariant ordinal value (see GetFieldValueAsText),
        // so assign it directly instead of matching against a (locale-dependent) caption.
        if Evaluate(OptionOrdinal, FieldValue) then
            FieldRef.Value(OptionOrdinal);
    end;

    local procedure AssignTextValue(var FieldRef: FieldRef; FieldValue: Text)
    begin
        // For Text, Code and other types, assign directly
        if FieldRef.Length() > 0 then
            FieldRef.Value(CopyStr(FieldValue, 1, FieldRef.Length()))
        else
            FieldRef.Value(FieldValue);
    end;

    local procedure RestoreFromSnapshot(var TableBackup: Record "Table Backup")
    begin
        // Snapshots are stored as JSON, so restore from JSON
        RestoreFromJSON(TableBackup);
    end;

    internal procedure ExportBackupToFile(var TableBackup: Record "Table Backup")
    var
        InStream: InStream;
        FileName: Text;
    begin
        TableBackup.CalcFields("Backup Data", "Table Name");

        if not TableBackup."Backup Data".HasValue() then
            Error(NoBackupDataErr);

        FileName := GetBackupFileName(TableBackup);
        TableBackup."Backup Data".CreateInStream(InStream);

        DownloadFromStream(InStream, ExportBackupTxt, '', FileFilterTxt, FileName);
    end;

    internal procedure ViewBackupData(var TableBackup: Record "Table Backup")
    var
        InStream: InStream;
        JSONText: Text;
    begin
        TableBackup.CalcFields("Backup Data");

        if not TableBackup."Backup Data".HasValue() then
            Error(NoBackupDataErr);

        TableBackup."Backup Data".CreateInStream(InStream, TextEncoding::UTF8);
        InStream.ReadText(JSONText);

        Message(ViewBackupDataMsg, TableBackup."Entry No.", CopyStr(JSONText, 1, 1000));
    end;

    internal procedure DeleteSnapshotTable(SnapshotTableID: Integer)
    begin
        // Cleanup of snapshot resources if needed - no-op if there is nothing to clean up
        if SnapshotTableID = 0 then
            exit;
        // In this implementation, snapshots are stored as JSON
    end;

    local procedure ConfirmBackupWithBlobFields(TableID: Integer): Boolean
    var
        ConfirmManagement: Codeunit "Confirm Management";
        TableContainsUnsupportedFieldsQst: Label 'Table %1 %2 contains field type(s) that cannot be backed up (e.g. BLOB, Media, RecordID) and will be skipped during backup and cannot be restored.\\Do you want to continue?', Comment = '%1 = Table ID, %2 = Table Name';
    begin
        if not TableHasBlobFields(TableID) then
            exit(true);
        if not GuiAllowed() then
            exit(true);
        exit(ConfirmManagement.GetResponseOrDefault(StrSubstNo(TableContainsUnsupportedFieldsQst, TableID, GetTableCaption(TableID)), true));
    end;

    // internal (not local) so callers can build their own aggregate messages listing table names
    internal procedure GetTableCaption(TableID: Integer): Text
    var
        AllObjWithCaption: Record AllObjWithCaption;
    begin
        AllObjWithCaption.SetRange("Object Type", AllObjWithCaption."Object Type"::Table);
        AllObjWithCaption.SetRange("Object ID", TableID);
        AllObjWithCaption.SetLoadFields("Object Caption");
        if AllObjWithCaption.FindFirst() then
            exit(AllObjWithCaption."Object Caption");
        exit('');
    end;

    // internal (not local) so the test app can verify the unsupported-field-type detection directly, without GuiAllowed() interference
    internal procedure TableHasBlobFields(TableID: Integer): Boolean
    var
        Field: Record Field;
    begin
        Field.SetRange(TableNo, TableID);
        Field.SetRange(Class, Field.Class::Normal);
        Field.SetRange(ObsoleteState, Field.ObsoleteState::No);
        Field.SetLoadFields(Type);

        if Field.FindSet() then
            repeat
                if not IsFieldTypeSupportedForBackup(Field.Type) then
                    exit(true);
            until Field.Next() = 0;

        exit(false);
    end;

    local procedure GetNextSnapshotTableId(): Integer
    var
        TableBackup: Record "Table Backup";
    begin
        TableBackup.SetFilter("Snapshot Table ID", '<>0');
        TableBackup.SetLoadFields("Snapshot Table ID");
        if TableBackup.FindLast() then
            exit(TableBackup."Snapshot Table ID" + 1);
        exit(99000001); // Starting point for snapshot table IDs
    end;

    local procedure GetBackupFileName(TableBackup: Record "Table Backup"): Text
    var
        FileNameTxt: Label 'Backup_Table_%1_%2_%3.json', Comment = '%1 = Table ID, %2 = Table Name, %3 = DateTime';
        DateTimeText: Text;
    begin
        TableBackup.CalcFields("Table Name");
        DateTimeText := Format(TableBackup."Backup Date Time", 0, '<Year4><Month,2><Day,2>_<Hours24><Minutes,2><Seconds,2>');
        exit(StrSubstNo(FileNameTxt, TableBackup."Table ID", DelChr(TableBackup."Table Name", '=', ' /\*?<>|":'), DateTimeText));
    end;

    internal procedure ImportBackupFromFile(TableID: Integer): Integer
    var
        TableBackup: Record "Table Backup";
        InStream: InStream;
        OutStream: OutStream;
        FileName: Text;
        JSONText: Text;
    begin
        if not UploadIntoStream(ImportBackupTxt, '', FileFilterTxt, FileName, InStream) then
            exit(0);

        TableBackup.Init();
        TableBackup.Validate("Table ID", TableID);
        TableBackup.Validate("Backup Type", TableBackup."Backup Type"::"JSON Export");
        TableBackup.Validate("Operation Type", TableBackup."Operation Type"::"Manual Backup");
        TableBackup.Validate(Description, CopyStr(StrSubstNo(ImportedFromFileTxt, FileName), 1, MaxStrLen(TableBackup.Description)));
        TableBackup.Validate("File Name", CopyStr(FileName, 1, MaxStrLen(TableBackup."File Name")));
        TableBackup.Insert(true);

        // Read and store the JSON
        InStream.ReadText(JSONText);
        TableBackup."Backup Data".CreateOutStream(OutStream, TextEncoding::UTF8);
        OutStream.WriteText(JSONText);
        TableBackup.Validate("Backup Size (KB)", Round(StrLen(JSONText) / 1024, 0.01));

        // Count records in JSON
        TableBackup.Validate("No. of Records", CountRecordsInJSON(JSONText));
        TableBackup.Modify(true);

        Message(ImportSuccessMsg, TableBackup."No. of Records", FileName);
        exit(TableBackup."Entry No.");
    end;

    local procedure CountRecordsInJSON(JSONText: Text): Integer
    var
        JSONArray: JsonArray;
    begin
        if JSONArray.ReadFrom(JSONText) then
            exit(JSONArray.Count());
        exit(0);
    end;

    var
        BackupRestoredMsg: Label '%1 records have been restored to table %2.', Comment = '%1 = No. of Records, %2 = Table Name';
        ExportBackupTxt: Label 'Export Backup';
        FileFilterTxt: Label 'JSON Files (*.json)|*.json|All Files (*.*)|*.*';
        ImportBackupTxt: Label 'Import Backup';
        ImportedFromFileTxt: Label 'Imported from file: %1', Comment = '%1 = File Name';
        ImportSuccessMsg: Label '%1 records were imported from file %2.', Comment = '%1 = Record Count, %2 = File Name';
        InvalidJSONErr: Label 'The backup data contains invalid JSON format.';
        NoBackupDataErr: Label 'No backup data found for this entry.';
        ViewBackupDataMsg: Label 'Backup Entry No.: %1\\Data Preview (first 1000 chars):\\%2', Comment = '%1 = Entry No., %2 = JSON Preview';
}
