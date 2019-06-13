# Asterix

The Astrix package provides means to decode EUROCONTROL ASTERIX records.

Currently the following ASTERIX categories and editions are supported:

- CAT 021
 - ED 0.26

# Disclaimer

This software is provided as is without any kind of warranty or any kind of guarantee that
it might be fit for any purpose.

PS: I am an Elixir noob, so please be gentle. ;)


## Installation

This package can be installed by adding it to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:asterix, git: "https://github.com/brachialix/elixir_asterix.git", tag: "master"}
  ]
end
```


