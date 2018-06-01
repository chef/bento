batch 'clean SxS' do
  code 'Dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase'
  ignore_failure true
end
