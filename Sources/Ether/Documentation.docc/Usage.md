# Usage

There are several ways to use Ether. This article will help you decide which way to use, and in which cases.

## Overview

Mode | How it works | Pros | Cons
--- | --- | --- | ---
Direct (`Route`) | `Ether.get(route: _, type: _, …)` | The most straightforward; no need to set anything else up | The longest
Direct (`TypedRoute`) | `Ether.get(typedRoute: _, …)` | Shorter; omits `type` | Need to set up `TypedRoute`s
`Route` | `route.get(type: _, …)` | Shorter; omits `Ether`; no need to set anything else up | A bit longer than others
`TypedRoute` | `typedRoute.get(_, …)` | Even shorter; omits both `Ether` and `type` | Need to set up `TypedRoute`s
`Fetchable` | `Type.fetch(id: _)` | The clearest | Need to set up your types as `Fetchable`; doesn't support as much customization at call time

## Topics

### <!--@START_MENU_TOKEN@-->Group<!--@END_MENU_TOKEN@-->

- <!--@START_MENU_TOKEN@-->``Symbol``<!--@END_MENU_TOKEN@-->
