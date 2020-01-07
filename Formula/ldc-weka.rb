class LdcWeka < Formula
  desc "Portable D programming language compiler - fork for Weka.IO"
  homepage "https://wiki.dlang.org/LDC"
  version_scheme 2

  stable do
    url "https://github.com/weka-io/ldc/releases/download/v1.13.0-weka_3/ldc-weka-1.13.0-weka_3-src.tar.xz"
    version "1.13.0-weka_3"
    sha256 "cd262496360009cf524182fa87ab75b7d0c954b80d613ca71f6d0fb291bca21f"
  end

  bottle do
    root_url "https://s3.amazonaws.com/wekaio-public/brew-bottles"
    sha256 "285ca4f2e8d28ea5d76131df931154ca93f6c083e1954ea217eb43ad9dbb04c3" => :mojave
  end

  head do
    url "https://github.com/weka-io/ldc.git", :shallow => false, :branch => "weka-master"
  end

  depends_on "cmake" => :build
  depends_on "libconfig" => :build
  # Pinning LLVM to 6.x - ldc2 v1.13.0 supports LLVM up to 7.0 (vs 9.0 which is the latest
  # on homebrew), but fails with 7.1.0 for some reason
  depends_on "llvm@6"

  conflicts_with "ldc", :because => "this is a patched ldc"

  resource "ldc-bootstrap" do
    url "https://github.com/ldc-developers/ldc/releases/download/v1.19.0/ldc2-1.19.0-osx-x86_64.tar.xz"
    version "1.19.0"
    sha256 "c7bf6facfa61f2e771091b834397b36331f5c28a56e988f06fc4dc9fe0ece3ae"
  end

  def install
    ENV.cxx11
    (buildpath/"ldc-bootstrap").install resource("ldc-bootstrap")

    mkdir "build" do
      args = std_cmake_args + %W[
        -DLLVM_ROOT_DIR=#{Formula["llvm@6"].opt_prefix}
        -DINCLUDE_INSTALL_DIR=#{include}/dlang/ldc
        -DD_COMPILER=#{buildpath}/ldc-bootstrap/bin/ldmd2
      ]

      system "cmake", "..", *args
      system "make"
      system "make", "install"
    end
  end

  test do
    (testpath/"test.d").write <<~EOS
      import std.stdio;
      void main() {
        writeln("Hello, world!");
      }
    EOS
    system bin/"ldc2", "test.d"
    assert_match "Hello, world!", shell_output("./test")
    system bin/"ldc2", "-flto=thin", "test.d"
    assert_match "Hello, world!", shell_output("./test")
    system bin/"ldc2", "-flto=full", "test.d"
    assert_match "Hello, world!", shell_output("./test")
    system bin/"ldmd2", "test.d"
    assert_match "Hello, world!", shell_output("./test")
  end
end
