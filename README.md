# my_backyard

A very simple chat-game made in Godot Engine (exporting with WebAssembly) with a very minimal Nodejs websocket server (and static serving of the game files).

The server is by no means scalable, it is just around 100 lines of simple javascript, and I didn't even know javascript at that time!

I'm currently hosting it on mybackyard.rilpires.com

There is a Dockerfile, but you need to build the godot project outside from it first (because godot cli build command wasn't stable enough in 3.x versions)

![preview](/mybackyard.gif)
[I wrote a post about it on my blog](https://rilpires.github.io/games/mybackyard.html)
