require 'json'
require 'base64'
require 'net/http'

def plog(str)
  time = Time.now.strftime("[%F %T]")
  puts "#{time} #{str}"
end

def http_post(url, params: {})
  uri = URI(url)
  req = Net::HTTP::Post.new(uri)
  req.set_form_data(params)
  Net::HTTP.start(uri.host, uri.port) { |http| http.request(req) }
end

def parse_qrcode
  url = 'http://cli.im/Api/Browser/deqr'
  ssimg = 'http://www.shadowsocks8.net/images/server03.png'
  res = http_post(url, params: { :data => ssimg })
  str = JSON.parse(res.body)['data']['RawData']
  data = Base64.decode64(str[5..-1])
  plog data
  plog '成功获取SS账号！'
  return data
end

def write_config(str)
  arr = str.split(':')
  method = arr[0]
  passwd = arr[1].split('@')[0]
  server = arr[1].split('@')[1]
  port = arr[2].to_i
  json = JSON.parse(IO.read('gui-config.json'))
  json['configs'][0]['method'] = method
  json['configs'][0]['server'] = server
  json['configs'][0]['server_port'] = port
  json['configs'][0]['password'] = passwd
  json['configs'][0]['remarks'] = 'Japan'
  IO.write('gui-config.json', JSON.pretty_generate(json))
  plog '成功写入配置！'
end

def main
  write_config(parse_qrcode)
end

if __FILE__ == $0
  main
end