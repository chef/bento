registry_key 'HKEY_LOCAL_MACHINE\software\Microsoft\Windows\CurrentVersion\Policies\system' do
  values [{
    name: 'EnableLUA',
    type: :dword,
    data: 0,  }]
end
