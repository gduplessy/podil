require 'twitter'

$twitter = Twitter::REST::Client.new do |config|
  config.consumer_key        = "p0uNtjNyvjwlZ5OTUHxMIw"
  config.consumer_secret     = "QB0qvYiRo1kCIKUmIxayagTSrmwAGIZ4NAj9HbfaW8"
  config.access_token        = "138976848-GJCt4Ak9p1skW7glKpwJ91YfYwq7ADx1EcJ2bwVU"
  config.access_token_secret = "s39uHrgrS0e9vIGLK8ZjiVda9yJUE2M3UVsBWBWnhX3rB"
end
