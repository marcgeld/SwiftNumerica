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

print("Summary:", summary)
print("All summaries:", table.summaries())
print("Group keys:", grouped.groupKeys)
print("Grouped summaries:", grouped.summaries())
print("Tensor table:", tensorTable.csvString())
print("Numeric table:", numericTable.csvString())
print("Manual summary:", manualSummary)
print("Manual group:", manualGroup.groupKeys)
