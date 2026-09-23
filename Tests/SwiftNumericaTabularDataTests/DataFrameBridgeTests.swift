import Testing
import SwiftNumerica
import SwiftNumericaTabularData

#if SWIFTNUMERICA_TABULARDATA && canImport(TabularData)
import TabularData

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

@Test func dataFrameBridgeReturnsNilForMissingOrMistypedColumns() throws {
    let table = try #require(
        DataTable(
            columns: ["group", "value"],
            rows: [
                ["a", "1"],
                ["b", "2"],
            ]
        ))
    let frame = table.dataFrame()

    #expect(DataTable(dataFrame: frame, stringColumns: ["missing"]) == nil)
    #expect(DataTable(dataFrame: frame, numericColumns: ["missing"]) == nil)
    #expect(DataTable(dataFrame: frame, numericColumns: ["value"]) == nil)

    let numericFrame = try #require(table.numericDataFrame(columns: ["value"]))
    #expect(DataTable(dataFrame: numericFrame, stringColumns: ["value"]) == nil)
}
#endif
