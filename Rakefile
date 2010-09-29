require 'bundler'
Bundler::GemHelper.install_tasks

# I'm guessing this shouldn't be necessary, but $? stays nil for
# me, so all the GemHelper tasks breaks with no useful output.
# This fixes the problem, but assumes everything works...
module Bundler
  class GemHelper
    def sh_with_code(cmd, &block)
      outbuf, errbuf = '', ''
      Dir.chdir(base) {
        stdin, stdout, stderr = *Open3.popen3(cmd)
        outbuf, errbuf = stdout.read, stderr.read
        block.call(outbuf, errbuf) if block
      }
      [outbuf, errbuf, 0]
    end
  end
end
