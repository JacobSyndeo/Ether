# Usage

There are several ways to use Ether. This article will help you decide which way to use, and in which cases.

## Overview

When using Ether, you may have your own coding style and/or preferences. You may prefer calling `Ether` directly. You may instead prefer to call from a `Route` or a `TypedRoute`. In other cases, you may prefer to use the `Fetchable` protocol. Ether supports all of these styles.

## Usage Styles

There are four main ways to use Ether:

- Directly, calling the functions on ``Ether/Ether``.
- Through ``Ether/EtherRoute``.
- Through ``Ether/EtherTypedRoute``.
- Through ``Ether/EtherFetchable``.

### Direct

In the most straightforward (but longform) way, you can call functions on ``Ether/Ether`` directly.

```swift
let user = try await Ether.get(route: Routes.user(id: 1),
                               type: User.self)
```

### Through a Route

If you want to use a ``Ether/EtherRoute``, you can use the ``Ether/EtherRoute/get(type:parameters:decoder:showAlertIfFailed:)`` method on the `Route` itself.

```swift
let user = try await Routes.user(id: 1).get(type: User.self)
```

### Through a TypedRoute

If you want to use ``Ether/EtherTypedRoute``, you can use the ``Ether/EtherTypedRoute/get(parameters:decoder:showAlertIfFailed:)`` method on the `TypedRoute` itself.

```swift
// Requires Routes to conform to `EtherTypedRoute`.
let user = try await Routes.user(id: 1).get()
```

### Through a Fetchable

If you want to use ``Ether/EtherFetchable``, you can use the ``Ether/EtherFetchable/fetch(id:parameters:)`` method on the `Fetchable` type itself.

```swift
// Requires User to conform to `EtherFetchable`.
let user = try await User.fetch(id: 1)
```

## Comparison

Here is a table comparing the different methods of using Ether.

Mode | How it works | Pros | Cons
--- | --- | --- | ---
Direct (``EtherRoute``) | `Ether.get(route: _, type: _, …)` | The most straightforward; no need to set anything else up | The longest
Direct (``EtherTypedRoute``) | `Ether.get(typedRoute: _, …)` | Shorter; omits `type` | Need to set up `TypedRoute`s
``EtherRoute`` | `route.get(type: _, …)` | Shorter; omits `Ether`; no need to set anything else up | A bit longer than others
``EtherTypedRoute`` | `typedRoute.get(_, …)` | Even shorter; omits both `Ether` and `type` | Need to set up `TypedRoute`s
``EtherFetchable`` | `Type.fetch(id: _)` | The clearest | Need to set up your types as `Fetchable`; doesn't support as much customization at call time

## Recommendations

### Use EtherFetchable when possible

We recommend using ``Ether/EtherFetchable`` most of the time, as it provides a clean, concise, and easy-to-use interface. It also allows you to use the same interface for all of your types, which can be useful if you have a lot of types that you want to fetch.

### Use EtherRoute when you need to customize the call

If you need to customize the call, you can use ``Ether/EtherRoute``. This allows you to customize the call, such as adding headers or changing the method. This lets you use ``EtherRoute``, which is a convenient typealias for both `URL` and `String`.

### Use EtherTypedRoute when you need to customize the call and don't want to specify the type each time

If you need to customize the call, but don't want to specify the type each time, you can use ``Ether/EtherTypedRoute``. This offers the same customization as EtherRoute, but also allows you to omit the type for each call. This does require you to set up ``TypedRoute``s, however, which can be a bit more work.

## Topics

### <!--@START_MENU_TOKEN@-->Group<!--@END_MENU_TOKEN@-->

- <!--@START_MENU_TOKEN@-->``Symbol``<!--@END_MENU_TOKEN@-->
