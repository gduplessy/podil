require 'digest/md5'
require 'net/http'

module Net
  module HTTPHeader
    def digest_auth(user, password, response)
      response['www-authenticate'] =~ /^(\w+) (.*)/

      params = {}
      Regexp.last_match(2).gsub(/(\w+)="(.*?)"/) { params[Regexp.last_match(1)] = Regexp.last_match(2) }
      params.merge!('cnonce' => Digest::MD5.hexdigest('%x' % (Time.now.to_i + rand(65_535))))

      a_1 = Digest::MD5.hexdigest("#{user}:#{params['realm']}:#{password}")
      a_2 = Digest::MD5.hexdigest("#{@method}:#{@path}")

      request_digest = Digest::MD5.hexdigest(
        [a_1, params['nonce'], '0', params['cnonce'], params['qop'], a_2].join(':')
      )

      header = [
        %(Digest username="#{user}"),
        %(realm="#{params['realm']}"),
        %(qop="#{params['qop']}"),
        %(uri="#{@path}"),
        %(nonce="#{params['nonce']}"),
        %(nc="0"),
        %(cnonce="#{params['cnonce']}"),
        %(opaque="#{params['opaque']}"),
        %(response="#{request_digest}")
      ]

      @header['Authorization'] = header
    end
  end
end
