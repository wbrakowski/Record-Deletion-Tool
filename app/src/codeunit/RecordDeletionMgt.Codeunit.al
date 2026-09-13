namespace RecordDeletionTool;

using Microsoft.Assembly.Comment;
using Microsoft.Assembly.Document;
using Microsoft.Assembly.History;
using Microsoft.Bank.Check;
using Microsoft.Bank.DirectDebit;
using Microsoft.Bank.Ledger;
using Microsoft.Bank.Payment;
using Microsoft.Bank.Reconciliation;
using Microsoft.Bank.Reports;
using Microsoft.Bank.Statement;
using Microsoft.CashFlow.Forecast;
using Microsoft.CashFlow.Setup;
using Microsoft.CashFlow.Worksheet;
using Microsoft.CostAccounting.Budget;
using Microsoft.CostAccounting.Journal;
using Microsoft.CostAccounting.Ledger;
using Microsoft.CRM.Campaign;
using Microsoft.CRM.Interaction;
using Microsoft.CRM.Opportunity;
using Microsoft.CRM.Segment;
using Microsoft.CRM.Task;
using Microsoft.EServices.EDocument;
using Microsoft.Finance.Analysis;
using Microsoft.Finance.Currency;
using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Budget;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Finance.GeneralLedger.Reversal;
using Microsoft.Finance.VAT.Ledger;
using Microsoft.Finance.VAT.RateChange;
using Microsoft.Finance.VAT.Reporting;
using Microsoft.FixedAssets.Insurance;
using Microsoft.FixedAssets.Journal;
using Microsoft.FixedAssets.Ledger;
using Microsoft.FixedAssets.Maintenance;
using Microsoft.Foundation.Comment;
using Microsoft.Foundation.Navigate;
using Microsoft.Foundation.Period;
using Microsoft.HumanResources.Absence;
using Microsoft.Intercompany.Comment;
using Microsoft.Intercompany.Dimension;
using Microsoft.Intercompany.Inbox;
using Microsoft.Intercompany.Outbox;
using Microsoft.Inventory.Analysis;
using Microsoft.Inventory.Availability;
using Microsoft.Inventory.Costing;
using Microsoft.Inventory.Counting.Journal;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Journal;
using Microsoft.Inventory.Ledger;
using Microsoft.Inventory.Planning;
using Microsoft.Inventory.Reconciliation;
using Microsoft.Inventory.Requisition;
using Microsoft.Inventory.Setup;
using Microsoft.Inventory.Tracking;
using Microsoft.Inventory.Transfer;
using Microsoft.Manufacturing.Capacity;
using Microsoft.Manufacturing.Document;
using Microsoft.Manufacturing.Forecast;
using Microsoft.Manufacturing.Routing;
using Microsoft.Projects.Project.Job;
using Microsoft.Projects.Project.Journal;
using Microsoft.Projects.Project.Ledger;
using Microsoft.Projects.Project.Planning;
using Microsoft.Projects.Project.WIP;
using Microsoft.Projects.Resources.Journal;
using Microsoft.Projects.Resources.Ledger;
using Microsoft.Projects.Resources.Resource;
using Microsoft.Projects.TimeSheet;
using Microsoft.Purchases.Archive;
using Microsoft.Purchases.Comment;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Payables;
using Microsoft.Sales.Archive;
using Microsoft.Sales.Comment;
using Microsoft.Sales.Document;
using Microsoft.Sales.FinanceCharge;
using Microsoft.Sales.History;
using Microsoft.Sales.Receivables;
using Microsoft.Sales.Reminder;
using Microsoft.Service.Comment;
using Microsoft.Service.Contract;
using Microsoft.Service.Document;
using Microsoft.Service.History;
using Microsoft.Service.Item;
using Microsoft.Service.Ledger;
using Microsoft.Service.Loaner;
using Microsoft.Service.Pricing;
using Microsoft.Utilities;
using Microsoft.Warehouse.Activity;
using Microsoft.Warehouse.Activity.History;
using Microsoft.Warehouse.Document;
using Microsoft.Warehouse.History;
using Microsoft.Warehouse.InternalDocument;
using Microsoft.Warehouse.InventoryDocument;
using Microsoft.Warehouse.Journal;
using Microsoft.Warehouse.Ledger;
using Microsoft.Warehouse.Request;
using Microsoft.Warehouse.Tracking;
using Microsoft.Warehouse.Worksheet;
using System.Automation;
using System.Diagnostics;
using System.Email;
using System.Reflection;
using System.Security.AccessControl;
using System.Threading;
using System.Utilities;

/// <summary>
/// Provides the record deletion workflow: table suggestion, relation checking, backup and deletion.
/// </summary>
codeunit 50000 "Record Deletion Mgt."
{
    Permissions = tabledata "Bank Account Ledger Entry" = imd,
                  tabledata "Change Log Entry" = imd,
                  tabledata "Cust. Ledger Entry" = imd,
                  tabledata "Detailed Cust. Ledg. Entry" = imd,
                  tabledata "Detailed Vendor Ledg. Entry" = imd,
                  tabledata "Dimension Set Entry" = imd,
                  tabledata "FA Ledger Entry" = imd,
                  tabledata "G/L Entry" = imd,
                  tabledata "G/L Entry - VAT Entry Link" = imd,
                  tabledata "G/L Register" = imd,
                  tabledata "Gen. Journal Line" = imd,
                  tabledata "Issued Reminder Line" = imd,
                  tabledata "Item Application Entry" = imd,
                  tabledata "Item Ledger Entry" = imd,
                  tabledata "Job Ledger Entry" = imd,
                  tabledata "Phys. Inventory Ledger Entry" = imd,
                  tabledata "Purch. Cr. Memo Hdr." = imd,
                  tabledata "Purch. Cr. Memo Line" = imd,
                  tabledata "Purch. Inv. Header" = imd,
                  tabledata "Purch. Inv. Line" = imd,
                  tabledata "Purch. Rcpt. Header" = imd,
                  tabledata "Purch. Rcpt. Line" = imd,
                  tabledata "Purchase Header" = imd,
                  tabledata "Purchase Line" = imd,
                  tabledata "Record Deletion" = rimd,
                  tabledata "Record Deletion Rel. Error" = rimd,
                  tabledata "Reminder/Fin. Charge Entry" = imd,
                  tabledata "Return Receipt Line" = imd,
                  tabledata "Return Shipment Header" = imd,
                  tabledata "Return Shipment Line" = imd,
                  tabledata "Sales Cr.Memo Header" = imd,
                  tabledata "Sales Cr.Memo Line" = imd,
                  tabledata "Sales Header" = imd,
                  tabledata "Sales Invoice Header" = imd,
                  tabledata "Sales Invoice Line" = imd,
                  tabledata "Sales Line" = imd,
                  tabledata "Sales Shipment Header" = imd,
                  tabledata "Sales Shipment Line" = imd,
                  tabledata "Value Entry" = imd,
                  tabledata "VAT Entry" = imd,
                  tabledata "Vendor Ledger Entry" = imd;
    internal procedure InsertUpdateTables()
    var
        AllObjWithCaption: Record AllObjWithCaption;
        RecordDeletion: Record "Record Deletion";
    begin
        AllObjWithCaption.SetRange("Object Type", AllObjWithCaption."Object Type"::Table);
        // Do not include system tables
        AllObjWithCaption.SetFilter("Object ID", '< %1', 2000000001);
        AllObjWithCaption.SetLoadFields("Object ID");
        if AllObjWithCaption.FindSet() then
            repeat
                RecordDeletion.Init();
                RecordDeletion.Validate("Table ID", AllObjWithCaption."Object ID");
                RecordDeletion.Validate(Company, CopyStr(CompanyName(), 1, MaxStrLen(RecordDeletion.Company)));
                if not RecordDeletion.Insert(true) then
                    continue;
            until AllObjWithCaption.Next() = 0;
    end;

    internal procedure SuggestRecordsToDelete()
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

    internal procedure ClearRecordsToDelete()
    var
        RecordDeletion: Record "Record Deletion";
    begin
        RecordDeletion.ModifyAll("Delete Records", false, true);
    end;

    internal procedure DeleteRecords(RunTrigger: Boolean)
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

        RecordDeletion.SetLoadFields("Table ID", "Delete Records");
        if RecordDeletion.FindSet() then
            repeat
                if not RecordDeletion."Delete Records" then
                    continue;

                UpdateDialog.Update(1, Format(RecordDeletion."Table ID"));
                TableBackupMgt.CreateBackup(
                    RecordDeletion."Table ID",
                    BackupType::"JSON Export",
                    BackupOperationType::"Before Deletion",
                    CopyStr(StrSubstNo(BackupDescriptionTxt, RunTrigger), 1, 250));
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

        RecordDeletion.SetLoadFields("Table ID", "Delete Records");
        if RecordDeletion.FindSet() then
            repeat
                if not RecordDeletion."Delete Records" then
                    continue;

                UpdateDialog.Update(1, Format(RecordDeletion."Table ID"));
                RecordRef.Open(RecordDeletion."Table ID");
                RecordRef.DeleteAll(RunTrigger);
                RecordRef.Close();
                RecordDeletionRelError.SetRange("Table ID", RecordDeletion."Table ID");
                RecordDeletionRelError.DeleteAll(true);
            until RecordDeletion.Next() = 0;

        UpdateDialog.Close();
    end;

    internal procedure CheckTableRelations()
    var
        RecordDeletion: Record "Record Deletion";
        RecordDeletionRelError: Record "Record Deletion Rel. Error";
        ConfirmManagement: Codeunit "Confirm Management";
        UpdateDialog: Dialog;
        TotalCount: Integer;
        ProcessedCount: Integer;
        CheckingRelationsTxt: Label 'Checking Relations Between Records!\Table: #1#######\Name: #2##################\Progress: #3##########', Comment = '%1 = Table ID, %2 = Table Name, %3 = Progress percentage';
        CheckRelationsQst: Label 'Check Table Relations?';
    begin
        if not ConfirmManagement.GetResponseOrDefault(CheckRelationsQst, false) then
            exit;

        UpdateDialog.Open(CheckingRelationsTxt);
        RecordDeletionRelError.DeleteAll(false);

        RecordDeletion.SetLoadFields("Table ID");
        RecordDeletion.SetAutoCalcFields("Table Name");
        TotalCount := RecordDeletion.Count();
        if RecordDeletion.FindSet() then
            repeat
                ProcessedCount += 1;
                UpdateDialog.Update(1, Format(RecordDeletion."Table ID"));
                UpdateDialog.Update(2, RecordDeletion."Table Name");
                UpdateDialog.Update(3, Format(ProcessedCount * 100 div TotalCount) + '%');
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
        // Skip system audit fields: they reference a reserved system user with no matching User record
        if Field."No." in [2000000002, 2000000004] then // SystemCreatedBy, SystemModifiedBy
            exit;

        FieldRef := RecordRef.Field(Field."No.");
        if IsBlankRelationValue(FieldRef) then
            exit;

        ValidateFieldRelation(RecordRef, FieldRef, Field);
    end;

    local procedure IsBlankRelationValue(var FieldRef: FieldRef): Boolean
    var
        GuidValue: Guid;
    begin
        // An empty GUID (e.g. an unused Dataverse/tax integration field) never resolves to a real record
        if FieldRef.Type() = FieldType::GUID then begin
            GuidValue := FieldRef.Value();
            exit(IsNullGuid(GuidValue));
        end;

        exit((Format(FieldRef.Value()) = '') or (Format(FieldRef.Value()) = '0'));
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

        // Keep this nested: FieldRef2 is unassigned when FieldRefInitialized is false, and AL does not
        // short-circuit "and" here, so combining both conditions would call FieldRef2.Type() on an unassigned FieldRef.
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
        KeyRec.SetLoadFields(Key);
        if not KeyRec.Get(TableNo, 1) then  // PK
            Error(CouldNotGetKeyErr, TableNo);

        Field2.SetRange(TableNo, TableNo);
        Field2.SetFilter(FieldName, CopyStr(KeyRec.Key, 1, 30));
        Field2.SetLoadFields("No.");
        if not Field2.FindFirst() then // No Match if Dual PK
            exit(false);

        FieldRef2 := RecordRef2.Field(Field2."No.");
        exit(true);
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
        RecordDeletionRelError.Validate("Table ID", RecordRef.Number());
        RecordDeletionRelError.Validate("Entry No.", EntryNo);
        RecordDeletionRelError.Validate("Field No.", FieldRef.Number());
        RecordDeletionRelError.Validate(Error, CopyStr(StrSubstNo(NotExistsTxt, Format(RecordRef.GetPosition()), Format(FieldRef2.Name()), Format(FieldRef.Value()), Format(RecordRef2.Name())), 1, 250));
        RecordDeletionRelError.Insert(false);
    end;

    internal procedure ViewRecords(RecordDeletion: Record "Record Deletion")
    begin
        Hyperlink(GetUrl(ClientType::Current, CompanyName(), ObjectType::Table, RecordDeletion."Table ID"));
    end;

    internal procedure SetSuggestedTable(TableID: Integer)
    var
        RecordDeletion: Record "Record Deletion";
    begin
        if not RecordDeletion.Get(TableID) then
            exit;
        RecordDeletion.Validate("Delete Records", true);
        RecordDeletion.Modify(true);
    end;

    internal procedure CalcRecordsInTable(TableNoToCheck: Integer): Integer
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

    internal procedure SuggestUnlicensedPartnerOrCustomRecordsToDelete()
    var
        RecordDeletion: Record "Record Deletion";
        RecsSuggestedCount: Integer;
        RecordsSuggestedMsg: Label '%1 unlicensed partner or custom records were suggested.', Comment = '%1 number of unlicensed records';
    begin
        RecordDeletion.SetFilter("Table ID", '> %1', 49999);
        RecordDeletion.SetLoadFields("Table ID");
        if RecordDeletion.FindSet(false) then
            repeat
                if IsRecordStandardTable(RecordDeletion."Table ID") then
                    continue;
                if IsRecordInLicense(RecordDeletion."Table ID") then
                    continue;

                SetSuggestedTable(RecordDeletion."Table ID");
                RecsSuggestedCount += 1;
            until RecordDeletion.Next() = 0;

        Message(RecordsSuggestedMsg, RecsSuggestedCount);
    end;

    local procedure IsRecordInLicense(TableID: Integer): Boolean
    var
        LicensePermission: Record "License Permission";
    begin
        LicensePermission.SetLoadFields("Read Permission", "Insert Permission", "Modify Permission", "Delete Permission", "Execute Permission");
        // LicensePermission.Get(LicensePermission."Object Type"::Table, TableID);
        if not LicensePermission.Get(LicensePermission."Object Type"::TableData, TableID) then
            exit(false);

        if (LicensePermission."Read Permission" = LicensePermission."Read Permission"::" ") and
            (LicensePermission."Insert Permission" = LicensePermission."Insert Permission"::" ") and
            (LicensePermission."Modify Permission" = LicensePermission."Modify Permission"::" ") and
            (LicensePermission."Delete Permission" = LicensePermission."Delete Permission"::" ") and
            (LicensePermission."Execute Permission" = LicensePermission."Execute Permission"::" ")
        then
            exit(false);
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