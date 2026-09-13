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
