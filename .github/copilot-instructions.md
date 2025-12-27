# Record Deletion Tool - Copilot Instructions

## Project Overview
Business Central AL extension (v27.0, Cloud target) that enables bulk deletion of records across multiple tables with relationship validation and backup capabilities. Built on Olof Simren's original tool, enhanced with comprehensive backup/restore system.

## Architecture & Data Flow

### Core Components
1. **Record Deletion System** (`RecordDeletion.Table.al`, `RecordDeletionMgt.Codeunit.al`)
   - Manages table selection and deletion workflow
   - Uses RecordRef/FieldRef for dynamic table operations
   - Validates table relationships before deletion to prevent orphaned records

2. **Backup System** (`TableBackup.Table.al`, `TableBackupMgt.Codeunit.al`)
   - JSON-based serialization of table data stored in BLOB fields
   - Three backup types: JSON Export, Snapshot, Full Backup (all use JSON internally)
   - Operations tracked via `Backup Operation Type` enum (Manual, Before Deletion, etc.)
   - **Critical workflow**: Always create backup before deletion (integrated in `DeleteRecords()`)

3. **Relationship Validation** (`RecordDeletionRelError.Table.al`)
   - Scans Field table metadata for RelationTableNo/RelationFieldNo
   - Stores validation errors for user review before deletion
   - Skips problematic CRM/external table types (TableType::Normal only)

### Key Data Flow Pattern
```
User Action → InsertUpdateTables() → Populates Record Deletion table
           → SuggestRecordsToDelete() → Sets "Delete Records" flags (11 helper procedures by BC area)
           → CheckTableRelations() → Validates foreign keys → Logs errors
           → DeleteRecords(RunTrigger) → AskForBackup() → CreateBackupsForDeletion() → PerformDeletion()
```

## AL-Specific Patterns

### RecordRef/FieldRef Dynamic Operations
- Use `RecordRef.Open(TableID)` for dynamic table access
- Use `RecordRef.ReadIsolation(IsolationLevel::UpdLock)` instead of deprecated `LockTable()`
- Always check `Get()` return values: `if not KeyRec.Get(...) then Error(...)`
- Set RunTrigger explicitly on all Insert/Modify/Delete operations: `.Insert(true)`, `.DeleteAll(false)`

### Code Quality Standards (Business Linter Corp)
- **Complexity thresholds**: Cyclomatic < 8, Cognitive < 15, Maintainability > 20
- **Refactoring pattern**: Split large procedures into focused helpers (see `SuggestRecordsToDelete()` → 11 area-specific procedures)
- **Variable ordering**: Record, Report, Codeunit, XmlPort, Page, Query, then RecordRef, FieldRef, Dialog, then primitives
- **Built-in methods**: Always use parentheses: `CompanyName()`, `IsEmpty()`, `Value()`, `Type()`, `Length()`, `Number()`, `Name()`
- **Confirmations**: Use `ConfirmManagement.GetResponseOrDefault()` instead of direct `Confirm()`
- **ToolTips**: Define on table fields only, not on page fields (LC0064)

### Critical LC Rules to Avoid
**FlowFields & Properties**
- LC0001: FlowFields must be Editable = false
- LC0019: Don't duplicate DataClassification on fields if set on table
- LC0042: Only use AutoCalcFields for FlowFields or Blob fields
- LC0064: All table fields must have ToolTip property
- LC0066: Don't duplicate ToolTip on both page and table fields
- LC0074: Set FlowFilter fields using filtering methods, not direct assignment

**Code Syntax & Best Practices**
- LC0004: Set DrillDownPageId and LookupPageId on tables used in list pages
- LC0005: Variable/method casing must match definition
- LC0010: Keep cyclomatic complexity < 8, maintainability > 20
- LC0015: All objects must be covered by permission sets
- LC0021: Use ConfirmManagement.GetResponseOrDefault() instead of Confirm()
- LC0023: Always provide DropDown and Brick fieldgroups on tables
- LC0024: Procedure declarations must not end with semicolon
- LC0031: Use ReadIsolation instead of deprecated LockTable()
- LC0035: Explicitly set AllowInCustomizations for fields omitted on pages
- LC0040: Explicitly set RunTrigger parameter on Insert/Modify/Delete
- LC0051: Don't assign text to target with smaller size (use CopyStr)
- LC0077: Always call methods with parentheses, even when no parameters
- LC0084: Check Get() return values: `if not Rec.Get(...) then Error(...)`
- LC0090: Keep Cognitive Complexity below threshold (typically 15)

**Data Operations**
- LC0008: Don't use filter operators in SetRange (use SetFilter instead)
- LC0032: Clear(All) doesn't affect single instance codeunit globals
- LC0044: Tables coupled with TransferFields must have matching fields
- LC0050: SetFilter with unsupported operator in filter expression
- LC0068: Missing permission to access tabledata (add to Permissions property)
- LC0075: Correct number/type of arguments in .Get() method
- LC0078: Temporary records should not trigger table triggers
- LC0081: Use Rec.IsEmpty() instead of Rec.Count() = 0

**Labels & Text**
- LC0016: All objects/fields need Caption property
- LC0026: ToolTip must end with a dot
- LC0036: ToolTip should start with "Specifies"
- LC0037: Don't use line breaks in ToolTip
- LC0038: ToolTip should not exceed 200 characters
- LC0041: Empty Captions should be Locked
- LC0046: Labels with suffix Tok must be locked
- LC0047: Locked labels must have suffix Tok

**Modern AL Features**
- LC0043: Use SecretText for credentials and sensitive values
- LC0083: Use new Date/Time/DateTime methods for extracting parts
- LC0086: Use PageStyle datatype instead of string literals
- LC0087: Use IsNullGuid() to check for empty GUID values
- LC0088: Use enum instead of Option types when applicable

### FlowFields & Metadata
- FlowFields (CalcFormula) always require `CalcFields()` before accessing
- Table metadata queries: `Field.SetRange(Class, Field.Class::Normal)` and `Field.SetRange(ObsoleteState, Field.ObsoleteState::No)` to filter active fields
- AllObjWithCaption used for dynamic table name lookups

### Permission Model
- Permission sets must cover ALL extension objects (LC0015 enforcement)
- Pattern: `table "X" = X` (execute), `tabledata "X" = RIMD` (Read Insert Modify Delete)
- Codeunit Permissions property lists required tabledata access

## Development Workflows

### Build & Deploy
- AL extension auto-compiles on save (no manual build command needed)
- Deploy via F5 with launch.json configurations (OnPrem environments defined)
- Object ID range: 50000-50099 (app.json)

### Testing Pattern
- Manual testing via "Record Deletion" page (Tell Me: search "Record Deletion")
- Workflow: Insert/Update Tables → Suggest Records → Check Relations → Delete (with backup prompt)
- Restore from "Table Backup List" page

### Debugging RecordRef Operations
- Enable SQL Information Debugger in launch.json (`enableSqlInformationDebugger: true`)
- Use breakpoints in RecordRef loops to inspect `FieldRef.Value()` and `RecordRef.GetPosition()`
- Check Table Metadata TableType before operations to avoid CRM connection errors

## Critical Conventions

### JSON Serialization (TableBackupMgt)
- Only Normal class fields, skip BLOB fields and Obsolete fields
- Format() used for all field values (handles type conversion)
- Restore uses type-specific Evaluate() with fallback to text assignment
- Progress dialogs update every 100 records (mod 100 check)

### Table Suggestion Organization
11 functional area procedures in RecordDeletionMgt:
- SetSuggestedFinanceTables() - G/L, VAT, FA, Bank ledgers
- SetSuggestedSalesTables() - Sales documents, shipments, invoices
- SetSuggestedPurchaseTables() - Purchase documents
- SetSuggestedInventoryTables() - Item ledger, tracking, journals
- SetSuggestedServiceTables() - Service orders, contracts
- SetSuggestedWarehouseTables() - Warehouse activities, receipts
- SetSuggestedJobTables() - Job ledgers, time sheets
- SetSuggestedManufacturingTables() - Production orders, capacity
- SetSuggestedCRMTables() - Opportunities, campaigns
- SetSuggestedOtherTables() - IC, approvals, assemblies

### Error Handling Workarounds
- Field IDs 124 filtered out for tables 5330/7200 to avoid "Table connection for table type CRM must be registered" error
- TableType::Normal filter prevents errors on external/virtual tables

## Files of Interest
- `RecordDeletionMgt.Codeunit.al`: 740+ lines, main business logic, heavily refactored for maintainability
- `TableBackupMgt.Codeunit.al`: Complete JSON backup/restore implementation with type handling
- `RecordDeletion.PermissionSet.al`: Security model reference for all extension objects
- `app.json`: Platform 27.0, NoImplicitWith feature, Cloud target
