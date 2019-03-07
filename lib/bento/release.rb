require "bento/common"

class ReleaseRunner
  include Common

  attr_reader :box, :version

  def initialize(opts)
    @box = opts.box
    @version = opts.version
  end

  def start
    banner("Releasing #{box}/#{version}...")
    time = Benchmark.measure do
      b = vc_account.get_box(box)
      v = b.get_version(version)
      v.release
    end
    banner("Release finished in #{duration(time.real)}.")
  end
end
