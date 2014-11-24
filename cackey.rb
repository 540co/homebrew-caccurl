require 'formula'

class Cackey < Formula
  homepage 'https://github.com/540co/homebrew-gitcac-binaries/homebrew-gitcac'
  url 'https://raw.github.com/540co/homebrew-gitcac-binaries/master/CACKey_0.7.0p1_Sltomav.pkg.tar.gz'
  sha1 'e118862f5526f06206e2eac078471be6bb022c06'

  def install
    ohai 'Installing cackey library; this requires admin privileges.'
    system "sudo", "/usr/sbin/installer", "-pkg", ".", "-target", "/"
  end
end