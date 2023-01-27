//  DataAccessObject.swift
import Foundation

public protocol DataAccessObject: AnyObject {
    func getDataStream() -> AsyncStream<Data>
    func onReceive(data: Data)
}

extension DataAccessObject {
    public func getObjStream<T:Decodable>() -> AsyncMapSequence<AsyncStream<Data>, T> {
        getDataStream().map({try! JSONDecoder().decode(T.self, from: $0)})
    }
}
