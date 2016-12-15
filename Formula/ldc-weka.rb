class LdcWeka < Formula
  desc "Portable D programming language compiler - fork for Weka.IO"
  homepage "https://wiki.dlang.org/LDC"
  url "https://github.com/weka-io/ldc.git", :revision => "e6a3448cf81cd0cab76c178eeabfb01befa00c30"
  version "2.070-weka_e6a3448"

  head do
    url "https://github.com/weka-io/ldc.git", :shallow => false, :branch => "weka-2.071"
    version "2.071-weka"
  end

  resource "ldc-lts" do
    url "https://github.com/ldc-developers/ldc.git", :shallow => false, :branch => "ltsmaster"
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
