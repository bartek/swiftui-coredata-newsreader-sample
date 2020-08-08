# swiftui-coredata-newsreader-sample

This is my _fail-in-public_ approach to learning Swift and iOS development in
general!

This is a naive and simple "news reader" and the scope has been capped to what
is defined below. I don't plan to add features to this application but I may
update it as I learn more within this ecosystem.

The primary purposes of building this were to understand how Core Data interacts
with SwiftUI. There are plenty of things I am unsure, unhappy with, and continue
to learn about!

This application is written for iOS 13. I am not on Big Sur yet, so I have not
tinkered with any SwiftUI features available in iOS 14.

### What this project does

The scope of this project is a naive newsreader that does a few things OK-ish and
a lot of things poorly.

- [x] Fetches news articles (with title: "apple") from https://newsapi.org
- [x] Basic implementation of opening articles in a webview
- [x] Allows user to "infinitely" scroll through results (hard cap of 500 articles)
- [x] Uses a Core Data techniques and other means to prevent duplicate data and
unnecessary requests.
- [x] Allows user to dismiss article as read, which changes stored data, but does
not remove the data from the persistent store

I hope reading this code helped you in some way!
