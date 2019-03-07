require "bento/common"

class RevokeRunner
  include Common

  attr_reader :box, :version

  def initialize(opts)
    @box = opts.box
    @version = opts.version
  end

  def start
    banner("Revoking #{box}/#{version}...")
    time = Benchmark.measure do
      box = vc_account.get_box(box)
      version = box.get_version(version)
      version.revoke
    end
    banner("Revoke finished in #{duration(time.real)}.")
  end
end
