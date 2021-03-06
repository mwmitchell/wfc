fb_config_file = Rails.root.join('config', 'facebook.yml')

if File.exists? fb_config_file
  facebook_settings = YAML.load_file(fb_config_file)[Rails.env]
elsif
  facebook_settings = {"app_id" => ENV["APP_ID"], "secret_key" => ENV["SECRET_KEY"]}
end

FACEBOOK_APP_ID = facebook_settings['app_id']
FACEBOOK_SECRET_KEY = facebook_settings['secret_key']