# frozen_string_literal: true

require 'spec_helper'
require 'bento/vagrant_freedos'

RSpec.describe Bento::VagrantFreedos::Communicator do
  subject(:communicator) { described_class.new(machine) }

  let(:freedos_cfg) { Bento::VagrantFreedos::Config.new }
  let(:vm_config) { double('vm_config', freedos: freedos_cfg) }
  let(:machine) { double('machine', config: vm_config) }
  let(:mock_socket) { double('socket', closed?: false, flush: nil, close: nil) }
  let(:crlf) { described_class::CRLF }
  let(:bs) { described_class::BS }

  before do
    allow(TCPSocket).to receive(:new).and_return(mock_socket)
    allow(SecureRandom).to receive(:hex).with(4).and_return('abcd1234')
  end

  describe '#freedos_config' do
    it 'finalizes and returns machine.config.freedos when present' do
      cfg = communicator.freedos_config
      expect(cfg.host).to eq('127.0.0.1')
      expect(cfg.port).to eq(2323)
    end

    it 'creates a finalized fallback Config when machine has no config.freedos' do
      bare_machine = double('bare_machine')
      comm = described_class.new(bare_machine)
      cfg = comm.freedos_config
      expect(cfg).to be_a(Bento::VagrantFreedos::Config)
      expect(cfg.port).to eq(2323)
    end
  end

  describe '#execute and #sudo' do
    it 'frames commands, strips prompts, yields stdout, and returns %ERRORLEVEL%' do
      allow(mock_socket).to receive(:write)
      response = [
        "C:#{bs}>ECHO ===START_ABCD1234===",
        '===START_ABCD1234===',
        "C:#{bs}>VER",
        'FreeCom version 0.85a',
        "C:#{bs}>ECHO ===EXIT_ABCD1234:0===",
        '===EXIT_ABCD1234:0==='
      ].join(crlf)
      allow(mock_socket).to receive(:readpartial).and_return(response)

      yielded = []
      code = communicator.execute('VER') do |type, data|
        yielded << [type, data]
      end

      expect(code).to eq(0)
      expect(yielded).to eq([[:stdout, "FreeCom version 0.85a
"]])
      expect(communicator.sudo('VER')).to eq(0)
    end

    it 'raises CommunicatorError when exit code is non-zero and error_check is true' do
      allow(mock_socket).to receive(:write)
      response = "===START_ABCD1234===#{crlf}Bad command#{crlf}===EXIT_ABCD1234:3===#{crlf}"
      allow(mock_socket).to receive(:readpartial).and_return(response)

      expect do
        communicator.execute('BADCMD')
      end.to raise_error(Bento::VagrantFreedos::CommunicatorError, /ERRORLEVEL 3/)
    end

    it 'returns non-zero exit code without raising when error_check is false' do
      allow(mock_socket).to receive(:write)
      response = "===START_ABCD1234===#{crlf}===EXIT_ABCD1234:7===#{crlf}"
      allow(mock_socket).to receive(:readpartial).and_return(response)

      expect(communicator.execute('FAILCMD', error_check: false)).to eq(7)
    end

    it 'raises CommunicatorError on EOFError before exit marker arrives' do
      allow(mock_socket).to receive(:write)
      allow(mock_socket).to receive(:readpartial).and_raise(EOFError)

      expect do
        communicator.execute('VER')
      end.to raise_error(Bento::VagrantFreedos::CommunicatorError, /Connection closed/)
    end

    it 'supports UNIXSocket when transport is :unix_socket' do
      freedos_cfg.finalize!
      freedos_cfg.transport = :unix_socket
      freedos_cfg.serial_socket = '/tmp/test_freedos.sock'
      expect(UNIXSocket).to receive(:new).with('/tmp/test_freedos.sock').and_return(mock_socket)
      allow(mock_socket).to receive(:write)
      allow(mock_socket).to receive(:readpartial).and_return("===START_ABCD1234===#{crlf}===EXIT_ABCD1234:0===#{crlf}")

      expect(communicator.execute('VER')).to eq(0)
    end
  end

  describe '#ready? and #wait_for_ready' do
    it 'returns true when ping marker is echoed back' do
      allow(mock_socket).to receive(:write)
      allow(mock_socket).to receive(:readpartial).and_return(
        "===START_ABCD1234===#{crlf}===VAGRANT_PING===#{crlf}===EXIT_ABCD1234:0===#{crlf}"
      )
      expect(communicator.ready?).to be(true)
      expect(communicator.wait_for_ready(1)).to be(true)
    end

    it 'returns false when socket raises an exception or times out' do
      allow(mock_socket).to receive(:write).and_raise(Errno::ECONNREFUSED)
      expect(communicator.ready?).to be(false)
      expect(communicator.wait_for_ready(0.01)).to be(false)
    end
  end

  describe '#reset!' do
    it 'closes existing socket (or skips close if already closed) and opens a new socket' do
      allow(mock_socket).to receive(:write)
      allow(mock_socket).to receive(:readpartial).and_return("===START_ABCD1234===#{crlf}===EXIT_ABCD1234:0===#{crlf}")
      communicator.execute('VER')
      expect(mock_socket).to receive(:close)
      expect(communicator.reset!).to be_nil

      allow(mock_socket).to receive(:closed?).and_return(true)
      expect(communicator.reset!).to be_nil
    end
  end

  describe '#test' do
    it 'returns true on exit code 0 and false on non-zero or exception' do
      allow(communicator).to receive(:execute).and_return(0)
      expect(communicator.test('VER')).to be(true)

      allow(communicator).to receive(:execute).and_return(1)
      expect(communicator.test('FAIL')).to be(false)

      allow(communicator).to receive(:execute).and_raise(StandardError, 'boom')
      expect(communicator.test('ERR')).to be(false)
    end
  end

  describe '#upload and #download' do
    it 'raises CommunicatorError when source path does not exist' do
      expect do
        communicator.upload('/nonexistent/file/path.txt', "D:#{bs}TEST.TXT")
      end.to raise_error(Bento::VagrantFreedos::CommunicatorError, /does not exist/)
    end

    it 'uploads a single file and a recursive directory to FreeDOS' do
      Dir.mktmpdir do |tmpdir|
        sub = File.join(tmpdir, 'sub')
        FileUtils.mkdir_p(sub)
        single_file = File.join(tmpdir, 'hello.c')
        File.write(single_file, 'int main() { return 0; }')
        File.write(File.join(sub, 'nested.h'), '#define X 1')

        executed_cmds = []
        allow(communicator).to receive(:execute) do |cmd, _opts|
          executed_cmds << cmd
          0
        end

        expect(communicator.upload(single_file, "D:#{bs}HELLO.C")).to be(true)
        expect(communicator.upload(tmpdir, '/vagrant')).to be(true)
        expect(communicator.upload(tmpdir, "D:#{bs}")).to be(true)
        expect(executed_cmds.join("\n")).to include('B64DEC.COM')
        expect(executed_cmds.join("\n")).to include("D:#{bs}sub")
      end
    end

    it 'downloads a file with Base64 markers and without markers' do
      Dir.mktmpdir do |tmpdir|
        dest1 = File.join(tmpdir, 'out1.bin')
        allow(communicator).to receive(:execute) do |_cmd, _opts, &blk|
          blk.call(:stdout, "===B64_START===
#{Base64.strict_encode64('DOS_BINARY_DATA')}
===B64_END===
")
          0
        end
        expect(communicator.download('/vagrant/OUT1.BIN', dest1)).to be(true)
        expect(File.binread(dest1)).to eq('DOS_BINARY_DATA')

        dest2 = File.join(tmpdir, 'out2.txt')
        allow(communicator).to receive(:execute) do |_cmd, _opts, &blk|
          blk.call(:stdout, "PLAIN_TEXT_OUTPUT
")
          0
        end
        expect(communicator.download("D:#{bs}OUT2.TXT", dest2)).to be(true)
        expect(File.read(dest2)).to eq('PLAIN_TEXT_OUTPUT')
      end
    end
  end

  describe '#strip_telnet_iac' do
    it 'strips IAC DO/WILL/WONT triplets with and without socket, replies WONT/DONT, and unescapes double IAC' do
      reply_io = StringIO.new
      raw = [
        described_class::IAC, described_class::DO_OPT, 1,
        described_class::IAC, described_class::WILL, 3,
        described_class::IAC, described_class::WONT, 5,
        described_class::IAC, described_class::IAC
      ].pack('C*') + 'HELLO' + [described_class::IAC].pack('C*')

      cleaned = communicator.strip_telnet_iac(raw, reply_io)
      expect(cleaned.bytes).to include(255)
      expect(cleaned).to end_with('HELLO')
      expect(reply_io.string.bytes).to eq([
        described_class::IAC, described_class::WONT, 1,
        described_class::IAC, described_class::DONT, 3
      ])

      cleaned_no_sock = communicator.strip_telnet_iac(raw, nil)
      expect(cleaned_no_sock).to end_with('HELLO')
    end

    it 'handles multi-chunk socket reads and reset! when socket is nil' do
      expect(communicator.reset!).to be_nil
      allow(mock_socket).to receive(:write)
      chunks = [
        "Pre-start line#{crlf}===START_ABCD1234===#{crlf}",
        "Output line#{crlf}===EXIT_ABCD1234:0===#{crlf}Post-exit line#{crlf}"
      ]
      allow(mock_socket).to receive(:readpartial) { chunks.shift || raise(EOFError) }
      expect(communicator.execute('VER')).to eq(0)
    end
  end
end
