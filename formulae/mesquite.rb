class Mesquite < Formula
  homepage "http://trilinos.org/packages/mesquite/"
  url "http://sourceforge.net/projects/openfoam-extend/files/foam-extend-3.1/ThirdParty/mesquite-2.1.2.tar.gz"
  sha256 "a1410104737c27e6f59b131b5c93a462016c5f2e51cf4381dd940638fe1a968f"

  depends_on "cmake" => :build

  def install
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}",
                          "--enable-release",
                          "--disable-debug-assertions",
                          "--disable-igeom",
                          "--disable-imesh",
                          "--disable-irel",
                          "--enable-shared",
                          "--without-cppunit",
                          "--enable-trap-fpe",
                          "--disable-function-timers"
    system "make", "install"
  end

  test do
  end
end
