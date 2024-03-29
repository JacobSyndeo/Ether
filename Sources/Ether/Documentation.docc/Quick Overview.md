# Quick Overview

A quick glance at Ether

## Overview

Let's say you want to go fetch an instance of `Blade` with ID `1`.

Normally, you'd write some code looking like this:
```swift
let url = URL(string: "https://xcapi.com/blades/1")! // Someone should make this API…

var request = URLRequest(url: url)
request.httpMethod = "GET"

let task = URLSession.shared.dataTask(with: request) { data, response, error in
    guard error == nil else {
        // Handle error…
        return
    }
    
    do {
        if let pyra = try JSONDecoder().decode(Blade.self, from: data) {
            // It's about time!
        }
    } catch {
        // Handle error…
    }
}

task.resume()
```

_…Yikes._ Are we cavemen?? Surely we can do better.

## GET
Let's replace this GET request using Ether:
```swift
let pyra = try? await Ether.get(route: Routes.blade(id: 1),
                                type: Blade.self)
```

Yep, Ether will not only perform the request for you, in one call, using async/await, but it will even decode the result into the `Decodable` type you want to use.

## POST
What about `POST`s?
```swift
try? await Ether.post(route: Routes.time,
                      with: reyn)
```
Dead simple.

## Custom Requests

Okay, but what about those times when you need to send a `PUT` request the server, using a dictionary _without_ a corresponding struct, _AND_ it needs GZip encoding?

…sounds _awfully_ contrived, but hey, Ether's got you covered here as well:

```swift
let result = try? await Ether.request(route: Routes.locations,
                                      method: .put,
                                      parameters: ["Dunban": "over there"],
                                      usingEncoding: .gZip)
```

So there ya go! Not bad, huh? 😎

<!--## Topics-->
<!---->
<!--### <!--@START_MENU_TOKEN@-->Group<!--@END_MENU_TOKEN@-->-->
<!---->
<!--- <!--@START_MENU_TOKEN@-->``Symbol``<!--@END_MENU_TOKEN@-->-->
