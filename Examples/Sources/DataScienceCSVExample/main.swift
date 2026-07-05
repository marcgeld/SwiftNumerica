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

print("Columns:", table.columns)
print("Rows:", table.rows)
print("Row count:", table.rowCount)
print("Column count:", table.columnCount)
print("Note column:", table.column("note") ?? [])
print("Numeric value column:", table.numericColumn("value")?.values ?? [])
print("Tensor values:", table.tensor(columns: ["value"])?.values ?? [])
print("CSV output:", table.csvString())
print("Reloaded rows:", reloaded.rows)
