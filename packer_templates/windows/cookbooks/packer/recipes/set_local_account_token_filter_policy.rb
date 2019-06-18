registry_key 'HKEY_LOCAL_MACHINE\software\Microsoft\Windows\CurrentVersion\Policies\system' do
  values [{
    name: 'LocalAccountTokenFilterPolicy',
    type: :dword,
    data: 1,
  }]
end
