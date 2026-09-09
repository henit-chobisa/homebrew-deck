# A review surface for agent work.
#
# Built from source rather than shipped as a bottle: a downloaded binary has to
# be signed and notarised before macOS will run it, and until that is set up a
# local build is the honest way in. It costs a few minutes once — deck compiles
# nineteen tree-sitter grammars into itself.
class Deck < Formula
  desc "Your agent points at code. You walk it, comment, submit"
  homepage "https://github.com/henit-chobisa/deck"
  url "https://github.com/henit-chobisa/deck.git", tag: "v0.0.5"
  license "Apache-2.0"
  head "https://github.com/henit-chobisa/deck.git", branch: "main"

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args(path: "crates/app")
  end

  def caveats
    <<~TEXT
      Run this once, to choose how deck looks and to tell your agents it exists:

        deck setup
    TEXT
  end

  test do
    assert_match "deck", shell_output("#{bin}/deck --help")

    # The whole loop, without a window: a deck is written, sealed, and read
    # back. If the protocol and the CLI disagree, this is where it shows.
    deck = shell_output("#{bin}/deck new --title 'A test' --at #{testpath} --total 1").strip
    system bin/"deck", "group", deck, "--say", "One claim.", "--ref", "#{testpath}/x.rs:1"
    system bin/"deck", "seal", deck
    assert_predicate Pathname(deck)/"deck.json", :exist?
    assert_predicate Pathname(deck)/"g1.json", :exist?
    assert_predicate Pathname(deck)/"done", :exist?
  end
end
