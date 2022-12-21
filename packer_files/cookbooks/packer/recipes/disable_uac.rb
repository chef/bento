windows_uac 'Configure UAC' do
  consent_behavior_admins :no_prompt
  prompt_on_secure_desktop false
  enable_uac false
end
