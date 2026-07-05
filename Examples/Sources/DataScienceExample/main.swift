import Foundation
import SwiftNumerica

// CSV and tabular summaries:
// https://en.wikipedia.org/wiki/Comma-separated_values
//
// This example imports CSV text into DataTable, extracts numeric tensors,
// summarizes columns, groups rows, creates tables from tensors/numeric columns,
// and writes a CSV file.

let csv = """
group,value,note
a,1,first
a,3,second
b,10,third
"""

let table = DataTable.importCSV(csv)!
let valueColumn = table.numericColumn("value")!
let tensor = table.tensor(columns: ["value"])!
let summary = table.summary(for: "value")!
let summaries = table.summaries()
let grouped = table.grouped(by: "group")!
let tensorTable = DataTable(tensor: Tensor.matrix([[1, 2], [3, 4]])!, columnNames: ["x", "y"])!
let numericTable = DataTable(numericColumns: ["x": [1, 2], "y": [3, 4]])!
let manualSummary = ColumnSummary(
    column: "manual",
    count: 2,
    min: 1,
    max: 2,
    mean: 1.5,
    median: 1.5,
    sampleVariance: 0.5,
    sampleStandardDeviation: 0.5.squareRoot()
)
let manualGroup = GroupedDataTable(groupColumn: "group", groups: ["all": table])
let outputURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("SwiftNumericaDataScienceExample.csv")
try table.exportCSV(to: outputURL)
let reloaded = try DataTable.importCSV(from: outputURL)!

print("Columns:", table.columns)
print("Rows:", table.rows)
print("Note column:", table.column("note") ?? [])
print("Numeric column:", valueColumn.values)
print("Tensor values:", tensor.values)
print("Summary mean:", summary.mean ?? .nan)
print("All numeric summaries:", summaries.keys.sorted())
print("Group keys:", grouped.groupKeys)
print("Grouped summaries:", grouped.summaries().keys.sorted())
print("Tensor table:", tensorTable.csvString())
print("Numeric table:", numericTable.csvString())
print("Manual summary:", manualSummary)
print("Manual group:", manualGroup.groupKeys)
print("Reloaded CSV rows:", reloaded.rows)

