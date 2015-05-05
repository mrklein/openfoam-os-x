class Parmgridgen < Formula
  homepage "http://www-users.cs.umn.edu/~moulitsa/software.html"
  url "https://github.com/mrklein/ParMGridGen/archive/v0.0.1.tar.gz"
  sha256 "94fd48e0253c809646b2ce90d9e282dff63393802cdf0d29d21368617599b1c5"

  depends_on :mpi => :cc

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
    lib.install "MGridGen/IMLib/libIMlib.a"
    doc.install "Doc/manual-parmgridgen.pdf"
    doc.install "Graphs/M6.metis"
    doc.install "Graphs/README"
  end
end
