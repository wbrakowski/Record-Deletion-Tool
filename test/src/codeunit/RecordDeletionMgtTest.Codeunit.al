namespace RecordDeletionTool.Test;

using RecordDeletionTool;
using System.TestLibraries.Utilities;

codeunit 60001 "RecordDeletionMgt Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";
        RecordDeletionMgt: Codeunit "Record Deletion Mgt.";

    [Test]
    procedure SetSuggestedTableMarksExistingEntryForDeletion()
    var
        RecordDeletion: Record "Record Deletion";
    begin
        // [GIVEN] A Record Deletion entry exists for the test table, not yet marked for deletion
        DeleteRecordDeletionEntry(Database::"Test Buffer");
        CreateRecordDeletionEntry(Database::"Test Buffer");

        // [WHEN] The table is suggested for deletion
        RecordDeletionMgt.SetSuggestedTable(Database::"Test Buffer");

        // [THEN] The entry is marked for deletion
        Assert.IsTrue(RecordDeletion.Get(Database::"Test Buffer"), 'Record Deletion entry should exist.');
        Assert.IsTrue(RecordDeletion."Delete Records", 'Delete Records should be set to true.');

        DeleteRecordDeletionEntry(Database::"Test Buffer");
    end;

    [Test]
    procedure SetSuggestedTableDoesNothingWithoutExistingEntry()
    var
        RecordDeletion: Record "Record Deletion";
    begin
        // [GIVEN] No Record Deletion entry exists for the test table
        DeleteRecordDeletionEntry(Database::"Test Buffer");

        // [WHEN] The table is suggested for deletion
        RecordDeletionMgt.SetSuggestedTable(Database::"Test Buffer");

        // [THEN] No entry was created (guard clause exits early on missing record)
        Assert.IsFalse(RecordDeletion.Get(Database::"Test Buffer"), 'No Record Deletion entry should have been created.');
    end;

    [Test]
    procedure ClearRecordsToDeleteClearsAllFlags()
    var
        RecordDeletion: Record "Record Deletion";
    begin
        // [GIVEN] The test table is marked for deletion
        DeleteRecordDeletionEntry(Database::"Test Buffer");
        CreateRecordDeletionEntry(Database::"Test Buffer");
        Assert.IsTrue(RecordDeletion.Get(Database::"Test Buffer"), 'Record Deletion entry should exist.');
        RecordDeletion."Delete Records" := true;
        RecordDeletion.Modify(false);

        // [WHEN] All records to delete flags are cleared
        RecordDeletionMgt.ClearRecordsToDelete();

        // [THEN] The flag is cleared, and no entry remains marked for deletion
        Assert.IsTrue(RecordDeletion.Get(Database::"Test Buffer"), 'Record Deletion entry should still exist.');
        Assert.IsFalse(RecordDeletion."Delete Records", 'Delete Records should be cleared.');
        RecordDeletion.SetRange("Delete Records", true);
        Assert.IsTrue(RecordDeletion.IsEmpty(), 'No Record Deletion entry should be marked for deletion.');

        DeleteRecordDeletionEntry(Database::"Test Buffer");
    end;

    [Test]
    procedure CalcRecordsInTableReturnsRecordCount()
    var
        TestBuffer: Record "Test Buffer";
    begin
        // [GIVEN] Two records in the test table
        TestBuffer.DeleteAll(false);
        InsertTestBufferRecord('R001');
        InsertTestBufferRecord('R002');

        // [WHEN] The record count is calculated
        // [THEN] It matches the number of inserted records
        Assert.AreEqual(2, RecordDeletionMgt.CalcRecordsInTable(Database::"Test Buffer"), 'Unexpected record count.');

        TestBuffer.DeleteAll(false);
    end;

    [Test]
    procedure CheckTableRelationsForTableDetectsMissingRelatedRecord()
    var
        TestBuffer: Record "Test Buffer";
        RecordDeletionRelError: Record "Record Deletion Rel. Error";
    begin
        // [GIVEN] One record with a valid self-reference and one with a dangling reference
        TestBuffer.DeleteAll(false);
        RecordDeletionRelError.SetRange("Table ID", Database::"Test Buffer");
        RecordDeletionRelError.DeleteAll(false);

        InsertTestBufferRecordWithRelation('C001', '');
        InsertTestBufferRecordWithRelation('C002', 'C001');
        InsertTestBufferRecordWithRelation('C003', 'MISSING');

        // [WHEN] Table relations are checked for the test table
        RecordDeletionMgt.CheckTableRelationsForTable(Database::"Test Buffer");

        // [THEN] Only the dangling reference is reported as a relation error
        RecordDeletionRelError.SetRange("Table ID", Database::"Test Buffer");
        Assert.RecordCount(RecordDeletionRelError, 1);
        Assert.IsTrue(RecordDeletionRelError.FindFirst(), 'A relation error should have been recorded.');
        Assert.AreEqual(TestBuffer.FieldNo("Related No."), RecordDeletionRelError."Field No.", 'Unexpected field reported in the relation error.');

        RecordDeletionRelError.DeleteAll(false);
        TestBuffer.DeleteAll(false);
    end;

    [Test]
    procedure PerformDeletionDeletesFlaggedRecordsAndClearsRelationErrors()
    var
        TestBuffer: Record "Test Buffer";
        RecordDeletion: Record "Record Deletion";
        RecordDeletionRelError: Record "Record Deletion Rel. Error";
    begin
        // [GIVEN] No other table is currently flagged for deletion - safety net so this test can never
        // delete real data left flagged by earlier interactive use of the tool in this environment.
        RecordDeletion.SetRange("Delete Records", true);
        Assert.IsTrue(RecordDeletion.IsEmpty(), 'Aborting: another table is already flagged for deletion in this environment.');

        // [GIVEN] Records in the test table, flagged for deletion, plus a stale relation error entry
        TestBuffer.DeleteAll(false);
        InsertTestBufferRecord('P001');
        InsertTestBufferRecord('P002');

        DeleteRecordDeletionEntry(Database::"Test Buffer");
        CreateRecordDeletionEntry(Database::"Test Buffer");
        Assert.IsTrue(RecordDeletion.Get(Database::"Test Buffer"), 'Record Deletion entry should exist.');
        RecordDeletion."Delete Records" := true;
        RecordDeletion.Modify(false);

        RecordDeletionRelError.Init();
        RecordDeletionRelError."Table ID" := Database::"Test Buffer";
        RecordDeletionRelError."Entry No." := 1;
        RecordDeletionRelError.Insert(false);

        // [WHEN] Deletion is performed
        RecordDeletionMgt.PerformDeletion(false);

        // [THEN] The flagged table's records and its relation errors are gone
        Assert.IsTrue(TestBuffer.IsEmpty(), 'Test buffer records should have been deleted.');
        RecordDeletionRelError.SetRange("Table ID", Database::"Test Buffer");
        Assert.IsTrue(RecordDeletionRelError.IsEmpty(), 'Relation errors for the deleted table should have been cleared.');

        DeleteRecordDeletionEntry(Database::"Test Buffer");
    end;

    [Test]
    procedure CreateBackupsForDeletionCreatesBackupForFlaggedTable()
    var
        TestBuffer: Record "Test Buffer";
        RecordDeletion: Record "Record Deletion";
        TableBackup: Record "Table Backup";
        BackupCountBefore: Integer;
    begin
        // [GIVEN] No other table is currently flagged for deletion - same safety net as PerformDeletion's test,
        // since this also iterates every flagged Record Deletion entry.
        RecordDeletion.SetRange("Delete Records", true);
        Assert.IsTrue(RecordDeletion.IsEmpty(), 'Aborting: another table is already flagged for deletion in this environment.');

        // [GIVEN] A record in the test table, flagged for deletion
        TestBuffer.DeleteAll(false);
        InsertTestBufferRecord('B001');

        DeleteRecordDeletionEntry(Database::"Test Buffer");
        CreateRecordDeletionEntry(Database::"Test Buffer");
        Assert.IsTrue(RecordDeletion.Get(Database::"Test Buffer"), 'Record Deletion entry should exist.');
        RecordDeletion."Delete Records" := true;
        RecordDeletion.Modify(false);

        TableBackup.SetRange("Table ID", Database::"Test Buffer");
        BackupCountBefore := TableBackup.Count();

        // [WHEN] Backups are created for all flagged tables
        Assert.IsTrue(RecordDeletionMgt.CreateBackupsForDeletion(false), 'Backup creation should not be aborted (no unsupported field types involved).');

        // [THEN] Exactly one new backup was created for the flagged table
        TableBackup.SetRange("Table ID", Database::"Test Buffer");
        Assert.AreEqual(BackupCountBefore + 1, TableBackup.Count(), 'Expected exactly one new backup to be created.');

        TableBackup.DeleteAll(false);
        TestBuffer.DeleteAll(false);
        DeleteRecordDeletionEntry(Database::"Test Buffer");
    end;

    [Test]
    procedure CheckTableRelationsForTableDetectsMissingGuidRelation()
    var
        TestBufferA: Record "Test Buffer";
        TestBufferB: Record "Test Buffer";
        TestBufferC: Record "Test Buffer";
        TestBufferD: Record "Test Buffer";
        RecordDeletionRelError: Record "Record Deletion Rel. Error";
    begin
        // [GIVEN] Records with a valid GUID self-reference, a dangling one, and a blank one
        TestBufferA.DeleteAll(false);
        RecordDeletionRelError.SetRange("Table ID", Database::"Test Buffer");
        RecordDeletionRelError.DeleteAll(false);

        TestBufferA.Init();
        TestBufferA."No." := 'G001';
        TestBufferA.Insert(false);

        TestBufferB.Init();
        TestBufferB."No." := 'G002';
        TestBufferB."Related System ID" := TestBufferA.SystemId;
        TestBufferB.Insert(false);

        TestBufferC.Init();
        TestBufferC."No." := 'G003';
        TestBufferC."Related System ID" := CreateGuid();
        TestBufferC.Insert(false);

        TestBufferD.Init();
        TestBufferD."No." := 'G004';
        TestBufferD.Insert(false);

        // [WHEN] Table relations are checked for the test table
        RecordDeletionMgt.CheckTableRelationsForTable(Database::"Test Buffer");

        // [THEN] Only the dangling GUID reference is reported as a relation error
        RecordDeletionRelError.SetRange("Table ID", Database::"Test Buffer");
        Assert.RecordCount(RecordDeletionRelError, 1);
        Assert.IsTrue(RecordDeletionRelError.FindFirst(), 'A relation error should have been recorded.');
        Assert.AreEqual(TestBufferA.FieldNo("Related System ID"), RecordDeletionRelError."Field No.", 'Unexpected field reported in the relation error.');

        RecordDeletionRelError.DeleteAll(false);
        TestBufferA.DeleteAll(false);
    end;

    local procedure CreateRecordDeletionEntry(TableID: Integer)
    var
        RecordDeletion: Record "Record Deletion";
    begin
        RecordDeletion.Init();
        RecordDeletion."Table ID" := TableID;
        RecordDeletion.Insert(false);
    end;

    local procedure DeleteRecordDeletionEntry(TableID: Integer)
    var
        RecordDeletion: Record "Record Deletion";
    begin
        if RecordDeletion.Get(TableID) then
            RecordDeletion.Delete(false);
    end;

    local procedure InsertTestBufferRecord(BufferNo: Code[20])
    var
        TestBuffer: Record "Test Buffer";
    begin
        TestBuffer.Init();
        TestBuffer."No." := BufferNo;
        TestBuffer.Insert(false);
    end;

    local procedure InsertTestBufferRecordWithRelation(BufferNo: Code[20]; RelatedNo: Code[20])
    var
        TestBuffer: Record "Test Buffer";
    begin
        TestBuffer.Init();
        TestBuffer."No." := BufferNo;
        TestBuffer."Related No." := RelatedNo;
        TestBuffer.Insert(false);
    end;
}
