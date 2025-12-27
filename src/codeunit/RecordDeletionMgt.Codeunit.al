codeunit 50000 "Record Deletion Mgt."
{
    Permissions = tabledata "Record Deletion" = RIMD,
                  tabledata "Record Deletion Rel. Error" = RIMD,
                  tabledata "Bank Account Ledger Entry" = IMD,
                  tabledata "Change Log Entry" = IMD,
                  tabledata "Cust. Ledger Entry" = IMD,
                  tabledata "Detailed Cust. Ledg. Entry" = IMD,
                  tabledata "Detailed Vendor Ledg. Entry" = IMD,
                  tabledata "Dimension Set Entry" = IMD,
                  //   Tabledata 3905 = IMD,
                  tabledata "FA Ledger Entry" = IMD,
tabledata "G/L Entry" = IMD,
                  tabledata "G/L Entry - VAT Entry Link" = IMD,
                  tabledata "G/L Register" = IMD,
                  tabledata "Gen. Journal Line" = IMD,
                  tabledata "Issued Reminder Line" = IMD,
                  tabledata "Item Application Entry" = IMD,
                  tabledata "Item Ledger Entry" = IMD,
                  tabledata "Job Ledger Entry" = IMD,
                  tabledata "Phys. Inventory Ledger Entry" = IMD,
                  tabledata "Purch. Cr. Memo Hdr." = IMD,
                  tabledata "Purch. Cr. Memo Line" = IMD,
                  tabledata "Purch. Inv. Header" = IMD,
                  tabledata "Purch. Inv. Line" = IMD,
                  tabledata "Purch. Rcpt. Header" = IMD,
                  tabledata "Purch. Rcpt. Line" = IMD,
                  tabledata "Purchase Header" = IMD,
                  tabledata "Purchase Line" = IMD,
                  tabledata "Reminder/Fin. Charge Entry" = IMD,
                  tabledata "Return Receipt Line" = IMD,
                  tabledata "Return Shipment Header" = IMD,
                  tabledata "Return Shipment Line" = IMD,
                  tabledata "Sales Cr.Memo Header" = IMD,
                  tabledata "Sales Cr.Memo Line" = IMD,
                  tabledata "Sales Header" = IMD,
                  tabledata "Sales Invoice Header" = IMD,
                  tabledata "Sales Invoice Line" = IMD,
                  tabledata "Sales Line" = IMD,
                  tabledata "Sales Shipment Header" = IMD,
                  tabledata "Sales Shipment Line" = IMD,
                  tabledata "Value Entry" = IMD,
                  tabledata "VAT Entry" = IMD,
                  tabledata "Vendor Ledger Entry" = IMD;
    procedure InsertUpdateTables()
    var
        AllObjWithCaption: Record AllObjWithCaption;
        RecordDeletion: Record "Record Deletion";
    begin
        AllObjWithCaption.SetRange("Object Type", AllObjWithCaption."Object Type"::Table);
        // Do not include system tables
        AllObjWithCaption.SetFilter("Object ID", '< %1', 2000000001);
        if AllObjWithCaption.FindSet() then
            repeat
                RecordDeletion.Init();
                RecordDeletion."Table ID" := AllObjWithCaption."Object ID";
                RecordDeletion.Company := CopyStr(CompanyName(), 1, MaxStrLen(RecordDeletion.Company));
                if not RecordDeletion.Insert(true) then
                    continue;
            until AllObjWithCaption.Next() = 0;
    end;

    procedure SuggestRecordsToDelete()
    var
        RecordDeletion: Record "Record Deletion";
        AfterSuggestionDeleteCount: Integer;
        BeforeSuggestionDeleteCount: Integer;
        RecordsWereSuggestedMsg: Label '%1 records to delete were suggested.', Comment = '%1 = number of suggested records';
    begin
        RecordDeletion.SetRange("Delete Records", true);
        BeforeSuggestionDeleteCount := RecordDeletion.Count();

        SetSuggestedTablesForDeletion();

        RecordDeletion.SetRange("Delete Records", true);
        AfterSuggestionDeleteCount := RecordDeletion.Count();
        Message(RecordsWereSuggestedMsg, AfterSuggestionDeleteCount - BeforeSuggestionDeleteCount);
    end;

    local procedure SetSuggestedTablesForDeletion()
    begin
        SetSuggestedFinanceTables();
        SetSuggestedSalesTables();
        SetSuggestedPurchaseTables();
        SetSuggestedInventoryTables();
        SetSuggestedServiceTables();
        SetSuggestedWarehouseTables();
        SetSuggestedJobTables();
        SetSuggestedManufacturingTables();
        SetSuggestedCRMTables();
        SetSuggestedOtherTables();
    end;

    local procedure SetSuggestedFinanceTables()
    begin
        SetSuggestedTable(Database::"Bank Acc. Reconciliation Line");
        SetSuggestedTable(Database::"Bank Acc. Reconciliation");
        SetSuggestedTable(Database::"Bank Account Ledger Entry");
        SetSuggestedTable(Database::"Bank Account Statement Line");
        SetSuggestedTable(Database::"Bank Account Statement");
        SetSuggestedTable(Database::"Bank Stmt Multiple Match Line");
        SetSuggestedTable(Database::"Cash Flow Manual Revenue");
        SetSuggestedTable(Database::"Cash Flow Manual Expense");
        SetSuggestedTable(Database::"Cash Flow Forecast Entry");
        SetSuggestedTable(Database::"Cash Flow Worksheet Line");
        SetSuggestedTable(Database::"Certificate of Supply");
        SetSuggestedTable(Database::"Change Log Entry");
        SetSuggestedTable(Database::"Check Ledger Entry");
        SetSuggestedTable(Database::"Cost Budget Entry");
        SetSuggestedTable(Database::"Cost Budget Register");
        SetSuggestedTable(Database::"Cost Entry");
        SetSuggestedTable(Database::"Cost Journal Line");
        SetSuggestedTable(Database::"Cost Register");
        SetSuggestedTable(Database::"Credit Trans Re-export History");
        SetSuggestedTable(Database::"Credit Transfer Entry");
        SetSuggestedTable(Database::"Credit Transfer Register");
        SetSuggestedTable(Database::"Cust. Ledger Entry");
        SetSuggestedTable(Database::"Date Compr. Register");
        SetSuggestedTable(Database::"Detailed Cust. Ledg. Entry");
        SetSuggestedTable(Database::"Detailed Vendor Ledg. Entry");
        SetSuggestedTable(Database::"Direct Debit Collection Entry");
        SetSuggestedTable(Database::"Direct Debit Collection");
        SetSuggestedTable(Database::"Exch. Rate Adjmt. Reg.");
        SetSuggestedTable(Database::"FA G/L Posting Buffer");
        SetSuggestedTable(Database::"FA Ledger Entry");
        SetSuggestedTable(Database::"FA Register");
        SetSuggestedTable(Database::"Fin. Charge Comment Line");
        SetSuggestedTable(Database::"Finance Charge Memo Header");
        SetSuggestedTable(Database::"Finance Charge Memo Line");
        SetSuggestedTable(Database::"G/L - Item Ledger Relation");
        SetSuggestedTable(Database::"G/L Budget Entry");
        SetSuggestedTable(Database::"G/L Budget Name");
        SetSuggestedTable(Database::"G/L Entry - VAT Entry Link");
        SetSuggestedTable(Database::"G/L Entry");
        SetSuggestedTable(Database::"G/L Register");
        SetSuggestedTable(Database::"Gen. Jnl. Allocation");
        SetSuggestedTable(Database::"Gen. Journal Line");
        SetSuggestedTable(Database::"Ins. Coverage Ledger Entry");
        SetSuggestedTable(Database::"Insurance Register");
        SetSuggestedTable(Database::"Issued Fin. Charge Memo Header");
        SetSuggestedTable(Database::"Issued Fin. Charge Memo Line");
        SetSuggestedTable(Database::"Issued Reminder Header");
        SetSuggestedTable(Database::"Issued Reminder Line");
        SetSuggestedTable(Database::"Payable Vendor Ledger Entry");
        SetSuggestedTable(Database::"Payment Application Proposal");
        SetSuggestedTable(Database::"Payment Export Data");
        SetSuggestedTable(Database::"Payment Jnl. Export Error Text");
        SetSuggestedTable(Database::"Payment Matching Details");
        SetSuggestedTable(Database::"Post Value Entry to G/L");
        SetSuggestedTable(Database::"Posted Payment Recon. Hdr");
        SetSuggestedTable(Database::"Posted Payment Recon. Line");
        SetSuggestedTable(Database::"Reminder Comment Line");
        SetSuggestedTable(Database::"Reminder Header");
        SetSuggestedTable(Database::"Reminder Line");
        SetSuggestedTable(Database::"Reminder/Fin. Charge Entry");
        SetSuggestedTable(Database::"Reversal Entry");
        SetSuggestedTable(Database::"Rounding Residual Buffer");
        SetSuggestedTable(Database::"VAT Entry");
        SetSuggestedTable(Database::"VAT Rate Change Log Entry");
        SetSuggestedTable(Database::"VAT Report Header");
        SetSuggestedTable(Database::"VAT Report Line");
        SetSuggestedTable(Database::"VAT Report Line Relation");
        SetSuggestedTable(Database::"VAT Report Error Log");
        SetSuggestedTable(Database::"Vendor Ledger Entry");
    end;

    local procedure SetSuggestedSalesTables()
    begin
        SetSuggestedTable(Database::"Returns-Related Document");
        SetSuggestedTable(Database::"Return Receipt Header");
        SetSuggestedTable(Database::"Return Receipt Line");
        SetSuggestedTable(Database::"Sales Comment Line Archive");
        SetSuggestedTable(Database::"Sales Comment Line");
        SetSuggestedTable(Database::"Sales Cr.Memo Header");
        SetSuggestedTable(Database::"Sales Cr.Memo Line");
        SetSuggestedTable(Database::"Sales Header Archive");
        SetSuggestedTable(Database::"Sales Header");
        SetSuggestedTable(Database::"Sales Invoice Header");
        SetSuggestedTable(Database::"Sales Invoice Line");
        SetSuggestedTable(Database::"Sales Line Archive");
        SetSuggestedTable(Database::"Sales Line");
        SetSuggestedTable(Database::"Sales Planning Line");
        SetSuggestedTable(Database::"Sales Shipment Header");
        SetSuggestedTable(Database::"Sales Shipment Line");
    end;

    local procedure SetSuggestedPurchaseTables()
    begin
        SetSuggestedTable(Database::"Purch. Comment Line Archive");
        SetSuggestedTable(Database::"Purch. Comment Line");
        SetSuggestedTable(Database::"Purch. Cr. Memo Hdr.");
        SetSuggestedTable(Database::"Purch. Cr. Memo Line");
        SetSuggestedTable(Database::"Purch. Inv. Header");
        SetSuggestedTable(Database::"Purch. Inv. Line");
        SetSuggestedTable(Database::"Purch. Rcpt. Header");
        SetSuggestedTable(Database::"Purch. Rcpt. Line");
        SetSuggestedTable(Database::"Purchase Header Archive");
        SetSuggestedTable(Database::"Purchase Header");
        SetSuggestedTable(Database::"Purchase Line Archive");
        SetSuggestedTable(Database::"Purchase Line");
        SetSuggestedTable(Database::"Return Shipment Header");
        SetSuggestedTable(Database::"Return Shipment Line");
    end;

    local procedure SetSuggestedInventoryTables()
    begin
        SetSuggestedTable(Database::"Avg. Cost Adjmt. Entry Point");
        SetSuggestedTable(Database::"Inventory Adjmt. Entry (Order)");
        SetSuggestedTable(Database::"Inventory Period Entry");
        SetSuggestedTable(Database::"Inventory Report Entry");
        SetSuggestedTable(Database::"Item Analysis View Budg. Entry");
        SetSuggestedTable(Database::"Item Analysis View Entry");
        SetSuggestedTable(Database::"Item Analysis View");
        SetSuggestedTable(Database::"Item Application Entry History");
        SetSuggestedTable(Database::"Item Application Entry");
        SetSuggestedTable(Database::"Item Budget Entry");
        SetSuggestedTable(Database::"Item Charge Assignment (Purch)");
        SetSuggestedTable(Database::"Item Charge Assignment (Sales)");
        SetSuggestedTable(Database::"Item Entry Relation");
        SetSuggestedTable(Database::"Item Journal Line");
        SetSuggestedTable(Database::"Item Ledger Entry");
        SetSuggestedTable(Database::"Item Register");
        SetSuggestedTable(Database::"Item Tracking Comment");
        SetSuggestedTable(Database::"Lot No. Information");
        SetSuggestedTable(Database::"Phys. Inventory Ledger Entry");
        SetSuggestedTable(Database::"Serial No. Information");
        SetSuggestedTable(Database::"Tracking Specification");
        SetSuggestedTable(Database::"Transfer Header");
        SetSuggestedTable(Database::"Transfer Line");
        SetSuggestedTable(Database::"Transfer Receipt Header");
        SetSuggestedTable(Database::"Transfer Receipt Line");
        SetSuggestedTable(Database::"Transfer Shipment Header");
        SetSuggestedTable(Database::"Transfer Shipment Line");
        SetSuggestedTable(Database::"Value Entry Relation");
        SetSuggestedTable(Database::"Value Entry");
    end;

    local procedure SetSuggestedServiceTables()
    begin
        SetSuggestedTable(Database::"Contract Change Log");
        SetSuggestedTable(Database::"Contract Gain/Loss Entry");
        SetSuggestedTable(Database::"Contract/Service Discount");
        SetSuggestedTable(Database::"Filed Contract Line");
        SetSuggestedTable(Database::"Filed Service Contract Header");
        SetSuggestedTable(Database::"Loaner Entry");
        SetSuggestedTable(Database::"Maintenance Ledger Entry");
        SetSuggestedTable(Database::"Maintenance Registration");
        SetSuggestedTable(Database::"Service Comment Line");
        SetSuggestedTable(Database::"Service Contract Header");
        SetSuggestedTable(Database::"Service Contract Line");
        SetSuggestedTable(Database::"Service Cr.Memo Header");
        SetSuggestedTable(Database::"Service Cr.Memo Line");
        SetSuggestedTable(Database::"Service Document Log");
        SetSuggestedTable(Database::"Service Document Register");
        SetSuggestedTable(Database::"Service Header");
        SetSuggestedTable(Database::"Service Invoice Header");
        SetSuggestedTable(Database::"Service Invoice Line");
        SetSuggestedTable(Database::"Service Item Component");
        SetSuggestedTable(Database::"Service Item Line");
        SetSuggestedTable(Database::"Service Item Log");
        SetSuggestedTable(Database::"Service Item");
        SetSuggestedTable(Database::"Service Ledger Entry");
        SetSuggestedTable(Database::"Service Line Price Adjmt.");
        SetSuggestedTable(Database::"Service Line");
        SetSuggestedTable(Database::"Service Order Allocation");
        SetSuggestedTable(Database::"Service Register");
        SetSuggestedTable(Database::"Service Shipment Header");
        SetSuggestedTable(Database::"Service Shipment Item Line");
        SetSuggestedTable(Database::"Service Shipment Line");
        SetSuggestedTable(Database::"Warranty Ledger Entry");
    end;

    local procedure SetSuggestedWarehouseTables()
    begin
        SetSuggestedTable(Database::"Internal Movement Header");
        SetSuggestedTable(Database::"Internal Movement Line");
        SetSuggestedTable(Database::"Posted Invt. Pick Header");
        SetSuggestedTable(Database::"Posted Invt. Pick Line");
        SetSuggestedTable(Database::"Posted Invt. Put-away Header");
        SetSuggestedTable(Database::"Posted Invt. Put-away Line");
        SetSuggestedTable(Database::"Posted Whse. Receipt Header");
        SetSuggestedTable(Database::"Posted Whse. Receipt Line");
        SetSuggestedTable(Database::"Posted Whse. Shipment Header");
        SetSuggestedTable(Database::"Posted Whse. Shipment Line");
        SetSuggestedTable(Database::"Registered Invt. Movement Hdr.");
        SetSuggestedTable(Database::"Registered Invt. Movement Line");
        SetSuggestedTable(Database::"Registered Whse. Activity Hdr.");
        SetSuggestedTable(Database::"Registered Whse. Activity Line");
        SetSuggestedTable(Database::"Warehouse Activity Header");
        SetSuggestedTable(Database::"Warehouse Activity Line");
        SetSuggestedTable(Database::"Warehouse Entry");
        SetSuggestedTable(Database::"Warehouse Journal Line");
        SetSuggestedTable(Database::"Warehouse Receipt Header");
        SetSuggestedTable(Database::"Warehouse Receipt Line");
        SetSuggestedTable(Database::"Warehouse Register");
        SetSuggestedTable(Database::"Warehouse Request");
        SetSuggestedTable(Database::"Warehouse Shipment Header");
        SetSuggestedTable(Database::"Warehouse Shipment Line");
        SetSuggestedTable(Database::"Whse. Internal Pick Header");
        SetSuggestedTable(Database::"Whse. Internal Pick Line");
        SetSuggestedTable(Database::"Whse. Internal Put-away Header");
        SetSuggestedTable(Database::"Whse. Internal Put-away Line");
        SetSuggestedTable(Database::"Whse. Item Entry Relation");
        SetSuggestedTable(Database::"Whse. Item Tracking Line");
        SetSuggestedTable(Database::"Whse. Pick Request");
        SetSuggestedTable(Database::"Whse. Put-away Request");
        SetSuggestedTable(Database::"Whse. Worksheet Line");
    end;

    local procedure SetSuggestedJobTables()
    begin
        SetSuggestedTable(Database::"Job Entry No.");
        SetSuggestedTable(Database::"Job Journal Line");
        SetSuggestedTable(Database::"Job Ledger Entry");
        SetSuggestedTable(Database::"Job Planning Line Invoice");
        SetSuggestedTable(Database::"Job Planning Line");
        SetSuggestedTable(Database::"Job Queue Log Entry");
        SetSuggestedTable(Database::"Job Register");
        SetSuggestedTable(Database::"Job Task Dimension");
        SetSuggestedTable(Database::"Job Task");
        SetSuggestedTable(Database::"Job Usage Link");
        SetSuggestedTable(Database::"Job WIP Entry");
        SetSuggestedTable(Database::"Job WIP G/L Entry");
        SetSuggestedTable(Database::"Job WIP Total");
        SetSuggestedTable(Database::"Job WIP Warning");
        SetSuggestedTable(Database::Job);
        SetSuggestedTable(Database::"Res. Capacity Entry");
        SetSuggestedTable(Database::"Res. Journal Line");
        SetSuggestedTable(Database::"Res. Ledger Entry");
        SetSuggestedTable(Database::"Resource Register");
        SetSuggestedTable(Database::"Time Sheet Cmt. Line Archive");
        SetSuggestedTable(Database::"Time Sheet Comment Line");
        SetSuggestedTable(Database::"Time Sheet Detail Archive");
        SetSuggestedTable(Database::"Time Sheet Detail");
        SetSuggestedTable(Database::"Time Sheet Header Archive");
        SetSuggestedTable(Database::"Time Sheet Header");
        SetSuggestedTable(Database::"Time Sheet Line Archive");
        SetSuggestedTable(Database::"Time Sheet Line");
        SetSuggestedTable(Database::"Time Sheet Posting Entry");
    end;

    local procedure SetSuggestedManufacturingTables()
    begin
        SetSuggestedTable(Database::"Action Message Entry");
        SetSuggestedTable(Database::"Capacity Ledger Entry");
        SetSuggestedTable(Database::"Order Promising Line");
        SetSuggestedTable(Database::"Order Tracking Entry");
        SetSuggestedTable(Database::"Planning Assignment");
        SetSuggestedTable(Database::"Planning Component");
        SetSuggestedTable(Database::"Planning Error Log");
        SetSuggestedTable(Database::"Planning Routing Line");
        SetSuggestedTable(Database::"Prod. Order Capacity Need");
        SetSuggestedTable(Database::"Prod. Order Comment Line");
        SetSuggestedTable(Database::"Prod. Order Comp. Cmt Line");
        SetSuggestedTable(Database::"Prod. Order Component");
        SetSuggestedTable(Database::"Prod. Order Line");
        SetSuggestedTable(Database::"Prod. Order Routing Line");
        SetSuggestedTable(Database::"Prod. Order Routing Personnel");
        SetSuggestedTable(Database::"Prod. Order Routing Tool");
        SetSuggestedTable(Database::"Prod. Order Rtng Comment Line");
        SetSuggestedTable(Database::"Prod. Order Rtng Qlty Meas.");
        SetSuggestedTable(Database::"Production Forecast Entry");
        SetSuggestedTable(Database::"Production Order");
        SetSuggestedTable(Database::"Requisition Line");
        SetSuggestedTable(Database::"Reservation Entry");
        SetSuggestedTable(Database::"Unplanned Demand");
        SetSuggestedTable(Database::"Untracked Planning Element");
    end;

    local procedure SetSuggestedCRMTables()
    begin
        SetSuggestedTable(Database::"Campaign Entry");
        SetSuggestedTable(Database::"Inter. Log Entry Comment Line");
        SetSuggestedTable(Database::"Interaction Log Entry");
        SetSuggestedTable(Database::"Opportunity Entry");
        SetSuggestedTable(Database::"Segment Criteria Line");
        SetSuggestedTable(Database::"Segment Header");
        SetSuggestedTable(Database::"Segment History");
        SetSuggestedTable(Database::"Segment Interaction Language");
        SetSuggestedTable(Database::"Segment Line");
        SetSuggestedTable(Database::"To-do");
        SetSuggestedTable(Database::Attachment);
        SetSuggestedTable(Database::Attendee);
        SetSuggestedTable(Database::Opportunity);
    end;

    local procedure SetSuggestedOtherTables()
    begin
        SetSuggestedTable(Database::"Analysis View Budget Entry");
        SetSuggestedTable(Database::"Analysis View Entry");
        SetSuggestedTable(Database::"Analysis View");
        SetSuggestedTable(Database::"Approval Comment Line");
        SetSuggestedTable(Database::"Approval Entry");
        SetSuggestedTable(Database::"Assemble-to-Order Link");
        SetSuggestedTable(Database::"Assembly Comment Line");
        SetSuggestedTable(Database::"Assembly Header");
        SetSuggestedTable(Database::"Assembly Line");
        SetSuggestedTable(Database::"Comment Line");
        SetSuggestedTable(Database::"Dimension Set Entry");
        SetSuggestedTable(Database::"Dimension Set Tree Node");
        SetSuggestedTable(Database::"Document Entry");
        SetSuggestedTable(Database::"Email Item");
        SetSuggestedTable(Database::"Employee Absence");
        SetSuggestedTable(Database::"Error Buffer");
        SetSuggestedTable(Database::"Handled IC Inbox Jnl. Line");
        SetSuggestedTable(Database::"Handled IC Inbox Purch. Header");
        SetSuggestedTable(Database::"Handled IC Inbox Purch. Line");
        SetSuggestedTable(Database::"Handled IC Inbox Sales Header");
        SetSuggestedTable(Database::"Handled IC Inbox Sales Line");
        SetSuggestedTable(Database::"Handled IC Inbox Trans.");
        SetSuggestedTable(Database::"Handled IC Outbox Jnl. Line");
        SetSuggestedTable(Database::"Handled IC Outbox Purch. Hdr");
        SetSuggestedTable(Database::"Handled IC Outbox Purch. Line");
        SetSuggestedTable(Database::"Handled IC Outbox Sales Header");
        SetSuggestedTable(Database::"Handled IC Outbox Sales Line");
        SetSuggestedTable(Database::"Handled IC Outbox Trans.");
        SetSuggestedTable(Database::"IC Comment Line");
        SetSuggestedTable(Database::"IC Document Dimension");
        SetSuggestedTable(Database::"IC Inbox Jnl. Line");
        SetSuggestedTable(Database::"IC Inbox Purchase Header");
        SetSuggestedTable(Database::"IC Inbox Purchase Line");
        SetSuggestedTable(Database::"IC Inbox Sales Header");
        SetSuggestedTable(Database::"IC Inbox Sales Line");
        SetSuggestedTable(Database::"IC Inbox Transaction");
        SetSuggestedTable(Database::"IC Inbox/Outbox Jnl. Line Dim.");
        SetSuggestedTable(Database::"IC Outbox Jnl. Line");
        SetSuggestedTable(Database::"IC Outbox Purchase Header");
        SetSuggestedTable(Database::"IC Outbox Purchase Line");
        SetSuggestedTable(Database::"IC Outbox Sales Header");
        SetSuggestedTable(Database::"IC Outbox Sales Line");
        SetSuggestedTable(Database::"IC Outbox Transaction");
        SetSuggestedTable(Database::"Incoming Document");
        SetSuggestedTable(Database::"Posted Approval Comment Line");
        SetSuggestedTable(Database::"Posted Approval Entry");
        SetSuggestedTable(Database::"Posted Assemble-to-Order Link");
        SetSuggestedTable(Database::"Posted Assembly Header");
        SetSuggestedTable(Database::"Posted Assembly Line");
    end;

    procedure ClearRecordsToDelete()
    var
        RecordDeletion: Record "Record Deletion";
    begin
        RecordDeletion.ModifyAll("Delete Records", false, true);
    end;

    procedure DeleteRecords(RunTrigger: Boolean)
    var
        ConfirmManagement: Codeunit "Confirm Management";
        CreateBackup: Boolean;
    begin
        if not ConfirmDeletion(RunTrigger, ConfirmManagement) then
            exit;

        CreateBackup := AskForBackup(ConfirmManagement);

        if CreateBackup then
            CreateBackupsForDeletion(RunTrigger);

        PerformDeletion(RunTrigger);
    end;

    local procedure ConfirmDeletion(RunTrigger: Boolean; var ConfirmManagement: Codeunit "Confirm Management"): Boolean
    var
        DeleteRecordsQst: Label 'Delete Records with RunTrigger = false?';
        DeleteRecordsWithTriggerQst: Label 'Delete Records with RunTrigger = true?';
    begin
        if RunTrigger then begin
            if not ConfirmManagement.GetResponseOrDefault(DeleteRecordsWithTriggerQst, false) then
                exit(false);
#pragma warning disable AA0005
        end else
            if not ConfirmManagement.GetResponseOrDefault(DeleteRecordsQst, false) then
                exit(false);
#pragma warning restore AA0005
        exit(true);
    end;

    local procedure AskForBackup(var ConfirmManagement: Codeunit "Confirm Management"): Boolean
    var
        CreateBackupQst: Label 'Do you want to create a backup before deleting records?\\This is highly recommended to allow restoration if needed.';
    begin
        exit(ConfirmManagement.GetResponseOrDefault(CreateBackupQst, true));
    end;

    local procedure CreateBackupsForDeletion(RunTrigger: Boolean)
    var
        RecordDeletion: Record "Record Deletion";
        TableBackupMgt: Codeunit "Table Backup Mgt.";
        BackupType: Enum "Backup Type";
        BackupOperationType: Enum "Backup Operation Type";
        UpdateDialog: Dialog;
        CreatingBackupTxt: Label 'Creating Backup!\Table: #1#######', Comment = '%1 = Table ID';
        BackupDescriptionTxt: Label 'Backup before deletion (RunTrigger=%1)', Comment = '%1 = RunTrigger value';
    begin
        UpdateDialog.Open(CreatingBackupTxt);

        if RecordDeletion.FindSet() then
            repeat
                if RecordDeletion."Delete Records" then begin
                    UpdateDialog.Update(1, Format(RecordDeletion."Table ID"));
                    TableBackupMgt.CreateBackup(
                        RecordDeletion."Table ID",
                        BackupType::"JSON Export",
                        BackupOperationType::"Before Deletion",
                        CopyStr(StrSubstNo(BackupDescriptionTxt, RunTrigger), 1, 250));
                end;
            until RecordDeletion.Next() = 0;

        UpdateDialog.Close();
    end;

    local procedure PerformDeletion(RunTrigger: Boolean)
    var
        RecordDeletion: Record "Record Deletion";
        RecordDeletionRelError: Record "Record Deletion Rel. Error";
        RecordRef: RecordRef;
        UpdateDialog: Dialog;
        DeletingRecordsTxt: Label 'Deleting Records!\Table: #1#######', Comment = '%1 = Table ID';
    begin
        UpdateDialog.Open(DeletingRecordsTxt);

        if RecordDeletion.FindSet() then
            repeat
                if RecordDeletion."Delete Records" then begin
                    UpdateDialog.Update(1, Format(RecordDeletion."Table ID"));
                    RecordRef.Open(RecordDeletion."Table ID");
                    RecordRef.DeleteAll(RunTrigger);
                    RecordRef.Close();
                    RecordDeletionRelError.SetRange("Table ID", RecordDeletion."Table ID");
                    RecordDeletionRelError.DeleteAll(true);
                end;
            until RecordDeletion.Next() = 0;

        UpdateDialog.Close();
    end;

    procedure CheckTableRelations()
    var
        RecordDeletion: Record "Record Deletion";
        RecordDeletionRelError: Record "Record Deletion Rel. Error";
        ConfirmManagement: Codeunit "Confirm Management";
        UpdateDialog: Dialog;
        CheckingRelationsTxt: Label 'Checking Relations Between Records!\Table: #1#######', Comment = '%1 = Table ID';
        CheckRelationsQst: Label 'Check Table Relations?';
    begin
        if not ConfirmManagement.GetResponseOrDefault(CheckRelationsQst, false) then
            exit;

        UpdateDialog.Open(CheckingRelationsTxt);
        RecordDeletionRelError.DeleteAll(false);

        if RecordDeletion.FindSet() then
            repeat
                UpdateDialog.Update(1, Format(RecordDeletion."Table ID"));
                CheckTableRelationsForTable(RecordDeletion."Table ID");
            until RecordDeletion.Next() = 0;

        UpdateDialog.Close();
    end;

    local procedure CheckTableRelationsForTable(TableID: Integer)
    var
        TableMetadata: Record "Table Metadata";
        RecordRef: RecordRef;
    begin
        // Only allow "normal" tables to avoid errors, Skip TableType MicrosoftGraph and CRM etc.
        TableMetadata.SetRange(ID, TableID);
        TableMetadata.SetRange(TableType, TableMetadata.TableType::Normal);
        if TableMetadata.IsEmpty() then
            exit;

        RecordRef.Open(TableID);
        if RecordRef.FindSet() then
            repeat
                CheckRecordRelations(RecordRef);
            until RecordRef.Next() = 0;
        RecordRef.Close();
    end;

    local procedure CheckRecordRelations(var RecordRef: RecordRef)
    var
        Field: Record Field;
    begin
        Field.SetRange(TableNo, RecordRef.Number());
        Field.SetRange(Class, Field.Class::Normal);
        Field.SetRange(ObsoleteState, Field.ObsoleteState::No);
        Field.SetFilter(RelationTableNo, '<>0');

        // Next 4 lines look funny but are needed to avoid this error:
        // "Table connection for table type CRM must be registered using RegisterTableConnection or cmdlet New-NAVTableConnection before it can be used"
        if RecordRef.Number() = 5330 then
            Field.SetFilter("No.", '<> %1', 124)
        else
            if RecordRef.Number() = 7200 then
                Field.SetFilter("No.", '<> %1', 124);

        if Field.FindSet() then
            repeat
                CheckFieldRelation(RecordRef, Field);
            until Field.Next() = 0;
    end;

    local procedure CheckFieldRelation(var RecordRef: RecordRef; Field: Record Field)
    var
        FieldRef: FieldRef;
    begin
        FieldRef := RecordRef.Field(Field."No.");
        if (Format(FieldRef.Value()) <> '') and (Format(FieldRef.Value()) <> '0') then
            ValidateFieldRelation(RecordRef, FieldRef, Field);
    end;

    local procedure ValidateFieldRelation(var RecordRef: RecordRef; var FieldRef: FieldRef; Field: Record Field)
    var
        RecordRef2: RecordRef;
        FieldRef2: FieldRef;
        FieldRefInitialized: Boolean;
    begin
        RecordRef2.Open(Field.RelationTableNo);
        FieldRefInitialized := false;

        if Field.RelationFieldNo <> 0 then begin
            FieldRef2 := RecordRef2.Field(Field.RelationFieldNo);
            FieldRefInitialized := true;
        end else
            FieldRefInitialized := GetPrimaryKeyFieldRef(Field.RelationTableNo, RecordRef2, FieldRef2);

        if FieldRefInitialized then
            if (FieldRef.Type() = FieldRef2.Type()) and (FieldRef.Length() = FieldRef2.Length()) then
                CheckRelationExists(RecordRef, FieldRef, RecordRef2, FieldRef2);

        RecordRef2.Close();
    end;

    local procedure GetPrimaryKeyFieldRef(TableNo: Integer; var RecordRef2: RecordRef; var FieldRef2: FieldRef): Boolean
    var
        Field2: Record Field;
        KeyRec: Record "Key";
        CouldNotGetKeyErr: Label 'Could not get key for table %1', Comment = '%1 = Table ID';
    begin
        if not KeyRec.Get(TableNo, 1) then  // PK
            Error(CouldNotGetKeyErr, TableNo);

        Field2.SetRange(TableNo, TableNo);
        Field2.SetFilter(FieldName, CopyStr(KeyRec.Key, 1, 30));
        if Field2.FindFirst() then begin // No Match if Dual PK
            FieldRef2 := RecordRef2.Field(Field2."No.");
            exit(true);
        end;
        exit(false);
    end;

    local procedure CheckRelationExists(var RecordRef: RecordRef; var FieldRef: FieldRef; var RecordRef2: RecordRef; var FieldRef2: FieldRef)
    var
        RecordDeletionRelError: Record "Record Deletion Rel. Error";
        EntryNo: Integer;
        NotExistsTxt: Label '%1 => %2 = ''%3'' does not exist in the ''%4'' table', Comment = '%1 = Source Table Name, %2 = Source Field Name, %3 = Field Value, %4 = Target Table Name';
    begin
        FieldRef2.SetRange(FieldRef.Value());
        if RecordRef2.FindFirst() then
            exit;

        RecordDeletionRelError.SetRange("Table ID", RecordRef.Number());
        if RecordDeletionRelError.FindLast() then
            EntryNo := RecordDeletionRelError."Entry No." + 1
        else
            EntryNo := 1;

        RecordDeletionRelError.Init();
        RecordDeletionRelError."Table ID" := RecordRef.Number();
        RecordDeletionRelError."Entry No." := EntryNo;
        RecordDeletionRelError."Field No." := FieldRef.Number();
        RecordDeletionRelError.Error := CopyStr(StrSubstNo(NotExistsTxt, Format(RecordRef.GetPosition()), Format(FieldRef2.Name()), Format(FieldRef.Value()), Format(RecordRef2.Name())), 1, 250);
        RecordDeletionRelError.Insert(false);
    end;

    procedure ViewRecords(RecordDeletion: Record "Record Deletion")
    begin
        Hyperlink(GetUrl(ClientType::Current, CompanyName(), ObjectType::Table, RecordDeletion."Table ID"));
    end;

    procedure SetSuggestedTable(TableID: Integer)
    var
        RecordDeletion: Record "Record Deletion";
    begin
        if not RecordDeletion.Get(TableID) then
            exit;
        RecordDeletion."Delete Records" := true;
        RecordDeletion.Modify(true);
    end;

    procedure CalcRecordsInTable(TableNoToCheck: Integer): Integer
    var
        Field: Record Field;
        RecordRef: RecordRef;
        NoOfRecords: Integer;
    begin
        Field.SetRange(TableNo, TableNoToCheck);
        if Field.IsEmpty() then
            exit(0);
        RecordRef.Open(TableNoToCheck);
        RecordRef.ReadIsolation(IsolationLevel::UpdLock);
        NoOfRecords := RecordRef.Count();
        RecordRef.Close();
        exit(NoOfRecords);
    end;

    procedure SuggestUnlicensedPartnerOrCustomRecordsToDelete()
    var
        RecordDeletion: Record "Record Deletion";
        RecsSuggestedCount: Integer;
        RecordsSuggestedMsg: Label '%1 unlicensed partner or custom records were suggested.', Comment = '%1 number of unlicensed records';
    begin
        RecordDeletion.SetFilter("Table ID", '> %1', 49999);
        if RecordDeletion.FindSet(false) then
            repeat
                if not IsRecordStandardTable(RecordDeletion."Table ID") then
                    if not IsRecordInLicense(RecordDeletion."Table ID") then begin
                        SetSuggestedTable(RecordDeletion."Table ID");
                        RecsSuggestedCount += 1;
                    end;
            until RecordDeletion.Next() = 0;

        Message(RecordsSuggestedMsg, RecsSuggestedCount);
    end;

    local procedure IsRecordInLicense(TableID: Integer): Boolean
    var
        LicensePermission: Record "License Permission";
    begin
        // LicensePermission.Get(LicensePermission."Object Type"::Table, TableID);
        if not LicensePermission.Get(LicensePermission."Object Type"::TableData, TableID) then
            exit(false);

        if (LicensePermission."Read Permission" = LicensePermission."Read Permission"::" ") and
            (LicensePermission."Insert Permission" = LicensePermission."Insert Permission"::" ") and
            (LicensePermission."Modify Permission" = LicensePermission."Modify Permission"::" ") and
            (LicensePermission."Delete Permission" = LicensePermission."Delete Permission"::" ") and
            (LicensePermission."Execute Permission" = LicensePermission."Execute Permission"::" ")
        then
            exit(false)
        else
            exit(true);
    end;

    local procedure IsRecordStandardTable(TableID: Integer): Boolean
    begin
        case true of
            //5005270 - 5005363
            // 5005363 = "Phys. Invt. Diff. List Buffer"
            // (TableID >= Database::"Delivery Reminder Header") and (TableID <= Database::"Phys. Invt. Diff. List Buffer"):
            (TableID >= 5005270) and (TableID <= 5005363):
                exit(true);
            //99000750 - 99008535
            // 99000750 = Workshift
            (TableID >= 99000750) and (TableID <= 99008535):
                exit(true);
            // Microsoft Localizations
            (TableID >= 100000) and (TableID <= 999999):
                exit(true);
        end;
        exit(false);
    end;
}