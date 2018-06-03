execute 'Set high performance power profile' do
  command 'powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c'
end

execute 'Turn off Hibernation' do
  command 'powercfg.exe /hibernate off'
  ignore_failure :quiet # if unsupported on the hardware it errors
end

execute 'Turn off monitor timeout on AC power' do
  command 'powercfg -Change -monitor-timeout-ac 0'
end

execute 'Turn off monitor timeout on DC power' do
  command 'powercfg -Change -monitor-timeout-dc 0'
end
