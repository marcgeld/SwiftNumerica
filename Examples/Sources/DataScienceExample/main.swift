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
let noteColumn = table.column("note")
let groupedSummaryKeys = grouped.summaries().keys.sorted()

print("Columns (expected [group, value, note]): \(table.columns)")
print("Rows (expected three CSV data rows): \(table.rows)")
print("Note column (expected [first, second, third]): \(noteColumn ?? [])")
print("Numeric column (expected [1, 3, 10]): \(valueColumn.values)")
print("Tensor values (expected [1, 3, 10]): \(tensor.values)")
print("Summary mean (expected (1 + 3 + 10) / 3 = 4.666666666666667): \(summary.mean ?? .nan)")
print("All numeric summaries (expected [value]): \(summaries.keys.sorted())")
print("Group keys (expected [a, b]): \(grouped.groupKeys)")
print("Grouped summaries (expected keys [a, b]): \(groupedSummaryKeys)")
print("Tensor table CSV (expected x/y columns): \(tensorTable.csvString())")
print("Numeric table CSV (expected sorted x/y columns): \(numericTable.csvString())")
print("Manual summary (expected count 2, mean 1.5): \(manualSummary)")
print("Manual group (expected [all]): \(manualGroup.groupKeys)")
print("Reloaded CSV rows (expected same rows after export/import): \(reloaded.rows)")
