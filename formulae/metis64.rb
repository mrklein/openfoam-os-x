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
diff --git a/GKlib/error.c b/GKlib/error.c
index e2a18cf..7a58f3d 100644
--- a/GKlib/error.c
+++ b/GKlib/error.c
@@ -18,7 +18,7 @@ This file contains functions dealing with error reporting and termination
 
 /* These are the jmp_buf for the graceful exit in case of severe errors.
    Multiple buffers are defined to allow for recursive invokation. */
-#define MAX_JBUFS 128
+#define MAX_JBUFS 24
 __thread int gk_cur_jbufs=-1;
 __thread jmp_buf gk_jbufs[MAX_JBUFS];
 __thread jmp_buf gk_jbuf;
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
 
 
 
diff --git a/programs/CMakeLists.txt b/programs/CMakeLists.txt
index 3aaf357..d948257 100644
--- a/programs/CMakeLists.txt
+++ b/programs/CMakeLists.txt
@@ -1,6 +1,5 @@
 # These programs use internal metis data structures.
 include_directories(../libmetis)
-link_directories(/home/karypis/local/lib)
 # Build program.
 add_executable(gpmetis gpmetis.c cmdline_gpmetis.c io.c stat.c)
 add_executable(ndmetis ndmetis.c cmdline_ndmetis.c io.c smbfactor.c)
