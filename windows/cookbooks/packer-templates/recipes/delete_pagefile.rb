registry_key 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management' do
  values [{
    :name => 'PagingFiles',
    :type => :string,
    :data => ''
  }]
end
