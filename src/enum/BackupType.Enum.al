enum 50001 "Backup Type"
{
    Extensible = true;
    // 0 reserved for blank

    value(1; "JSON Export")
    {
        Caption = 'JSON Export';
    }
    value(2; Snapshot)
    {
        Caption = 'Snapshot';
    }
    value(3; "Full Backup")
    {
        Caption = 'Full Backup';
    }
}
