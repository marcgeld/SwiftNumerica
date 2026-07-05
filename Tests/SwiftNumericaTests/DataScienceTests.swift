import Foundation
import Testing

#if canImport(TabularData)
import TabularData
#endif

@testable import SwiftNumerica

@Test func dataTableImportsAndExportsCSV() throws {
    let csv = "group,value,note\n"
        + "a,1,\"hello, world\"\n"
        + "a,3,\"quote \"\"inside\"\"\"\n"
        + "b,5,plain"
    let table = try #require(DataTable.importCSV(csv))

    #expect(table.columns == ["group", "value", "note"])
    #expect(table.rowCount == 3)
    #expect(table.column("note") == ["hello, world", "quote \"inside\"", "plain"])
    #expect(table.csvString().contains("\"hello, world\""))
    #expect(table.csvString().contains("\"quote \"\"inside\"\"\""))
}

@Test func dataTableProducesNumericColumnsTensorsAndSummaries() throws {
    let table = try #require(
        DataTable(
            columns: ["group", "x", "y"],
            rows: [
                ["a", "1", "2"],
                ["a", "3", "4"],
                ["b", "5", "6"],
            ]
        ))

    let x = try #require(table.numericColumn("x"))
    #expect(x.values == [1, 3, 5])

    let tensor = try #require(table.tensor(columns: ["x", "y"]))
    #expect(tensor.shape.dimensions == [3, 2])
    #expect(tensor.values == [1, 2, 3, 4, 5, 6])

    let summary = try #require(table.summary(for: "x"))
    #expect(summary.count == 3)
    #expect(summary.min?.isApproximatelyEqual(to: 1) == true)
    #expect(summary.max?.isApproximatelyEqual(to: 5) == true)
    #expect(summary.mean?.isApproximatelyEqual(to: 3) == true)
    #expect(summary.sampleVariance?.isApproximatelyEqual(to: 4) == true)

    let summaries = table.summaries()
    #expect(summaries.keys.sorted() == ["x", "y"])
}

@Test func dataTableGroupsRowsAndSummarizesGroups() throws {
    let table = try #require(
        DataTable(
            columns: ["group", "value"],
            rows: [
                ["a", "1"],
                ["a", "3"],
                ["b", "10"],
            ]
        ))
    let grouped = try #require(table.grouped(by: "group"))

    #expect(grouped.groupKeys == ["a", "b"])
    #expect(grouped.groups["a"]?.rowCount == 2)
    #expect(grouped.groups["b"]?.rowCount == 1)

    let summaries = grouped.summaries()
    #expect(summaries["a"]?["value"]?.mean?.isApproximatelyEqual(to: 2) == true)
    #expect(summaries["b"]?["value"]?.mean?.isApproximatelyEqual(to: 10) == true)
}

@Test func dataTableCanReadAndWriteCSVFiles() throws {
    let table = try #require(
        DataTable(
            columns: ["x", "y"],
            rows: [
                ["1", "2"],
                ["3", "4"],
            ]
        ))
    let url = URL(fileURLWithPath: NSTemporaryDirectory())
        .appendingPathComponent("SwiftNumericaDataScienceTests.csv")

    try table.exportCSV(to: url)
    let imported = try #require(try DataTable.importCSV(from: url))

    #expect(imported == table)
}

@Test func dataTableCanBeCreatedFromTensor() throws {
    let tensor = try #require(Tensor.matrix([[1, 2], [3, 4]]))
    let table = try #require(DataTable(tensor: tensor, columnNames: ["x", "y"]))

    #expect(table.columns == ["x", "y"])
    #expect(table.rows == [["1.0", "2.0"], ["3.0", "4.0"]])
    #expect(try #require(table.tensor()).values == [1, 2, 3, 4])
}

#if canImport(TabularData)
@Test func dataTableBridgesToAndFromTabularDataDataFrame() throws {
    let table = try #require(
        DataTable(
            columns: ["group", "value"],
            rows: [
                ["a", "1"],
                ["b", "2"],
            ]
        ))

    let frame = table.dataFrame()
    let stringRoundTrip = try #require(
        DataTable(dataFrame: frame, stringColumns: ["group", "value"])
    )
    #expect(stringRoundTrip == table)

    let numericFrame = try #require(table.numericDataFrame(columns: ["value"]))
    let numericRoundTrip = try #require(
        DataTable(dataFrame: numericFrame, numericColumns: ["value"])
    )
    #expect(numericRoundTrip.numericColumn("value")?.values == [1, 2])
}
#endif
