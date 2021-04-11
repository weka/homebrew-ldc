class LdcWeka < Formula
  desc "Portable D programming language compiler - fork for Weka.IO"
  homepage "https://wiki.dlang.org/LDC"
  url "https://github.com/weka-io/ldc/releases/download/v1.21.0-weka/ldc-weka-1.21.0-weka.tar.xz"
  version "1.21.0-weka"
  sha256 "d86859dc04fddb6b9917338b1fcdb8bbc7258249dcab02691f2fa5401cbd0392"
  license "BSD-3-Clause"
  head "https://github.com/weka-io/ldc.git", :shallow => false, :branch => "weka-master"

  conflicts_with "ldc", :because => "this is a patched ldc"
  version_scheme 2

  bottle do
    root_url "https://github.com/weka-io/ldc/releases/download/v1.21.0-weka"
    sha256 catalina: "d4b9d31de8adb52ee1e7d6a5296ce8ff223b8c45fc9c74636b0adba44bc67dd1"
    sha256 big_sur: "6a16a2014117fb1b6ba144e5c1031540fe114afbe8128b8f49fbe03fda56455d"
  end

  depends_on "cmake" => :build
  depends_on "libconfig" => :build
  depends_on "llvm@9" # due to a bug in llvm 10 https://bugs.llvm.org/show_bug.cgi?id=47226

  uses_from_macos "libxml2" => :build

  on_linux do
    depends_on "pkg-config" => :build
  end

  resource "ldc-bootstrap" do
    url "https://github.com/ldc-developers/ldc/releases/download/v1.23.0/ldc2-1.23.0-osx-x86_64.tar.xz"
    version "1.23.0"
    sha256 "b3a6ec50f83063a66d5d538c635b1d1efc454bd8f2f8d74adaa93c36e1566dab"
  end

  def install
    ENV.cxx11
    (buildpath/"ldc-bootstrap").install resource("ldc-bootstrap")

    mkdir "build" do
      args = std_cmake_args + %W[
        -DLLVM_ROOT_DIR=#{Formula["llvm@9"].opt_prefix}
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
