// DataManager

import os.log
import Foundation
import SingleInstance

public enum DataManagerError: Error {
    case dataSourceNotFound(String)
    case dataSourceNotUniquelyInstaced(String)
    case dataSourceReferenceNotStoredInUnownedProperty(String)
    case dataSourceTypeConversionFailed(String)
}

private struct UnownedDataSource {
    var dataSource: DataSource
}

open class DataManager: SingleInstance {
    // responsibilities: create DAO, manage datasources, manage middleware hooks
    private var dataSources = [String: UnownedDataSource]()
    private var dataSourceTypes = [String: DataSource.Type]()

    @available(*, obsoleted:0.0, message:"Use init?(dataSources:) instead.")
    public required init?() {
        return nil
    }

    public init?(dataSources: [DataSource.Type]) {
        guard type(of: self) !== DataManager.self
        else {
            os_log("ERROR: Do not create direct instances of DataManager class, instantiate subclasses instead.")
            return nil
        }

        guard !dataSources.isEmpty
        else {
            os_log("ERROR: DataManager cannot initialize without data sources")
            return nil
        }

        for dataSource in dataSources {
            if let instantiatedDataSource = dataSource.init() {
                guard self.dataSources[instantiatedDataSource.dataSourceID] == nil
                else {
                    os_log("ERROR: Non-unique data source detected \(instantiatedDataSource.dataSourceID). DataManager not initialized.")
                    return nil
                }
                self.dataSources[instantiatedDataSource.dataSourceID] = UnownedDataSource(dataSource: instantiatedDataSource)
                self.dataSourceTypes[instantiatedDataSource.dataSourceID] = dataSource
            } else {
                os_log("ERROR: Couldn't instantiate SingleInstance data source \(dataSource). DataManager not initialized.")
                return nil
            }
        }
    }

    fileprivate struct ObjectWrapper {
        unowned var object: AnyObject
    }

    public func injectDataSource<T>(_ t: T.Type) throws -> T {
        var id = ""
        for (key, value) in dataSourceTypes where value == t {
            id = key
            break
        }
        guard dataSources[id] != nil
        else {
            throw DataManagerError.dataSourceNotFound(id)
        }
        if let dataSource = dataSources[id]?.dataSource as? T {
            return dataSource
        } else {
            throw DataManagerError.dataSourceTypeConversionFailed(id)
        }
    }

    public func createDataAccessObject(id: String, params:[String:String]=[:]) -> DataAccessObject? {
        let components = id.split(separator: ".").map(String.init)
        guard components.count > 1
        else {
            os_log("ERROR: createDataAccessObject `id` requires at least two dot-separated components (\"datasource.service\"), got \"\(id)\"")
            return nil
        }
        guard let dataSource = dataSources[components[0]]?.dataSource else { return nil }
        return dataSource.createDataAccessObject(id: components[1], params: params)
    }
}
