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
    {:asterix, git: "https://github.com/brachialix/elixir_asterix.git", branch: "master"}
  ]
end
```

# Author

Alex Wemmer: elixir_asterix@wemmer.at

PS: I am an Elixir noob, so please be gentle. ;)

# License

The source code is released under GNU GPLv3

# Disclaimer

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.







