God.watch do |w|
  w.behavior(:clean_pid_file)
  w.log_cmd = "/usr/bin/logger -p local5.info -t '[ficklehand]'"
  w.keepalive
  w.name = 'ficklehand'
  w.start = "cd #{ENV['APPLICATION_PATH']} && ruby ficklehand.rb"
end
