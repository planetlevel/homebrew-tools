class Jot < Formula
  include Language::Python::Virtualenv

  desc "Java Observability Toolkit, a Java agent and a console that shows what an application does"
  homepage "https://github.com/planetlevel/jot"
  url "https://github.com/planetlevel/jot/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "111c9567e551540ba016fcce17e7e139526395289f0cd1c85d8f5eda6d4bcdb8"
  license "Apache-2.0"

  depends_on "maven" => :build
  depends_on "openjdk@21"
  depends_on "python@3.13"

  resource "pyyaml" do
    url "https://files.pythonhosted.org/packages/05/8e/961c0007c59b8dd7729d542c61a4d537767a59645b82a0b521206e1e25c2/pyyaml-6.0.3.tar.gz"
    sha256 "d76623373421df22fb4cf8817020cbb7ef15c725b9d5e45f17e189bfc384190f"
  end

  def install
    ENV["JAVA_HOME"] = Language::Java.java_home("21")
    system "mvn", "-q", "package", "-DskipTests"
    cp "target/jot-#{version}.jar", "jot.jar"

    libexec.install "bin", "catalog", "dashboard", "jot.jar"

    venv = virtualenv_create(libexec/"venv", "python3.13")
    venv.pip_install resources

    (bin/"jot").write_env_script libexec/"bin/jot",
      JOT_PYTHON: libexec/"venv/bin/python",
      JAVA_HOME:  Language::Java.java_home("21")
  end

  def caveats
    <<~EOS
      Start the console in the folder of the application you want to watch.
        cd your-app && jot
      Start the application with the agent.
        java -javaagent:$(jot jar) -jar your-app.jar
      The first run asks for an ANTHROPIC_API_KEY, which the Assistant needs.
      It is kept in .jot/.env in your project. Press Enter to skip.
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/jot version")
    assert_match "jot.jar", shell_output("#{bin}/jot jar")
  end
end
