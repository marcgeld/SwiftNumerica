// This adapter is active only when the package's `TabularData` trait is enabled.
#if SWIFTNUMERICA_TABULARDATA && canImport(TabularData)
import SwiftNumerica
import TabularData

public extension Numerica.DataScience.DataTable {
    /// Creates a table from selected TabularData columns.
    ///
    /// String columns and numeric columns must be listed explicitly so the bridge
    /// stays strongly typed and avoids dynamic type inspection.
    init?(dataFrame: DataFrame, stringColumns: [String] = [], numericColumns: [String] = []) {
        let columns = stringColumns + numericColumns
        guard !columns.isEmpty,
              Set(columns).count == columns.count else { return nil }

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
