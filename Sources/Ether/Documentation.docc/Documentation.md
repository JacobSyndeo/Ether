# ``Ether``

The framework that makes working with network calls—and the data they return—not just bearable, but easy.
_Dare I say fun, even?_ See for yourself!

## Overview

Let's say you want to go fetch a `Blade` with ID `1`.

Normally, you'd write some code looking like this:
```swift
let url = URL(string: "https://xcapi.com/blades")! // Someone should make this API…

var request = URLRequest(url: url)
request.httpMethod = "GET"

let task = URLSession.shared.dataTask(with: request) { data, response, error in
    guard error == nil else {
        Task {
            await MainActor.run {
                UIAlertController.showBasicAlert("Error", message: "An error occurred while loading the data.")
            }
        }
        return
    }
    
    do {
        if let blade = try JSONDecoder().decode(Blade.self, from: data) {
            // Finally use the data
        }
    } catch {
        Task {
            await MainActor.run {
                UIAlertController.showBasicAlert("Decoding Error", message: "An error occurred while decoding the data.")
            }
        }
    }
}

task.resume()
```

_…Yikes._ Who wants to deal with that? Are we cavemen??

(It's a similar situation with `POST`ing data, but even more complex.)

Surely there's a better way to do this, right?

## GET
Enter Ether:
```swift
let blade = await Ether.get(route: Routes.blade(id: 1),
                            type: Blade.self)
```

Yep, Ether will not only perform the request for you, in one call, using async/await, but it will even decode the result into the `Decodable` type you want to use.

## POST
What about `POST`s, then?
```swift
try? await Ether.post(route: Routes.blade,
                      with: blade)
```
Dead simple.

## Custom Requests

Okay, but what about those times when you need to send a `TRACE` request the server, using a dictionary _without_ a corresponding struct, _AND_ it needs GZip encoding?

…sounds _awfully_ contrived, but hey, Ether's got you covered here as well:

```swift
let result = try? await Ether.request(route: Routes.echo,
                                      method: .trace,
                                      parameters: ["marco": "polo"],
                                      usingEncoding: .gZip)
```

Enjoy!

## Topics

### Firing off network requests

- ``Ether/Ether/get(route:type:parameters:decoder:showAlertIfFailed:)``
- ``Ether/Ether/post(route:with:usingEncoding:responseFormat:decoder:showAlertIfFailed:)``
- ``Ether/Ether/postMultipartForm(route:formItems:responseFormat:decoder:showAlertIfFailed:)``
- ``Ether/Ether/request(route:method:headers:parameters:body:responseFormat:usingEncoding:decoder:showAlertIfFailed:)``

### Routing

- ``EtherRoute``

### Responses

- ``Ether/Ether/Response``
