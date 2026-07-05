import Foundation

#if canImport(TabularData)
import TabularData
#endif

public extension Numerica.DataScience {
    /// A lightweight tabular adapter around string-backed rows.
    ///
    /// Numerical algorithms should continue to operate on `Tensor<Double>`.
    /// `DataTable` exists to bridge CSV, grouped summaries, and optional
    /// TabularData interop into tensor-first workflows.
    struct DataTable: Equatable, Sendable {
        /// The table column names.
        public let columns: [String]

        /// The table rows, ordered to match `columns`.
        public let rows: [[String]]

        /// The number of rows.
        public var rowCount: Int {
            rows.count
        }

        /// The number of columns.
        public var columnCount: Int {
            columns.count
        }

        /// Creates a table from column names and rows.
        public init?(columns: [String], rows: [[String]]) {
            guard !columns.isEmpty,
                  Set(columns).count == columns.count,
                  rows.allSatisfy({ $0.count == columns.count }) else { return nil }
            self.columns = columns
            self.rows = rows
        }

        /// Creates a table from a rank-2 tensor.
        public init?(tensor: Tensor<Double>, columnNames: [String]? = nil) {
            guard tensor.rank == 2,
                  tensor.shape.dimensions.count == 2 else { return nil }

            let rowCount = tensor.shape.dimensions[0]
            let columnCount = tensor.shape.dimensions[1]
            let names = columnNames ?? (0..<columnCount).map { "column\($0 + 1)" }
            guard names.count == columnCount else { return nil }

            let rows = (0..<rowCount).map { row in
                (0..<columnCount).map { column in
                    String(tensor.values[row * columnCount + column])
                }
            }
            self.init(columns: names, rows: rows)
        }

        /// Creates a table from numerical columns.
        public init?(numericColumns: [String: [Double]]) {
            let names = numericColumns.keys.sorted()
            guard let firstName = names.first,
                  let rowCount = numericColumns[firstName]?.count,
                  names.allSatisfy({ numericColumns[$0]?.count == rowCount }) else { return nil }

            let rows = (0..<rowCount).map { row in
                names.map { name in
                    String(numericColumns[name]![row])
                }
            }
            self.init(columns: names, rows: rows)
        }

        /// Returns a string column by name.
        public func column(_ name: String) -> [String]? {
            guard let index = columns.firstIndex(of: name) else { return nil }
            return rows.map { $0[index] }
        }

        /// Returns a numeric tensor for a column when all values parse as `Double`.
        public func numericColumn(_ name: String) -> Tensor<Double>? {
            guard let values = column(name) else { return nil }
            var parsed: [Double] = []
            parsed.reserveCapacity(values.count)

            for value in values {
                guard let doubleValue = Double(value.trimmingCharacters(in: .whitespacesAndNewlines)),
                      doubleValue.isFinite else { return nil }
                parsed.append(doubleValue)
            }

            return .vector(parsed)
        }

        /// Returns a rank-2 tensor using selected numeric columns.
        public func tensor(columns selectedColumns: [String]? = nil) -> Tensor<Double>? {
            let names = selectedColumns ?? columns
            guard !names.isEmpty else { return nil }

            let numericColumns = names.map { numericColumn($0) }
            guard numericColumns.allSatisfy({ $0 != nil }) else { return nil }

            let values = (0..<rowCount).flatMap { row in
                numericColumns.map { $0!.values[row] }
            }
            return Tensor.multidimensional(values, dimensions: [rowCount, names.count])
        }

        /// Produces summary statistics for a numeric column.
        public func summary(for column: String) -> ColumnSummary? {
            guard let tensor = numericColumn(column) else { return nil }
            return ColumnSummary(column: column, tensor: tensor)
        }

        /// Produces summary statistics for every fully numeric column.
        public func summaries() -> [String: ColumnSummary] {
            columns.reduce(into: [:]) { result, column in
                if let summary = summary(for: column) {
                    result[column] = summary
                }
            }
        }

        /// Groups rows by a column.
        public func grouped(by column: String) -> GroupedDataTable? {
            guard let groupIndex = columns.firstIndex(of: column) else { return nil }

            var groupedRows: [String: [[String]]] = [:]
            for row in rows {
                groupedRows[row[groupIndex], default: []].append(row)
            }

            let groups = groupedRows.compactMapValues { DataTable(columns: columns, rows: $0) }
            return .init(groupColumn: column, groups: groups)
        }

        /// Parses CSV text into a table.
        public static func importCSV(_ csv: String, hasHeader: Bool = true) -> DataTable? {
            let records = CSV.parse(csv)
            guard !records.isEmpty else { return nil }

            let columns: [String]
            let rows: [[String]]
            if hasHeader {
                columns = records[0]
                rows = Array(records.dropFirst())
            } else {
                columns = (0..<records[0].count).map { "column\($0 + 1)" }
                rows = records
            }

            guard rows.allSatisfy({ $0.count == columns.count }) else { return nil }
            return DataTable(columns: columns, rows: rows)
        }

        /// Reads CSV data from a file URL.
        public static func importCSV(from url: URL, hasHeader: Bool = true) throws -> DataTable? {
            let csv = try String(contentsOf: url, encoding: .utf8)
            return importCSV(csv, hasHeader: hasHeader)
        }

        /// Serializes the table to CSV text.
        public func csvString(includeHeader: Bool = true) -> String {
            var records: [[String]] = includeHeader ? [columns] : []
            records.append(contentsOf: rows)
            return records.map { row in
                row.map(CSV.escape).joined(separator: ",")
            }.joined(separator: "\n")
        }

        /// Writes the table to a CSV file URL.
        public func exportCSV(to url: URL, includeHeader: Bool = true) throws {
            try csvString(includeHeader: includeHeader).write(to: url, atomically: true, encoding: .utf8)
        }
    }

    /// Summary statistics for a numeric table column.
    struct ColumnSummary: Equatable, Sendable {
        /// The source column name.
        public let column: String

        /// The number of numeric values.
        public let count: Int

        /// The minimum value.
        public let min: Double?

        /// The maximum value.
        public let max: Double?

        /// The mean value.
        public let mean: Double?

        /// The median value.
        public let median: Double?

        /// The sample variance.
        public let sampleVariance: Double?

        /// The sample standard deviation.
        public let sampleStandardDeviation: Double?

        /// Creates a column summary.
        public init(
            column: String,
            count: Int,
            min: Double?,
            max: Double?,
            mean: Double?,
            median: Double?,
            sampleVariance: Double?,
            sampleStandardDeviation: Double?
        ) {
            self.column = column
            self.count = count
            self.min = min
            self.max = max
            self.mean = mean
            self.median = median
            self.sampleVariance = sampleVariance
            self.sampleStandardDeviation = sampleStandardDeviation
        }

        fileprivate init(column: String, tensor: Tensor<Double>) {
            self.init(
                column: column,
                count: tensor.count,
                min: Numerica.Statistics.min(tensor),
                max: Numerica.Statistics.max(tensor),
                mean: Numerica.Statistics.mean(tensor),
                median: Numerica.Statistics.median(tensor),
                sampleVariance: Numerica.Statistics.sampleVariance(tensor),
                sampleStandardDeviation: Numerica.Statistics.sampleStandardDeviation(tensor)
            )
        }
    }

    /// Grouped table rows and per-group numeric summaries.
    struct GroupedDataTable: Equatable, Sendable {
        /// The column used as the group key.
        public let groupColumn: String

        /// Tables keyed by group value.
        public let groups: [String: DataTable]

        /// Creates a grouped table.
        public init(groupColumn: String, groups: [String: DataTable]) {
            self.groupColumn = groupColumn
            self.groups = groups
        }

        /// Sorted group keys for stable presentation.
        public var groupKeys: [String] {
            groups.keys.sorted()
        }

        /// Summary statistics for each group's numeric columns.
        public func summaries() -> [String: [String: ColumnSummary]] {
            groups.mapValues { $0.summaries() }
        }
    }
}

#if canImport(TabularData)
public extension Numerica.DataScience.DataTable {
    /// Creates a table from selected TabularData columns.
    ///
    /// String columns and numeric columns must be listed explicitly so the bridge
    /// stays strongly typed and avoids Python-style dynamic inspection.
    init?(dataFrame: DataFrame, stringColumns: [String] = [], numericColumns: [String] = []) {
        let columns = stringColumns + numericColumns
        guard !columns.isEmpty,
              Set(columns).count == columns.count else { return nil }

        // DataFrame's typed subscript traps on missing or mistyped columns, so
        // validate names and element types first to preserve the `init?` contract.
        let columnTypes = Dictionary(
            uniqueKeysWithValues: dataFrame.columns.map { ($0.name, $0.wrappedElementType) }
        )
        guard stringColumns.allSatisfy({ columnTypes[$0] == String.self }),
              numericColumns.allSatisfy({ columnTypes[$0] == Double.self }) else { return nil }

        let stringValues = stringColumns.map { column in
            Array(dataFrame[column, String.self]).map { $0 ?? "" }
        }
        let numericValues = numericColumns.map { column in
            Array(dataFrame[column, Double.self]).map { value in
                value.map { String($0) } ?? ""
            }
        }
        let columnValues = stringValues + numericValues
        guard let rowCount = columnValues.first?.count,
              columnValues.allSatisfy({ $0.count == rowCount }) else { return nil }

        let rows = (0..<rowCount).map { row in
            columnValues.map { $0[row] }
        }
        self.init(columns: columns, rows: rows)
    }

    /// Creates a TabularData `DataFrame` with string columns.
    func dataFrame() -> DataFrame {
        let frameColumns = columns.map { column in
            Column(name: column, contents: self.column(column) ?? []).eraseToAnyColumn()
        }
        return DataFrame(columns: frameColumns)
    }

    /// Creates a TabularData `DataFrame` with selected numeric columns.
    func numericDataFrame(columns selectedColumns: [String]? = nil) -> DataFrame? {
        let names = selectedColumns ?? columns
        let frameColumns = names.compactMap { name -> AnyColumn? in
            guard let tensor = numericColumn(name) else { return nil }
            return Column(name: name, contents: tensor.values).eraseToAnyColumn()
        }
        guard frameColumns.count == names.count else { return nil }
        return DataFrame(columns: frameColumns)
    }
}
#endif

private enum CSV {
    static func parse(_ csv: String) -> [[String]] {
        var records: [[String]] = []
        var row: [String] = []
        var field = ""
        var inQuotes = false
        var index = csv.startIndex

        while index < csv.endIndex {
            let character = csv[index]
            let next = csv.index(after: index)

            if character == "\"" {
                if inQuotes, next < csv.endIndex, csv[next] == "\"" {
                    field.append("\"")
                    index = csv.index(after: next)
                    continue
                }
                inQuotes.toggle()
            } else if character == ",", !inQuotes {
                row.append(field)
                field.removeAll(keepingCapacity: true)
            } else if (character == "\n" || character == "\r"), !inQuotes {
                row.append(field)
                records.append(row)
                row.removeAll(keepingCapacity: true)
                field.removeAll(keepingCapacity: true)

                if character == "\r", next < csv.endIndex, csv[next] == "\n" {
                    index = csv.index(after: next)
                    continue
                }
            } else {
                field.append(character)
            }

            index = next
        }

        if !field.isEmpty || !row.isEmpty {
            row.append(field)
            records.append(row)
        }

        return records.filter { !$0.allSatisfy(\.isEmpty) }
    }

    static func escape(_ field: String) -> String {
        guard field.contains(",")
            || field.contains("\"")
            || field.contains("\n")
            || field.contains("\r") else { return field }

        return "\"\(field.replacingOccurrences(of: "\"", with: "\"\""))\""
    }
}

/// A lightweight tabular adapter around string-backed rows.
public typealias DataTable = Numerica.DataScience.DataTable

/// Summary statistics for a numeric table column.
public typealias ColumnSummary = Numerica.DataScience.ColumnSummary

/// Grouped table rows and per-group numeric summaries.
public typealias GroupedDataTable = Numerica.DataScience.GroupedDataTable
