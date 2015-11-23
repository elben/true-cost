# True Cost

## Development

(First [install Elm](http://elm-lang.org/install))

```bash
elm repl
import Main exposing (..)
```

And then open `index.html` to see it in action!

A good way to test on a phone is to use `ngrok`:

```
cd ~/code/true-cost
python -m SimpleHTTPServer 8005

ngrok http 8005
```

### Compiling

```
elm make Main.elm --output truecost.js
open index.html
```

# Notes

- [HTML interop with Elm](http://elm-lang.org/guide/interop)
