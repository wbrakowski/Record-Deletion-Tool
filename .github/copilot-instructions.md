# Record Deletion Tool - Copilot Instructions

## Project Overview
Business Central AL extension (v29.0, Cloud target) that enables bulk deletion of records across multiple tables with relationship validation and backup capabilities. Built on Olof Simren's original tool, enhanced with comprehensive backup/restore system.

## Repo Layout
- **`app/`**: main app (`app/app.json`, `app/src/...`), id range 50000-50099, namespace `RecordDeletionTool`.
- **`test/`**: separate AL test app (`test/app.json`, `test/src/...`), id range 60000-60049, namespace `RecordDeletionTool.Test`, depends on `app` plus Microsoft's `Library Assert`/`Any` libraries.
- Both are true sibling folders under the repo root (neither is nested inside the other's directory tree), which is required so the AL compiler never merges their files/id ranges into a single project — see "Automated Testing" below for the history of why this matters.
- Open both together via **`Record-Deletion-Tool.code-workspace`** (multi-root workspace).

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

### Namespaces (BC29+)
- All app files declare `namespace RecordDeletionTool;` (test app: `namespace RecordDeletionTool.Test;`) as the first line, per the AA0247 analyzer rule.
- Once a file declares a `namespace`, unqualified references outside that namespace tree need an explicit `using` statement (e.g. `using System.Reflection;`, `using System.Utilities;`, `using System.TestLibraries.Utilities;`, or `using RecordDeletionTool;` from the test app) — otherwise compilation fails with "X is missing"/"name does not exist". `using` statements must be alphabetically sorted (AA0477).

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
- Object ID range: 50000-50099 (`app/app.json`)

### Manual Testing Pattern
- Manual testing via "Record Deletion" page (Tell Me: search "Record Deletion")
- Workflow: Insert/Update Tables → Suggest Records → Check Relations → Delete (with backup prompt)
- Restore from "Table Backup List" page

### Automated Testing (AL Test Toolkit)
- Tests live in a **separate AL app** under `test/` (own `app.json`, `id`, `idRanges 60000-60049`), depending on the main app plus Microsoft's `Library Assert` and `Any` test libraries.
- The main app used to live directly at the repo root with `test/` nested inside it, which made the AL compiler's default build (e.g. `Ctrl+Shift+B`) recursively merge `test/`'s files into the main app's project — its object IDs then collided with the main app's `50000-50099` range and `Library Assert` couldn't resolve. Moving the main app into its own `app/` folder (sibling to `test/`, not a parent of it) fixes this permanently, regardless of which folder/workspace is open.
- Open both projects together via the **`Record-Deletion-Tool.code-workspace`** multi-root workspace file for convenience (IntelliSense across both, easy access to both Test Explorers) — this is no longer required to avoid the id-range merge bug, but is still the recommended way to work in this repo.
- After opening the workspace file, run `AL: Download Symbols` for both projects (or use `al_downloadsymbols`) before building/running tests. Build with `al_build scope='all'`, then publish each project separately (`al_publish`, focusing `app/app.json` then `test/app.json` first).
- Test codeunits use `Subtype = Test;`, `[Test]` procedures, and `Codeunit "Library Assert"` (`Assert.AreEqual`, `Assert.IsTrue`, `Assert.RecordCount`, `Assert.AreNotEqual`, ...) for assertions. `TestPermissions = Disabled` is used to avoid unrelated permission-set setup for these focused unit tests.
- Test files declare `namespace RecordDeletionTool.Test;` and need `using RecordDeletionTool;` (for main-app types like `Table Backup Mgt.`, `Record Deletion Mgt.`, `Table Backup`, `Record Deletion`) and `using System.TestLibraries.Utilities;` (for `Library Assert`).

**`internal` procedures exposed purely for testability** (all follow the same pattern: the public entry point is gated by `ConfirmManagement.GetResponseOrDefault(..., false)`, which always resolves to its default/no-op because `GuiAllowed()` is `false` during test execution — so tests call the underlying `internal` procedure directly, bypassing the interactive confirm dialog; each has an `internalsVisibleTo` entry in `app/app.json` pointing at the test app's id):
- `TableBackupMgt.RestoreFromJSON` (was `local`) — exercised by `RestoreBackup()` normally.
- `RecordDeletionMgt.CheckTableRelationsForTable` (was `local`) — exercised by `CheckTableRelations()` normally.
- `RecordDeletionMgt.PerformDeletion` (was `local`) — exercised by `DeleteRecords()` normally.
- `RecordDeletionMgt.CreateBackupsForDeletion` (was `local`) — exercised by `DeleteRecords()` normally.

**Safety guard for destructive tests**: `PerformDeletion` and `CreateBackupsForDeletion` iterate over **every** `"Record Deletion"` row with `Delete Records = true`, not just the test's own row. A test calling them directly could delete real data if the sandbox already has other tables flagged from earlier interactive use of the tool. Tests for these two procedures therefore start with:
  ```al
  RecordDeletion.SetRange("Delete Records", true);
  Assert.IsTrue(RecordDeletion.IsEmpty(), 'Aborting: another table is already flagged for deletion in this environment.');
  ```
  before setting up their own test data. Apply this same guard to any new test that calls one of these two procedures.

- `test/src/table/TestBuffer.Table.al` (id 60000) is the shared dummy table for both test codeunits. It intentionally carries extra fields beyond simple round-trip data so relation-check tests have something to exercise: `"Related No."` (Code, self `TableRelation` to `"No."`) and `"Related System ID"` (Guid, self `TableRelation` to `SystemId`) — used to verify `CheckTableRelationsForTable` detects both Code-based and GUID-based dangling references while ignoring valid/blank ones.
- Current test codeunits: `TableBackupMgtTest` (id 60000) covers all 3 backup types (JSON Export, Snapshot, Full Backup), filtered backups, full round-trip restore across every field type (Integer/Decimal/Boolean/Date/Time/DateTime/Guid/Text), `ViewBackupData`/`ExportBackupToFile` error guards (via `asserterror`), and `DeleteSnapshotTable`. `RecordDeletionMgtTest` (id 60001) covers `SetSuggestedTable`, `ClearRecordsToDelete`, `CalcRecordsInTable`, `CheckTableRelationsForTable` (Code and GUID relation errors), `PerformDeletion`, and `CreateBackupsForDeletion`.
- **Deliberately NOT covered**, with reasons — don't attempt to test these without discussing the tradeoff first:
  - `InsertUpdateTables()`, `SuggestRecordsToDelete()`, all 11 `SetSuggestedXTables()` helpers — scan/flag every table in the environment or a large hardcoded list; too slow/environment-dependent for a unit test.
  - `SuggestUnlicensedPartnerOrCustomRecordsToDelete`, `IsRecordInLicense`, `IsRecordStandardTable` — depend on the environment's license/permission data, not deterministic.
  - `DeleteRecords()`, `RestoreBackup()` (the public, confirm-gated entry points) — thin orchestration already covered by testing their internal building blocks directly.
  - `ViewRecords` — just calls `Hyperlink()`, nothing to assert.
  - The "dual primary key" fallback branch in `GetPrimaryKeyFieldRef` and the `SystemCreatedBy`/`SystemModifiedBy` skip branch in `CheckFieldRelation` — not reliably forceable/verifiable without live test execution (see session notes if picking this up).
  - The real `DownloadFromStream` success path in `ExportBackupToFile` — only the `Error(NoBackupDataErr)` guard clause is tested; behavior of an actual client download when `GuiAllowed()` is `false` wasn't empirically verified.
- **AL test pitfall**: inserting a record and then immediately calling code that does `CalcFields` on a Blob field (e.g. `ViewBackupData`, `ExportBackupToFile`) can fail with "The X does not exist" even though the row was just inserted — `Get()`/`Find()` right after `Insert()` do NOT fix this. Call `Commit();` right after `Insert()` before invoking the code under test. Whenever a test calls `Commit()`, it MUST also carry `[TransactionModel(TransactionModel::AutoCommit)]` on the `[Test]` procedure (default test transaction model is `AutoRollback`, which doesn't match a test that commits) — and still manually clean up the row afterwards, since `Commit()` breaks the automatic rollback isolation for that data.
- **AL test pitfall**: a bare `asserterror SomeCall();` only proves *some* error occurred, not the *expected* one — a regression that throws a different error (e.g. a permission error instead of the intended validation error) would still pass. Always follow `asserterror` with `Assert.ExpectedError('<exact error text>');` (or `ExpectedErrorCode`) to pin down which error was expected.
- Pattern for new tests: create isolated test data (prefer `Test Buffer` over real business tables), exercise the public/internal procedure, assert on the result, clean up inserted records (and any `Record Deletion`/`Record Deletion Rel. Error`/`Table Backup` rows created) at the end of the test.
- Run tests from VS Code using the AL Test Tool (Test Explorer) or `Ctrl+Shift+P` → `AL: Run Test`/`AL: Run All Tests` after publishing the test app to the sandbox in `test/.vscode/launch.json`. `AL: Run All Tests with Coverage` additionally reports which lines of the main app were exercised, at the cost of a slower run.

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
- `app/src/codeunit/RecordDeletionMgt.Codeunit.al`: 740+ lines, main business logic, heavily refactored for maintainability
- `app/src/codeunit/TableBackupMgt.Codeunit.al`: Complete JSON backup/restore implementation with type handling
- `app/src/permissionset/RecordDeletion.PermissionSet.al`: Security model reference for all extension objects
- `app/app.json`: Platform 29.0, NoImplicitWith feature, Cloud target, `internalsVisibleTo` the test app
- `test/src/codeunit/TableBackupMgtTest.Codeunit.al` (id 60000): backup/restore tests (all backup types, all field types, filtered backups)
- `test/src/codeunit/RecordDeletionMgtTest.Codeunit.al` (id 60001): deletion/relation-check tests
- `test/src/table/TestBuffer.Table.al` (id 60000): dummy table used by both test codeunits, with self-relation fields for relation-check tests
- `test/`: Separate AL test app (open via `Record-Deletion-Tool.code-workspace`), object ID range 60000-60049
