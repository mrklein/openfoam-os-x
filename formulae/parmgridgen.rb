class Parmgridgen < Formula
  homepage "http://www-users.cs.umn.edu/~moulitsa/software.html"
  url "https://github.com/mrklein/ParMGridGen/archive/v0.0.2.tar.gz"
  sha256 "b3875d877def79c5fe37df0c9b1a43a47b3a99e8714f654a44d2010ce338ea93"

  depends_on "open-mpi"

  def install
    ENV.deparallelize

    system "make", "parallel"

    bin.install "bin/mgridgen"
    bin.install "bin/parmgridgen"
    include.install "mgridgen.h"
    include.install "parmgridgen.h"
    lib.install "libmgrid.a"
    lib.install "libparmgrid.a"
    lib.install "ParMGridGen/IMParMetis-2.0/libIMparmetis.a"
    lib.install "MGridGen/IMlib/libIMlib.a"
    doc.install "Doc/manual-parmgridgen.pdf"
    doc.install "Graphs/M6.metis"
    doc.install "Graphs/README"
  end
end
