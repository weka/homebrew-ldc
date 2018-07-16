class LdcWeka < Formula
  desc "Portable D programming language compiler - fork for Weka.IO"
  homepage "https://wiki.dlang.org/LDC"
  version_scheme 2

  stable do
    url "https://github.com/weka-io/ldc/releases/download/weka-v1.8.0/ldc-weka-1.8.0-src.tar.xz"
    sha256 "cf8d3dbbb976eb04224157397b2baef0c152a7e754330902af224b159d119ab6"
  end

  head do
    url "https://github.com/weka-io/ldc.git", :shallow => false, :branch => "weka-master"
  end

  needs :cxx11

  depends_on "cmake" => :build
  depends_on "libconfig" => :build
  depends_on "llvm"

  conflicts_with "ldc", :because => "this is a patched ldc"

  resource "ldc-bootstrap" do
    url "https://github.com/ldc-developers/ldc/releases/download/v1.10.0/ldc2-1.10.0-osx-x86_64.tar.xz"
    version "1.10.0"
    sha256 "79df77cd4c03560c4a8d32030a5fdad6eac14bbb4e3710e6872e27dce1915403"
  end

  def install
    ENV.cxx11
    (buildpath/"ldc-bootstrap").install resource("ldc-bootstrap")

    mkdir "build" do
      args = std_cmake_args + %W[
        -DLLVM_ROOT_DIR=#{Formula["llvm"].opt_prefix}
        -DINCLUDE_INSTALL_DIR=#{include}/dlang/ldc
        -DD_COMPILER=#{buildpath}/ldc-bootstrap/bin/ldmd2
        -DLDC_WITH_LLD=OFF
        -DRT_ARCHIVE_WITH_LDC=OFF
      ]
      # LDC_WITH_LLD see https://github.com/ldc-developers/ldc/releases/tag/v1.4.0 Known issues
      # RT_ARCHIVE_WITH_LDC see https://github.com/ldc-developers/ldc/issues/2350

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
