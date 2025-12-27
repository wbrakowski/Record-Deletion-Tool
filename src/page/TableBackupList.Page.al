page 50002 "Table Backup List"
{
    ApplicationArea = All;
    Caption = 'Table Backups';
    CardPageId = "Table Backup Card";
    Editable = false;
    PageType = List;
    SourceTable = "Table Backup";
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {
                }
                field("Table ID"; Rec."Table ID")
                {
                }
                field("Table Name"; Rec."Table Name")
                {
                }
                field("Backup Type"; Rec."Backup Type")
                {
                }
                field("Operation Type"; Rec."Operation Type")
                {
                }
                field("Backup Date Time"; Rec."Backup Date Time")
                {
                }
                field("User ID"; Rec."User ID")
                {
                }
                field("No. of Records"; Rec."No. of Records")
                {
                    Style = Strong;
                    StyleExpr = true;
                }
                field("Backup Size (KB)"; Rec."Backup Size (KB)")
                {
                }
                field(Description; Rec.Description)
                {
                }
                field(Restored; Rec.Restored)
                {
                }
                field("Restore Date Time"; Rec."Restore Date Time")
                {
                }
                field("Company Name"; Rec."Company Name")
                {
                    Visible = false;
                }
            }
        }
        area(FactBoxes)
        {
            systempart(Links; Links)
            {
            }
            systempart(Notes; Notes)
            {
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(CreateBackup)
            {
                Caption = 'Create Backup';
                Image = Export;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Create a new backup of a table.';

                trigger OnAction()
                var
                    CreateBackupPage: Page "Create Table Backup";
                begin
                    CreateBackupPage.RunModal();
                    CurrPage.Update(false);
                end;
            }
            action(RestoreBackup)
            {
                Caption = 'Restore Backup';
                Enabled = Rec."Entry No." <> 0;
                Image = Import;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Restore records from the selected backup.';

                trigger OnAction()
                begin
                    Rec.RestoreBackup();
                    CurrPage.Update(false);
                end;
            }
            action(ExportToFile)
            {
                Caption = 'Export to File';
                Enabled = Rec."Entry No." <> 0;
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
            action(ImportFromFile)
            {
                Caption = 'Import from File';
                Image = ImportExcel;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Import backup data from a JSON file.';

                trigger OnAction()
                var
                    AllObjWithCaption: Record AllObjWithCaption;
                    TableBackupMgt: Codeunit "Table Backup Mgt.";
                begin
                    if Page.RunModal(Page::"Table Objects", AllObjWithCaption) = Action::LookupOK then begin
                        TableBackupMgt.ImportBackupFromFile(AllObjWithCaption."Object ID");
                        CurrPage.Update(false);
                    end;
                end;
            }
            action(ViewData)
            {
                Caption = 'View Backup Data';
                Enabled = Rec."Entry No." <> 0;
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
            action(DeleteOldBackups)
            {
                Caption = 'Delete Old Backups';
                Image = Delete;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Delete backups older than a specified number of days.';

                trigger OnAction()
                var
                    TableBackup: Record "Table Backup";
                    ConfirmManagement: Codeunit "Confirm Management";
                    CutoffDate: DateTime;
                    Days: Integer;
                    DeletedCount: Integer;
                    DeleteConfirmQst: Label 'This will delete %1 backup(s) older than %2 days. Continue?', Comment = '%1 = No. of backups, %2 = Days';
                    DeletedMsg: Label '%1 backup(s) have been deleted.', Comment = '%1 = No. of backups';
                    NoBackupsFoundMsg: Label 'No backups found older than %1 days.', Comment = '%1 = Days to keep';
                begin
                    Days := 30; // Default: 30 days

                    CutoffDate := CreateDateTime(Today() - Days, 0T);
                    TableBackup.SetFilter("Backup Date Time", '<%1', CutoffDate);
                    if TableBackup.IsEmpty() then begin
                        Message(NoBackupsFoundMsg, Days);
                        exit;
                    end;

                    if not ConfirmManagement.GetResponseOrDefault(StrSubstNo(DeleteConfirmQst, TableBackup.Count(), Days), false) then
                        exit;

                    DeletedCount := TableBackup.Count();
                    TableBackup.DeleteAll(true);
                    Message(DeletedMsg, DeletedCount);
                    CurrPage.Update(false);
                end;
            }
        }
    }
}
