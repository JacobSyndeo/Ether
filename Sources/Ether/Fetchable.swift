import Foundation

/// Types conforming to ``EtherSingularFetchable`` assert that their APIs provide a way to get single instances back, usually by providing an identifier.
public protocol EtherSingularFetchable: Decodable { // 12 syllables… oof
    static func singularRoute(id: String?) -> any EtherRoute
}

/// Types conforming to ``EtherPluralFetchable`` assert that their APIs provide a way to get multiple instances back, optionally filtered by fields specified in ``Ether.FetchableFilters``
public protocol EtherPluralFetchable: Decodable {
    static func pluralRoute(filters: Ether.FetchableFilters?) -> any EtherRoute
}

public typealias EtherFetchable = EtherSingularFetchable & EtherPluralFetchable

extension Ether {
    /// A typealias for ``EtherSingularFetchable``.
    /// Since it's a protocol, it requires a global namespace, but typealiases can be namespaced within other types.
    /// This lets it be accessed as `Ether.SingularFetchable`, much like how ``Method`` is accessible as `Ether.Method`, as well as other subtypes.
    /// - SeeAlso: ``EtherSingularFetchable``
    public typealias SingularFetchable = EtherSingularFetchable // 6 syllables… better!
    
    /// A typealias for ``EtherPluralFetchable``.
    /// Since it's a protocol, it requires a global namespace, but typealiases can be namespaced within other types.
    /// This lets it be accessed as `Ether.PluralFetchable`, much like how ``Method`` is accessible as `Ether.Method`, as well as other subtypes.
    /// - SeeAlso: ``EtherPluralFetchable``
    public typealias PluralFetchable = EtherPluralFetchable
    
    /// A typealias for ``EtherFetchable``.
    /// Since it's a protocol, it requires a global namespace, but typealiases can be namespaced within other types.
    /// This lets it be accessed as `Ether.Fetchable`, much like how ``Method`` is accessible as `Ether.Method`, as well as other subtypes.
    /// - SeeAlso: ``EtherFetchable``
    public typealias Fetchable = EtherFetchable
    
    /// A set of filters that can be used to narrow down results of queries. May or may not be supported by the API.
    /// Although limiting the availability of things at the compiler-level (based on whether or not the API supports them) is the rationale for most other decisions in Ether, segmenting things down to the level of these filters would likely be overkill to build and cumbersome to maintain, so it's unlikely to be done.
    public typealias FetchableFilters = (searchQuery: String?,
                                         dateRange: ClosedRange<Date>?)
}

// Implement fetch and fetchAll
public extension Ether.SingularFetchable {
    static func fetch(id: String? = nil, parameters: Ether.Parameters = [:]) async throws -> Self {
        return try await Ether.get(route: singularRoute(id: id),
                                   type: Self.self,
                                   parameters: parameters)
    }
    
    static func fetchWithContainer<Container: Decodable>(id: String? = nil,
                                                         parameters: Ether.Parameters = [:],
                                                         container: Container.Type) async throws -> Container {
        return try await Ether.get(route: singularRoute(id: id),
                                   type: Container.self,
                                   parameters: parameters)
    }
    
    static func fetch<Container: Decodable>(id: String? = nil,
                                            parameters: Ether.Parameters = [:],
                                            container: Container.Type,
                                            keyPath: KeyPath<Container, Self>) async throws -> Self {
        return try await fetchWithContainer(id: id,
                                            parameters: parameters,
                                            container: container)[keyPath: keyPath]
    }
}

extension Ether.PluralFetchable {
    public static func fetchAll(filters: Ether.FetchableFilters? = nil,
                                parameters: Ether.Parameters = [:]) async throws -> [Self] {
        return try await Ether.get(route: pluralRoute(filters: filters),
                                   type: [Self].self,
                                   parameters: parameters)
    }
    
    public static func fetchAllWithContainer<Container: Decodable>(filters: Ether.FetchableFilters? = nil,
                                                                   parameters: Ether.Parameters = [:],
                                                                   container: Container.Type,
                                                                   keyPath: KeyPath<Container, [Self]>) async throws -> Container {
        return try await Ether.get(route: pluralRoute(filters: filters),
                                    type: Container.self,
                                   parameters: parameters)
    }
    
    public static func fetchAll<Container: Decodable>(filters: Ether.FetchableFilters? = nil,
                                                      parameters: Ether.Parameters = [:],
                                                      container: Container.Type,
                                                      keyPath: KeyPath<Container, [Self]>) async throws -> [Self] {
        return try await fetchAllWithContainer(filters: filters,
                                               parameters: parameters,
                                               container: container,
                                               keyPath: keyPath)[keyPath: keyPath]
    }
}
