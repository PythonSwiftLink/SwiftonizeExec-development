

class SwiftonizeAT02 < Formula
  desc ""
  homepage ""

  url "https://github.com/PythonSwiftLink/SwiftonizeExec/releases/download/{{ cookiecutter.version }}/swiftonize.tar.gz"
  version "{{ cookiecutter.version }}"
  sha256 "{{ cookiecutter.sha }}"
  license ""

  def install
    bin.install "Swiftonize"
    bin.install "python_stdlib"
    bin.install "python-extra"
    end

  test do
    system "false"
  end
end
