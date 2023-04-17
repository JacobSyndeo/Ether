import Foundation

/// Types conforming to ``EtherSingularFetchable`` assert that their APIs provide a way to get single instances back, usually by providing an identifier.
public protocol EtherSingularFetchable: Decodable {
    /// The route used to request single instances of this type.
    /// Set this up to return proper route endpoints for any provided identifier (or `nil`, if appropriate for the API).
    ///
    /// By convention, this involves the route containing an identifier representing the specific item in question.
    /// E.g. in the URL `https://site.com/users/1`, the `1` represents the identifier.
    /// Some sites also use username strings, such as `https://github.com/JacobSyndeo`. In this case, `JacobSyndeo` is the identifier.
    ///
    /// For these, you'd want to return:
    /// `"https://site.com/users/" + id`
    /// or
    /// `"https://github.com/" + id`, respectively.
    /// - Parameter id: The identifier of the instance this route will fetch from the server.
    /// - Returns: The ``EtherRoute`` corresponding to the type and provided identifier.
    static func singularRoute(id: String?) -> any EtherRoute
}

/// Types conforming to ``EtherPluralFetchable`` assert that their APIs provide a way to get multiple instances back, optionally filtered by fields specified in ``Ether/Ether/FetchableFilters``
public protocol EtherPluralFetchable: Decodable {
    /// The route used to request multiple instances of this type.
    /// This is commonly used in index pages, search results, etc.
    /// Set this up to return the proper route endpoints, along with supporting filters (if desired and appropriate for the API).
    ///
    /// For instance, suppose your API is for a list of all the user's friends.
    /// It may look something like this:
    ///
    /// `"https://site.com/friends"`
    ///
    /// In that case, this function should simply return that exact string.
    ///
    /// However, if the API has a search friends feature that you'd like to support with Ether, you'd want to look at the filters.
    ///
    /// Suppose that API's search feature is represented as a URL query:
    /// `"https://site.com/friends?search=query"`
    ///
    /// You'd then change your return to look like this:
    ///
    /// ```
    /// var query = ""
    ///
    /// if let searchQuery = filters?.searchQuery {
    ///     query = "search=" + searchQuery
    /// }
    ///
    /// return "https://site.com/friends" + query
    /// ```
    ///
    /// - Parameter filters: An optional set of filters. See ``Ether/Ether/FetchableFilters`` for more information.
    /// - Returns: The ``EtherRoute`` corresponding to the type and (optionally) any provided filters.
    static func pluralRoute(filters: Ether.FetchableFilters?) -> any EtherRoute
}

public typealias EtherFetchable = EtherSingularFetchable & EtherPluralFetchable

extension Ether {
    /// A typealias for ``EtherSingularFetchable``, namespaced under ``Ether/Ether``.
    ///
    /// Since it's a protocol, it requires a global namespace, but typealiases can be namespaced within other types.
    /// This lets it be accessed as `Ether.SingularFetchable`, much like how ``Ether/Ether/Method`` is accessible as a type namespaced under ``Ether/Ether``, as well as other subtypes.
    /// - SeeAlso: ``EtherSingularFetchable``
    public typealias SingularFetchable = EtherSingularFetchable
    
    /// A typealias for ``EtherPluralFetchable``, namespaced under ``Ether/Ether``.
    ///
    /// Since it's a protocol, it requires a global namespace, but typealiases can be namespaced within other types.
    /// This lets it be accessed as `Ether.PluralFetchable`, much like how ``Ether/Ether/Method`` is accessible as a type namespaced under ``Ether/Ether``, as well as other subtypes.
    /// - SeeAlso: ``EtherPluralFetchable``
    public typealias PluralFetchable = EtherPluralFetchable
    
    /// A typealias for ``EtherFetchable``, namespaced under ``Ether/Ether``.
    ///
    /// Since it's a protocol, it requires a global namespace, but typealiases can be namespaced within other types.
    /// This lets it be accessed as `Ether.Fetchable`, much like how ``Ether/Ether/Method`` is accessible as a type namespaced under ``Ether/Ether``, as well as other subtypes.
    /// - SeeAlso: ``EtherFetchable``
    public typealias Fetchable = EtherFetchable
    
    /// A set of filters that can be used to narrow down results of queries. May or may not be supported by the API endpoint you're calling.
    ///
    /// Although limiting the availability of things at the compiler-level (based on whether or not the API supports them) is the rationale for most other decisions in Ether, segmenting things down to the level of these filters would likely be overkill to build and cumbersome to maintain, so it's unlikely to be done.
    /// It's a fun enough idea, however, that I'd be open to revisiting it in the future!
    public typealias FetchableFilters = (searchQuery: String?,
                                         dateRange: ClosedRange<Date>?)
}

// Implement fetch and fetchAll
public extension Ether.SingularFetchable {
    /// Fetch an instance of this type from the server.
    /// - Parameters:
    ///   - id: The identifier of the instance to fetch from the server.
    ///   - parameters: The parameters to use in the request. Defaults to empty.
    /// - Returns: The instance requested.
    static func fetch(id: String? = nil, parameters: Ether.Parameters = [:]) async throws -> Self {
        return try await Ether.get(route: singularRoute(id: id),
                                   type: Self.self,
                                   parameters: parameters)
    }
    
    /// Fetch an instance of this type from the server, within a container type.
    ///
    /// Sometimes, servers don't directly give you the type you want. Sometimes, it's wrapped up in some kind of "Results" container type.
    /// Typically, this includes various metadata about the request and/or response.
    ///
    /// However, this conflicts with Fetchable's `fetch` function, which normally needs to give the caller exactly the type it was expecting.
    ///
    /// So if the server is giving you a result container (which contains the type you're after), this function is for you!
    ///
    /// Otherwise, in the case that you _don't_ want that metadata, use ``Ether/Ether/SingularFetchable/fetchWithContainer(id:parameters:container:keyPath:)``.
    /// - Parameters:
    ///   - id: The identifier of the instance to fetch from the server.
    ///   - parameters: The parameters to use in the request. Defaults to empty.
    ///   - container: The container type to decode from. You'll need to create this type based on the server's API response format.
    /// - Returns: An instance of the provided container format, based on the server's response.
    static func fetchWithContainer<Container: Decodable>(id: String? = nil,
                                                         parameters: Ether.Parameters = [:],
                                                         container: Container.Type) async throws -> Container {
        return try await Ether.get(route: singularRoute(id: id),
                                   type: Container.self,
                                   parameters: parameters)
    }
    
    /// Fetch an instance of this type from the server, unwrapping from a container type.
    ///
    /// Sometimes, servers don't directly give you the type you want. Sometimes, it's wrapped up in some kind of "Results" container type.
    /// Typically, this includes various metadata about the request and/or response.
    ///
    /// However, this conflicts with Fetchable's ``Ether/EtherSingularFetchable/fetch(id:parameters:)`` function, which normally needs to give the caller exactly the type it was expecting.
    ///
    /// If all you really care about is the type you asked for, then this function is for you!
    ///
    /// Otherwise, in the case that you _do_ want that metadata, use ``Ether/EtherSingularFetchable/fetchWithContainer(id:parameters:container:)``.
    /// - Parameters:
    ///   - id: The identifier of the instance to fetch from the server.
    ///   - parameters: The parameters to use in the request. Defaults to empty.
    ///   - container: The container type to decode from. You'll need to create this type based on the server's API response format.
    ///   - keyPath: The key path representing the location of this type within the container.
    /// - Returns: An instance of the type with the provided identifier, based on the server's response.
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
    /// Fetch all available instances of this type from the server that match the provided filters (if any).
    /// - Parameters:
    ///   - filters: An optional set of filters. See ``Ether/Ether/FetchableFilters`` for more information.
    ///   - parameters: The parameters to use in the request. Defaults to empty.
    /// - Returns: An array containing all available instances of the type matching the provided filters (if any), based on the server's response.
    public static func fetchAll(filters: Ether.FetchableFilters? = nil,
                                parameters: Ether.Parameters = [:]) async throws -> [Self] {
        return try await Ether.get(route: pluralRoute(filters: filters),
                                   type: [Self].self,
                                   parameters: parameters)
    }
    
    /// Fetch all available instances of this type from the server that match the provided filters (if any), within a container type.
    ///
    /// Sometimes, servers don't directly give you instances of the type you want. Sometimes, it's wrapped up in some kind of "Results" container type.
    /// Typically, this includes various metadata about the request and/or response.
    ///
    /// However, this conflicts with Fetchable's ``Ether/EtherPluralFetchable/fetchAll(filters:parameters:)`` function, which normally needs to give the caller an array of exactly the type it was expecting.
    ///
    /// So if the server is giving you a result container (which contains the instances of the type you're after), this function is for you!
    ///
    /// Otherwise, in the case that you _don't_ want that metadata, use ``Ether/EtherPluralFetchable/fetchWithContainer(filters:parameters:container:keyPath:)``.
    /// - Parameters:
    ///   - filters: An optional set of filters. See ``Ether/Ether/FetchableFilters`` for more information.
    ///   - parameters: The parameters to use in the request. Defaults to empty.
    ///   - container: The container type to decode from. You'll need to create this type based on the server's API response format.
    ///   - keyPath: The key path representing the location of the array of instances of the type within the container.
    /// - Returns: An instance of the provided container format, based on the server's response.
    public static func fetchAllWithContainer<Container: Decodable>(filters: Ether.FetchableFilters? = nil,
                                                                   parameters: Ether.Parameters = [:],
                                                                   container: Container.Type,
                                                                   keyPath: KeyPath<Container, [Self]>) async throws -> Container {
        return try await Ether.get(route: pluralRoute(filters: filters),
                                    type: Container.self,
                                   parameters: parameters)
    }
    
    /// Fetch all available instances of this type from the server that match the provided filters (if any), unwrapping from a container type.
    ///
    /// Sometimes, servers don't directly give you instances of the type you want. Sometimes, it's wrapped up in some kind of "Results" container type.
    /// Typically, this includes various metadata about the request and/or response.
    ///
    /// However, this conflicts with Fetchable's ``Ether/EtherPluralFetchable/fetchAll(filters:parameters:)`` function, which normally needs to give the caller an array of exactly the type it was expecting.
    ///
    /// If all you really care about is the type you asked for, then this function is for you!
    ///
    /// Otherwise, in the case that you _do_ want that metadata, use ``Ether/EtherPluralFetchable/fetchWithContainer(filters:parameters:container:)``.
    /// - Parameters:
    ///   - filters: An optional set of filters. See ``Ether/Ether/FetchableFilters`` for more information.
    ///   - parameters: The parameters to use in the request. Defaults to empty.
    ///   - container: The container type to decode from. You'll need to create this type based on the server's API response format.
    ///   - keyPath: The key path representing the location of this type within the container.
    /// - Returns: An array containing all available instances of the type matching the provided filters (if any), based on the server's response.
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
