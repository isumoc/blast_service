guard :bundler do
  watch('Gemfile')
end

guard :foreman, :procfile => 'Procfile.dev' do
  watch( /^blast_app.rb$/ )
  watch( /^lib\/.+\.rb$/ )
  watch( /^lib\/workers\/.+\.rb$/ )
end
