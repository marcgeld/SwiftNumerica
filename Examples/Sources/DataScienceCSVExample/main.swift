import Foundation
import SwiftNumerica

// Comma-separated values:
// https://en.wikipedia.org/wiki/Comma-separated_values
//
// This example imports CSV data, extracts columns, converts numeric data to a
// tensor, and exports the table back to CSV.

let csv = """
group,value,note
a,1,first
a,3,second
b,10,third
"""

let table = DataTable.importCSV(csv)!
let outputURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("SwiftNumericaDataScienceCSVExample.csv")
try table.exportCSV(to: outputURL)
let reloaded = try DataTable.importCSV(from: outputURL)!
let noteColumn = table.column("note")
let numericValueColumn = table.numericColumn("value")
let tensor = table.tensor(columns: ["value"])
let csvOutput = table.csvString()

print("Columns (expected [group, value, note]): \(table.columns)")
print("Rows (expected three CSV data rows): \(table.rows)")
print("Row count (expected 3): \(table.rowCount)")
print("Column count (expected 3): \(table.columnCount)")
print("Note column (expected [first, second, third]): \(noteColumn ?? [])")
print("Numeric value column (expected [1, 3, 10]): \(numericValueColumn?.values ?? [])")
print("Tensor values (expected [1, 3, 10]): \(tensor?.values ?? [])")
print("CSV output (expected original rows with header): \(csvOutput)")
print("Reloaded rows (expected same rows after export/import): \(reloaded.rows)")
