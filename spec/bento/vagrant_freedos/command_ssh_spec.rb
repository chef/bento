# frozen_string_literal: true

require 'spec_helper'
require 'bento/vagrant_freedos'

RSpec.describe Bento::VagrantFreedos::CommandSsh do
  let(:communicator) { double('communicator') }
  let(:vm_config) { double('vm_config', communicator: :freedos, guest: :freedos) }
  let(:freedos_cfg) { Bento::VagrantFreedos::Config.new.tap(&:finalize!) }
  let(:config) { double('config', vm: vm_config, freedos: freedos_cfg) }
  let(:machine) { double('machine', config: config, communicate: communicator, data_dir: nil) }

  describe '.freedos_machine?' do
    it 'returns true when communicator or guest is :freedos' do
      expect(described_class.freedos_machine?(machine)).to be(true)
      guest_only_vm = double('vm')
      allow(guest_only_vm).to receive(:respond_to?).with(:communicator).and_return(false)
      allow(guest_only_vm).to receive(:respond_to?).with(:guest).and_return(true)
      allow(guest_only_vm).to receive(:guest).and_return(:freedos)
      expect(described_class.freedos_machine?(double('m', config: double('c', vm: guest_only_vm)))).to be(true)
    end

    it 'returns false for non-FreeDOS machines or nil' do
      linux_vm = double('vm')
      allow(linux_vm).to receive(:respond_to?).with(:communicator).and_return(true)
      allow(linux_vm).to receive(:communicator).and_return(:ssh)
      allow(linux_vm).to receive(:respond_to?).with(:guest).and_return(false)
      linux_machine = double('machine', config: double('cfg', vm: linux_vm))
      expect(described_class.freedos_machine?(linux_machine)).to be(false)
      expect(described_class.freedos_machine?(Object.new)).to be(false)
    end
  end

  describe '#parse_argv' do
    it 'parses -c / --command and -p / --plain flags' do
      cmd = described_class.new(['-p', '-c', 'D:\HELLO16.EXE', 'default'])
      parsed = cmd.parse_argv(cmd.argv)
      expect(parsed[:plain]).to be(true)
      expect(parsed[:command]).to eq('D:\HELLO16.EXE')
    end
  end

  describe '#execute_for_machine and #run_single_command' do
    it 'runs a single command when -c is passed and returns the DOS exit code' do
      Dir.mktmpdir do |tmpdir|
        mach = double('machine', config: config, communicate: communicator, data_dir: tmpdir)
        out = StringIO.new
        allow(communicator).to receive(:execute).with('VER', error_check: false) do |_c, _o, &blk|
          blk.call(:stdout, "FreeDOS 1.3
")
          0
        end

        handler = described_class.new(['-c', 'VER'])
        expect(handler.execute_for_machine(mach, stdout: out)).to eq(0)
        expect(out.string).to eq("FreeDOS 1.3
")
      end
    end

    it 'runs an interactive session when no -c flag is passed' do
      handler = described_class.new([])
      out = StringIO.new
      in_r, in_w = IO.pipe
      in_w.write("VER\n#{described_class::CTRL_RIGHT_BRACKET.chr}")
      in_w.close
      c_sock, s_sock = UNIXSocket.pair
      s_sock.write('C:\\>')

      allow(handler).to receive(:open_interactive_socket).and_return(c_sock)
      expect(handler.execute_for_machine(machine, stdout: out, stdin: in_r)).to eq(0)
      expect(out.string).to include('Connected to FreeDOS')
    ensure
      c_sock&.close
      s_sock&.close
      in_r&.close
    end
  end

  describe '#run_interactive_session and socket opening' do
    it 'pumps interactive bytes, translates LF to CRLF, and disconnects cleanly on Ctrl+] or EOF' do
      client_sock, server_sock = UNIXSocket.pair
      server_sock.write('C:\\>')
      in_r, in_w = IO.pipe
      in_w.write("DIR\n")
      in_w.close

      out = StringIO.new
      handler = described_class.new([])
      expect(handler.run_interactive_session(machine, stdout: out, stdin: in_r, socket: client_sock)).to eq(0)
      expect(out.string).to include('C:\\>')
      expect(server_sock.read_nonblock(64)).to include("DIR\r\n")

      # Test when sock is ready with data and stdin is not ready yet
      c_only, s_only = UNIXSocket.pair
      s_only.write('READY>')
      s_only.close
      r_idle, w_idle = IO.pipe
      expect(handler.send(:pump_interactive_streams, c_only, r_idle, out)).to be_nil

      # Test when sock hits EOF inside pump_interactive_streams (and stdin is not ready)
      c2, s2 = UNIXSocket.pair
      s2.close
      r2, w2 = IO.pipe
      expect(handler.send(:pump_interactive_streams, c2, r2, out)).to be_nil

      # Test when IO.select returns nil or raises IOError
      allow(IO).to receive(:select).and_return(nil)
      expect(handler.send(:pump_interactive_streams, c2, r2, out)).to be_nil
      allow(IO).to receive(:select).and_raise(IOError)
      expect(handler.send(:pump_interactive_streams, c2, r2, out)).to be_nil
    ensure
      client_sock&.close
      server_sock&.close
      in_r&.close
      c_only&.close
      r_idle&.close
      w_idle&.close
      c2&.close
      r2&.close
      w2&.close
    end

    it 'opens TCP or UNIX interactive sockets via open_interactive_socket' do
      handler = described_class.new([])
      fake_sock = StringIO.new
      expect(TCPSocket).to receive(:new).with('127.0.0.1', 2323).and_return(fake_sock)
      expect(handler.send(:open_interactive_socket, machine)).to eq(fake_sock)

      freedos_cfg.transport = :unix_socket
      freedos_cfg.serial_socket = '/tmp/freedos_tty.sock'
      expect(UNIXSocket).to receive(:new).with('/tmp/freedos_tty.sock').and_return(fake_sock)
      expect(handler.send(:open_interactive_socket, machine)).to eq(fake_sock)
    end
  end

  describe '#call (Action Middleware)' do
    it 'intercepts SSHRun and SSHExec for FreeDOS machines' do
      app = double('app')
      middleware = described_class.new(app, {})
      out = StringIO.new

      allow(communicator).to receive(:execute).with('WMAKE', error_check: false).and_return(2)
      action_env = { machine: machine, ssh_run_command: 'WMAKE', ssh_Polyfill_stdout: out }
      expect(middleware.call(action_env)).to eq(2)
      expect(action_env[:ssh_run_exit_status]).to eq(2)

      allow(middleware).to receive(:run_interactive_session).and_return(0)
      interactive_env = { machine: machine, ssh_Polyfill_stdout: out }
      expect(middleware.call(interactive_env)).to eq(0)
    end

    it 'delegates to next middleware app for non-FreeDOS machines or returns 0 when app is nil' do
      app = double('app')
      expect(app).to receive(:call).and_return(:passed_through)
      middleware = described_class.new(app, {})
      expect(middleware.call({ machine: nil })).to eq(:passed_through)

      no_app = described_class.new([], {})
      expect(no_app.call({ machine: nil })).to eq(0)
    end
  end
end
