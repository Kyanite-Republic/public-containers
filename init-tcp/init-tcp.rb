require 'socket'

def check(host, port)
  begin
    Socket.tcp(host, port, connect_timeout: 5) {}
    'success'
    rescue Errno::ECONNREFUSED
    abort("Connection Refused")
    rescue Errno::EHOSTUNREACH
    abort("Host Unreachable")
    rescue
    abort("Total Disaster")
  end
end

check(ENV["TCPHOST"], ENV["TCPPORT"])