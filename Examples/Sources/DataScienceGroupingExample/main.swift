import SwiftNumerica

// Grouped data:
// https://en.wikipedia.org/wiki/Group_by_(SQL)
//
// This example summarizes a numeric column and groups a table by a category.

let table = DataTable(
    columns: ["group", "value"],
    rows: [["a", "1"], ["a", "3"], ["b", "10"]]
)!
let tensorTable = DataTable(tensor: Tensor.matrix([[1, 2], [3, 4]])!, columnNames: ["x", "y"])!
let numericTable = DataTable(numericColumns: ["x": [1, 2], "y": [3, 4]])!
let summary = table.summary(for: "value")!
let grouped = table.grouped(by: "group")!
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
let allSummaries = table.summaries()
let groupedSummaries = grouped.summaries()
let tensorTableCSV = tensorTable.csvString()
let numericTableCSV = numericTable.csvString()

print("Summary (expected count 3, mean 4.666666666666667): \(summary)")
print("All summaries (expected one numeric summary for value): \(allSummaries)")
print("Group keys (expected [a, b]): \(grouped.groupKeys)")
print("Grouped summaries (expected group a mean 2, group b mean 10): \(groupedSummaries)")
print("Tensor table CSV (expected x/y columns with rows [1,2] and [3,4]): \(tensorTableCSV)")
print("Numeric table CSV (expected sorted x/y columns): \(numericTableCSV)")
print("Manual summary (expected count 2, mean 1.5): \(manualSummary)")
print("Manual group (expected [all]): \(manualGroup.groupKeys)")
