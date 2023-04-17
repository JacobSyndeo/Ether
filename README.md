# 🎆 Ether

Ether is a networking library for Swift. It is designed to be delightful to use and easy to understand.

## Why another networking library?

With so many networking libraries out there, why did I make Ether?

After exploring and trying many networking libraries, I found that they all had some problems:

- **They're overcomplicated**. Most networking libraries have a complicated API that is hard to understand and use. Often, you have to chain together a lot of methods and properties, which makes the code hard to read and understand.
- **They feel heavy**. Most networking libraries feel heavy, requiring a lot of boilerplate code and a lot of setup.
- **No Swift Concurrency support**. Most networking libraries don't support Swift Concurrency. They don't use async/await, requiring a lot of closures and completion handlers that clutter up your codebase, making it harder to read, understand, and maintain.
- **They're not generic**. Many networking libraries don't support generics, simply returning `Data` or `Any`. This is an anti-pattern in Swift, and it makes it harder to use the library.
- **They don't use Swift errors**. Many networking libraries aren't using Swift errors, instead opting for custom result types, which is less semantic and makes it harder to handle errors.

Ether is designed to solve these problems:

- **It's easy to use**. Ether is designed to be easy to use, with useful defaults and a simple API.
- **It's easy to understand**. Ether is designed to be easy to understand. It follows Swift's "progressive disclosure" design pattern, where you only need to learn about the features you need. I've also put a lot of effort into making the documentation clear and easy to understand.
- **It's lightweight**. Ether is designed to be lightweight. It relies on Swift's built-in `URLSession` and `JSONEncoder`/`JSONDecoder` types, and it doesn't require a lot of boilerplate code or setup.
- **Full Swift Concurrency support**. Ether is designed to support Swift Concurrency. It uses async/await, which makes it easier to use and understand.
- **It's generic**. Ether is designed to be generic. It can be used with any type that conforms to `Codable`, which makes it easier to use. Conforming to ``Fetchable` provides even more features.
- **It uses Swift errors**. Ether properly handles errors, including network errors and HTTP errors, and throws them as Swift errors.
- **It's open-source**. Ether is open source! It's free to use, and anyone can contribute to it.

Furthermore, Ether has some features that you won't find in other networking libraries:

- **Automatic decoding**. Ether automatically decodes JSON responses into Swift types. This not only makes it easier to use, but greatly reduces the amount of boilerplate code you need to write.
- **Alert support**. Ether has built-in support for showing alerts when network requests fail, which (again) reduces the amount of boilerplate code you need to write.

## Getting started

Let's say you want to go fetch an instance of `Blade` with ID `1`.

Normally, you'd write some code looking like this:
```swift
let url = URL(string: "https://xcapi.com/blades")! // Someone should make this API…

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
                                      usingEncoding: .gZip,
                                      showAlertIfFailed: .ifUserHasntMuted)
```

Enjoy!
