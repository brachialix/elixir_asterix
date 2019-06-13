# Elixir Asterix

The Elixir Asterix package provides means to decode [EUROCONTROL ASTERIX](https://www.eurocontrol.int/services/asterix) records.

Currently the following ASTERIX categories and editions are supported:

- [CAT 021](https://www.eurocontrol.int/publications/cat021-automatic-dependent-surveillance-broadcast-ads-b-messages-part-12)
    - ED 0.26

# Installation

This package can be installed by adding it to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:asterix, git: "https://github.com/brachialix/elixir_asterix.git", tag: "master"}
  ]
end
```

# Disclaimer

This software is provided as is without any kind of warranty or any kind of guarantee that
it might be fit for any purpose.

PS: I am an Elixir noob, so please be gentle. ;)


