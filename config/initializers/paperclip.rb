if Rails.env == 'production'
  Paperclip.options[:command_path] = "/home/guupa/local/bin/"
  Paperclip.options[:swallow_stderr] = false
end
