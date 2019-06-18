require "bento/common"

class DeleteRunner
  include Common

  attr_reader :box, :version

  def initialize(opts)
    @box = opts.box
    @version = opts.version
  end

  def start
    banner("Starting Delete...")
    time = Benchmark.measure do
      box = vc_account.get_box(box)
      version = box.get_version(version)
      version.delete
    end
    banner("Delete finished in #{duration(time.real)}.")
  end
end
