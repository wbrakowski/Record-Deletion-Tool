page 50003 "Table Backup Card"
{
    ApplicationArea = All;
    Caption = 'Table Backup Card';
    PageType = Card;
    SourceTable = "Table Backup";
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("Entry No."; Rec."Entry No.")
                {
                    Editable = false;
                }
                field("Table ID"; Rec."Table ID")
                {
                    Editable = false;
                }
                field("Table Name"; Rec."Table Name")
                {
                    Editable = false;
                }
                field(Description; Rec.Description)
                {
                }
            }
            group(BackupInfo)
            {
                Caption = 'Backup Information';

                field("Backup Type"; Rec."Backup Type")
                {
                    Editable = false;
                }
                field("Operation Type"; Rec."Operation Type")
                {
                    Editable = false;
                }
                field("Backup Date Time"; Rec."Backup Date Time")
                {
                    Editable = false;
                }
                field("User ID"; Rec."User ID")
                {
                    Editable = false;
                }
                field("Company Name"; Rec."Company Name")
                {
                    Editable = false;
                }
            }
            group(Statistics)
            {
                Caption = 'Statistics';

                field("No. of Records"; Rec."No. of Records")
                {
                    Editable = false;
                    Style = Strong;
                    StyleExpr = true;
                }
                field("Backup Size (KB)"; Rec."Backup Size (KB)")
                {
                    Editable = false;
                }
                field("File Name"; Rec."File Name")
                {
                    Editable = false;
                }
                field("Filter View"; Rec."Filter View")
                {
                    Editable = false;
                    MultiLine = true;
                }
            }
            group(RestoreInfo)
            {
                Caption = 'Restore Information';

                field(Restored; Rec.Restored)
                {
                    Editable = false;
                }
                field("Restore Date Time"; Rec."Restore Date Time")
                {
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(RestoreBackup)
            {
                Caption = 'Restore Backup';
                Image = Import;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Restore records from this backup.';

                trigger OnAction()
                begin
                    Rec.RestoreBackup();
                    CurrPage.Update(false);
                end;
            }
            action(ExportToFile)
            {
                Caption = 'Export to File';
                Image = ExportFile;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Export the backup data to a JSON file.';

                trigger OnAction()
                begin
                    Rec.ExportToFile();
                end;
            }
            action(ViewData)
            {
                Caption = 'View Backup Data';
                Image = View;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Specifies that the backup data (first 1000 characters) will be displayed.';

                trigger OnAction()
                begin
                    Rec.ViewBackupData();
                end;
            }
        }
    }
}
