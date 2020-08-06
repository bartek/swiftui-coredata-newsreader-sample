# swiftui-coredata-newsreader-sample

This is my _fail-in-public_ approach to learning Swift and iOS development in
general!

For this exercise, I wanted to understand how to use Core Data when I am dealing
with an external API feed. As of writing this README, I've done my best to
understand how I might use Core Data in this case, but there are plenty of
things I am unsure, or unhappy with, and continue to learn about!

If you read the code and have opinions or feedback, I'd love it! That's the
reason for publishing :)

### What this project does

The scope of this project is a naive newsreader that does a few things well and
a lot of things poorly.

- [ ] Fetches news articles (with title: "apple") from https://newsapi.org
- [ ] Basic implementation of opening articles in a webview
- [ ] Allows user to "infinitely" scroll through results (hard cap of 500 articles)
- [ ] Uses a few built in techniques and other means to prevent duplicate data and
unnecessary requests.
- [ ] Allows user to dismiss article as read, which changes stored data, but does
not remove the data from the persistent store

As you can see, this isn't an application with much of the nuance of a news
reader considered! Enjoy!
