class LdcWeka < Formula
  desc "Portable D programming language compiler - fork for Weka.IO"
  homepage "https://wiki.dlang.org/LDC"
  version_scheme 1

  stable do
    url "https://github.com/weka-io/ldc.git", :shallow => false, :revision => "2d8c2b045d3e5ef69de0e240f973b30da263e48d"
    version "1.1.0-mac2"

    resource "ldc-lts" do
      url "https://github.com/ldc-developers/ldc/releases/download/v0.17.3/ldc-0.17.3-src.tar.gz"
      sha256 "325bd540f7eb71c309fa0ee9ef6d196a75ee2c3ccf323076053e6b7b295c2dad"
    end
  end

  needs :cxx11

  depends_on "cmake" => :build
  depends_on "llvm"
  depends_on "libconfig"

  conflicts_with "ldc", :because => "this is a patched ldc"

  def install
    ENV.cxx11
    (buildpath/"ldc-lts").install resource("ldc-lts")
    cd "ldc-lts" do
      mkdir "build" do
        args = std_cmake_args + %W[
          -DLLVM_ROOT_DIR=#{Formula["llvm"].opt_prefix}
        ]
        system "cmake", "..", *args
        system "make"
      end
    end
    mkdir "build" do
      args = std_cmake_args + %W[
        -DLLVM_ROOT_DIR=#{Formula["llvm"].opt_prefix}
        -DINCLUDE_INSTALL_DIR=#{include}/dlang/ldc
        -DD_COMPILER=#{buildpath}/ldc-lts/build/bin/ldmd2
      ]

      system "cmake", "..", *args
      system "make"
      system "make", "install"
    end
  end

  test do
    (testpath/"test.d").write <<-EOS.undent
      import std.stdio;
      void main() {
        writeln("Hello, world!");
      }
    EOS

    system bin/"ldc2", "test.d"
    assert_match "Hello, world!", shell_output("./test")
    system bin/"ldmd2", "test.d"
    assert_match "Hello, world!", shell_output("./test")
  end
end
