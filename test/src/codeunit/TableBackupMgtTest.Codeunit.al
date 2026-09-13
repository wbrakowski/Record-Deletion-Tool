namespace RecordDeletionTool.Test;

using RecordDeletionTool;
using System.TestLibraries.Utilities;

codeunit 60000 "TableBackupMgt Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";
        TableBackupMgt: Codeunit "Table Backup Mgt.";

    [Test]
    procedure CreateBackupStoresExpectedRecordCountAndData()
    var
        TestBuffer: Record "Test Buffer";
        TableBackup: Record "Table Backup";
        EntryNo: Integer;
    begin
        // [GIVEN] Three records in the source table
        CreateTestBufferRecord('T001', 'First', 1, 1.1, true, 20260101D);
        CreateTestBufferRecord('T002', 'Second', 2, 2.2, false, 20260102D);
        CreateTestBufferRecord('T003', 'Third', 3, 3.3, true, 20260103D);

        // [WHEN] A JSON export backup is created for the table
        EntryNo := TableBackupMgt.CreateBackup(Database::"Test Buffer", Enum::"Backup Type"::"JSON Export", Enum::"Backup Operation Type"::"Manual Backup", 'Unit test backup');

        // [THEN] The backup entry reflects the source data
        Assert.IsTrue(TableBackup.Get(EntryNo), 'Backup entry should exist.');
        Assert.AreEqual(3, TableBackup."No. of Records", 'Unexpected number of backed up records.');
        Assert.AreEqual(Enum::"Backup Type"::"JSON Export".AsInteger(), TableBackup."Backup Type".AsInteger(), 'Unexpected backup type.');

        TableBackup.CalcFields("Backup Data");
        Assert.IsTrue(TableBackup."Backup Data".HasValue(), 'Backup Data blob should not be empty.');

        TestBuffer.DeleteAll(false);
    end;

    [Test]
    procedure BackupAndRestoreRoundTripRestoresAllFields()
    var
        TestBuffer: Record "Test Buffer";
        TableBackup: Record "Table Backup";
        EntryNo: Integer;
    begin
        // [GIVEN] Two records in the source table
        CreateTestBufferRecord('T101', 'Alpha', 10, 10.5, true, 20260201D);
        CreateTestBufferRecord('T102', 'Beta', 20, 20.75, false, 20260202D);

        // [GIVEN] A JSON export backup of the source table
        EntryNo := TableBackupMgt.CreateBackup(Database::"Test Buffer", Enum::"Backup Type"::"JSON Export", Enum::"Backup Operation Type"::"Manual Backup", 'Round-trip test backup');

        // [GIVEN] All source records have been deleted
        TestBuffer.DeleteAll(false);
        Assert.IsTrue(TestBuffer.IsEmpty(), 'Test buffer should be empty before restore.');

        // [WHEN] The backup is restored directly (bypassing the interactive confirm dialog)
        Assert.IsTrue(TableBackup.Get(EntryNo), 'Backup entry should exist.');
        TableBackupMgt.RestoreFromJSON(TableBackup);

        // [THEN] Both records are restored with their original field values
        Assert.AreEqual(2, TestBuffer.Count(), 'Unexpected number of restored records.');

        Assert.IsTrue(TestBuffer.Get('T101'), 'Record T101 should exist after restore.');
        Assert.AreEqual('Alpha', TestBuffer.Description, 'Description does not match for T101.');
        Assert.AreEqual(10, TestBuffer."Integer Value", 'Integer Value does not match for T101.');
        Assert.AreEqual(10.5, TestBuffer."Decimal Value", 'Decimal Value does not match for T101.');
        Assert.IsTrue(TestBuffer."Boolean Value", 'Boolean Value does not match for T101.');
        Assert.AreEqual(20260201D, TestBuffer."Date Value", 'Date Value does not match for T101.');

        Assert.IsTrue(TestBuffer.Get('T102'), 'Record T102 should exist after restore.');
        Assert.AreEqual('Beta', TestBuffer.Description, 'Description does not match for T102.');
        Assert.AreEqual(20, TestBuffer."Integer Value", 'Integer Value does not match for T102.');
        Assert.AreEqual(20.75, TestBuffer."Decimal Value", 'Decimal Value does not match for T102.');
        Assert.IsFalse(TestBuffer."Boolean Value", 'Boolean Value does not match for T102.');
        Assert.AreEqual(20260202D, TestBuffer."Date Value", 'Date Value does not match for T102.');

        TestBuffer.DeleteAll(false);
    end;

    [Test]
    procedure CreateBackupWithFilterOnlyBacksUpMatchingRecords()
    var
        TestBuffer: Record "Test Buffer";
        TableBackup: Record "Table Backup";
        FilterView: Text;
        EntryNo: Integer;
    begin
        // [GIVEN] Three records, only some of which match a filter on Integer Value
        CreateTestBufferRecord('F001', 'First', 1, 1.1, true, 20260101D);
        CreateTestBufferRecord('F002', 'Second', 2, 2.2, false, 20260102D);
        CreateTestBufferRecord('F003', 'Third', 3, 3.3, true, 20260103D);

        TestBuffer.SetFilter("Integer Value", '>%1', 1);
        FilterView := TestBuffer.GetView(false);

        // [WHEN] A filtered JSON export backup is created
        EntryNo := TableBackupMgt.CreateBackupWithFilter(Database::"Test Buffer", Enum::"Backup Type"::"JSON Export", Enum::"Backup Operation Type"::"Manual Backup", 'Filtered backup', FilterView);

        // [THEN] Only the records matching the filter were backed up
        Assert.IsTrue(TableBackup.Get(EntryNo), 'Backup entry should exist.');
        Assert.AreEqual(2, TableBackup."No. of Records", 'Unexpected number of backed up records for the filtered backup.');

        TestBuffer.SetRange("Integer Value");
        TestBuffer.DeleteAll(false);
    end;

    [Test]
    procedure CreateBackupWithSnapshotTypeAssignsSnapshotTableId()
    var
        TestBuffer: Record "Test Buffer";
        TableBackup: Record "Table Backup";
        EntryNo: Integer;
    begin
        // [GIVEN] A record in the source table
        TestBuffer.DeleteAll(false);
        CreateTestBufferRecord('S001', 'Snap', 1, 1.1, true, 20260101D);

        // [WHEN] A snapshot backup is created
        EntryNo := TableBackupMgt.CreateBackup(Database::"Test Buffer", Enum::"Backup Type"::Snapshot, Enum::"Backup Operation Type"::"Manual Backup", 'Snapshot backup');

        // [THEN] A snapshot table ID is assigned and the record count is correct
        Assert.IsTrue(TableBackup.Get(EntryNo), 'Backup entry should exist.');
        Assert.AreEqual(Enum::"Backup Type"::Snapshot.AsInteger(), TableBackup."Backup Type".AsInteger(), 'Unexpected backup type.');
        Assert.AreNotEqual(0, TableBackup."Snapshot Table ID", 'Snapshot Table ID should have been assigned.');
        Assert.AreEqual(1, TableBackup."No. of Records", 'Unexpected number of backed up records.');

        TestBuffer.DeleteAll(false);
    end;

    [Test]
    procedure CreateBackupWithFullBackupTypeStoresExpectedData()
    var
        TestBuffer: Record "Test Buffer";
        TableBackup: Record "Table Backup";
        EntryNo: Integer;
    begin
        // [GIVEN] A record in the source table
        TestBuffer.DeleteAll(false);
        CreateTestBufferRecord('F101', 'Full', 1, 1.1, true, 20260101D);

        // [WHEN] A full backup is created
        EntryNo := TableBackupMgt.CreateBackup(Database::"Test Buffer", Enum::"Backup Type"::"Full Backup", Enum::"Backup Operation Type"::"Manual Backup", 'Full backup');

        // [THEN] The backup entry reflects the source data
        Assert.IsTrue(TableBackup.Get(EntryNo), 'Backup entry should exist.');
        Assert.AreEqual(Enum::"Backup Type"::"Full Backup".AsInteger(), TableBackup."Backup Type".AsInteger(), 'Unexpected backup type.');
        Assert.AreEqual(1, TableBackup."No. of Records", 'Unexpected number of backed up records.');

        TestBuffer.DeleteAll(false);
    end;

    [Test]
    procedure BackupAndRestoreRoundTripRestoresTimeDateTimeAndGuidFields()
    var
        TestBuffer: Record "Test Buffer";
        TableBackup: Record "Table Backup";
        ExpectedGuid: Guid;
        ExpectedDateTime: DateTime;
        EntryNo: Integer;
    begin
        // [GIVEN] A record using Time, DateTime and Guid fields
        TestBuffer.DeleteAll(false);
        ExpectedGuid := CreateGuid();
        ExpectedDateTime := CreateDateTime(20260301D, 083000T);

        TestBuffer.Init();
        TestBuffer."No." := 'T201';
        TestBuffer."Time Value" := 083000T;
        TestBuffer."DateTime Value" := ExpectedDateTime;
        TestBuffer."Guid Value" := ExpectedGuid;
        TestBuffer.Insert(false);

        // [GIVEN] A JSON export backup of the source table
        EntryNo := TableBackupMgt.CreateBackup(Database::"Test Buffer", Enum::"Backup Type"::"JSON Export", Enum::"Backup Operation Type"::"Manual Backup", 'Time/DateTime/Guid backup');

        // [GIVEN] The source record has been deleted
        TestBuffer.DeleteAll(false);

        // [WHEN] The backup is restored directly
        Assert.IsTrue(TableBackup.Get(EntryNo), 'Backup entry should exist.');
        TableBackupMgt.RestoreFromJSON(TableBackup);

        // [THEN] Time, DateTime and Guid values are restored correctly
        Assert.IsTrue(TestBuffer.Get('T201'), 'Record T201 should exist after restore.');
        Assert.AreEqual(083000T, TestBuffer."Time Value", 'Time Value does not match.');
        Assert.AreEqual(ExpectedDateTime, TestBuffer."DateTime Value", 'DateTime Value does not match.');
        Assert.AreEqual(ExpectedGuid, TestBuffer."Guid Value", 'Guid Value does not match.');

        TestBuffer.DeleteAll(false);
    end;

    [Test]
    procedure CreateBackupWithSnapshotTypeIncrementsSnapshotTableId()
    var
        TestBuffer: Record "Test Buffer";
        TableBackup: Record "Table Backup";
        FirstEntryNo: Integer;
        SecondEntryNo: Integer;
        FirstSnapshotId: Integer;
    begin
        // [GIVEN] A record in the source table
        TestBuffer.DeleteAll(false);
        CreateTestBufferRecord('S101', 'Snap1', 1, 1.1, true, 20260101D);

        // [WHEN] Two snapshot backups are created in sequence
        FirstEntryNo := TableBackupMgt.CreateBackup(Database::"Test Buffer", Enum::"Backup Type"::Snapshot, Enum::"Backup Operation Type"::"Manual Backup", 'Snapshot 1');
        SecondEntryNo := TableBackupMgt.CreateBackup(Database::"Test Buffer", Enum::"Backup Type"::Snapshot, Enum::"Backup Operation Type"::"Manual Backup", 'Snapshot 2');

        // [THEN] The second snapshot gets the next sequential snapshot table ID
        Assert.IsTrue(TableBackup.Get(FirstEntryNo), 'First backup entry should exist.');
        FirstSnapshotId := TableBackup."Snapshot Table ID";
        Assert.IsTrue(TableBackup.Get(SecondEntryNo), 'Second backup entry should exist.');
        Assert.AreEqual(FirstSnapshotId + 1, TableBackup."Snapshot Table ID", 'Snapshot Table ID should increment sequentially.');

        TableBackup.SetFilter("Entry No.", '%1|%2', FirstEntryNo, SecondEntryNo);
        TableBackup.DeleteAll(false);
        TestBuffer.DeleteAll(false);
    end;

    [Test]
    procedure ViewBackupDataSucceedsWhenBackupDataExists()
    var
        TestBuffer: Record "Test Buffer";
        TableBackup: Record "Table Backup";
        EntryNo: Integer;
    begin
        // [GIVEN] A backup with data
        TestBuffer.DeleteAll(false);
        CreateTestBufferRecord('V001', 'View', 1, 1.1, true, 20260101D);
        EntryNo := TableBackupMgt.CreateBackup(Database::"Test Buffer", Enum::"Backup Type"::"JSON Export", Enum::"Backup Operation Type"::"Manual Backup", 'View backup');

        // [WHEN/THEN] Viewing the backup data does not raise an error
        Assert.IsTrue(TableBackup.Get(EntryNo), 'Backup entry should exist.');
        TableBackupMgt.ViewBackupData(TableBackup);

        TableBackup.Delete(false);
        TestBuffer.DeleteAll(false);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoCommit)]
    procedure ViewBackupDataErrorsWhenNoBackupDataExists()
    var
        TableBackup: Record "Table Backup";
    begin
        // [GIVEN] A backup entry without any backup data
        TableBackup.Init();
        TableBackup."Table ID" := Database::"Test Buffer";
        TableBackup.Insert(true);
        // CalcFields on a Blob field requires the row to be committed, not just visible in this transaction
        Commit();

        // [WHEN/THEN] Viewing the backup data raises the specific "no backup data" error
        asserterror TableBackupMgt.ViewBackupData(TableBackup);
        Assert.ExpectedError('No backup data found for this entry.');

        TableBackup.Delete(false);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoCommit)]
    procedure ExportBackupToFileErrorsWhenNoBackupDataExists()
    var
        TableBackup: Record "Table Backup";
    begin
        // [GIVEN] A backup entry without any backup data
        TableBackup.Init();
        TableBackup."Table ID" := Database::"Test Buffer";
        TableBackup.Insert(true);
        // CalcFields on a Blob field requires the row to be committed, not just visible in this transaction
        Commit();

        // [WHEN/THEN] Exporting to file raises the specific "no backup data" error (the actual client download is not exercised in automated tests)
        asserterror TableBackupMgt.ExportBackupToFile(TableBackup);
        Assert.ExpectedError('No backup data found for this entry.');

        TableBackup.Delete(false);
    end;

    [Test]
    procedure DeleteSnapshotTableDoesNotErrorForAnyId()
    begin
        // [WHEN/THEN] Deleting a snapshot table never errors, regardless of the ID (no-op cleanup)
        TableBackupMgt.DeleteSnapshotTable(0);
        TableBackupMgt.DeleteSnapshotTable(99000001);
    end;

    local procedure CreateTestBufferRecord(No: Code[20]; Description: Text[100]; IntegerValue: Integer; DecimalValue: Decimal; BooleanValue: Boolean; DateValue: Date)
    var
        TestBuffer: Record "Test Buffer";
    begin
        TestBuffer.Init();
        TestBuffer."No." := No;
        TestBuffer.Description := Description;
        TestBuffer."Integer Value" := IntegerValue;
        TestBuffer."Decimal Value" := DecimalValue;
        TestBuffer."Boolean Value" := BooleanValue;
        TestBuffer."Date Value" := DateValue;
        TestBuffer.Insert(false);
    end;
}
