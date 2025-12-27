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
    }
    value(4; "Scheduled Backup")
    {
        Caption = 'Scheduled Backup';
    }
}
