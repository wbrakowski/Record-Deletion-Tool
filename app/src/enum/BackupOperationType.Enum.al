namespace RecordDeletionTool;

/// <summary>
/// Specifies why a table backup was created.
/// </summary>
enum 50000 "Backup Operation Type"
{
    Extensible = true;

    value(0; " ")
    {
        Caption = ' ', Locked = true;
    }
    value(1; "Manual Backup")
    {
        Caption = 'Manual Backup';
    }
    value(2; "Before Deletion")
    {
        Caption = 'Before Deletion';
    }
    value(3; "Before Modification")
    {
        Caption = 'Before Modification';
        ObsoleteReason = 'Never used by the tool.';
        ObsoleteState = Pending;
        ObsoleteTag = '1.1.0.0';
    }
    value(4; "Scheduled Backup")
    {
        Caption = 'Scheduled Backup';
        ObsoleteReason = 'Never used by the tool.';
        ObsoleteState = Pending;
        ObsoleteTag = '1.1.0.0';
    }
}
