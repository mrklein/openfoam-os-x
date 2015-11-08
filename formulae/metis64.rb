class Metis64 < Formula
  homepage "http://glaros.dtc.umn.edu/gkhome/views/metis"
  url "http://glaros.dtc.umn.edu/gkhome/fetch/sw/metis/metis-5.1.0.tar.gz"
  sha256 "76faebe03f6c963127dbb73c13eab58c9a3faeae48779f049066a21c087c5db2"

  depends_on "cmake" => :build

  patch :DATA

  keg_only "Conflicts with metis formula"

  def install
    make_args = ["shared=1", "prefix=#{prefix}"]
    make_args << "openmp=" + ((ENV.compiler == :clang) ? "0" : "1")
    system "make", "config", *make_args
    system "make", "install"

    (share / "metis").install "graphs"
    doc.install "manual"
  end

  test do
    ["4elt", "copter2", "mdual"].each do |g|
      system "#{bin}/graphchk", "#{share}/metis/graphs/#{g}.graph"
      system "#{bin}/gpmetis", "#{share}/metis/graphs/#{g}.graph", "2"
      system "#{bin}/ndmetis", "#{share}/metis/graphs/#{g}.graph"
    end
    system "#{bin}/gpmetis", "#{share}/metis/graphs/test.mgraph", "2"
    system "#{bin}/mpmetis", "#{share}/metis/graphs/metis.mesh", "2"
  end
end
__END__
diff --git a/include/metis.h b/include/metis.h
index dc5406a..e951270 100644
--- a/include/metis.h
+++ b/include/metis.h
@@ -30,7 +30,7 @@
  GCC does provides these definitions in stdint.h, but it may require some
  modifications on other architectures.
 --------------------------------------------------------------------------*/
-#define IDXTYPEWIDTH 32
+#define IDXTYPEWIDTH 64
 
 
 /*--------------------------------------------------------------------------
@@ -40,7 +40,7 @@
    32 : single precission floating point (float)
    64 : double precission floating point (double)
 --------------------------------------------------------------------------*/
-#define REALTYPEWIDTH 32
+#define REALTYPEWIDTH 64
