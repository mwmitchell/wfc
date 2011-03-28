fb_config_file = Rails.root.join('config', 'facebook.yml')

if File.exists? fb_config_file
  facebook_settings = YAML.load_file(fb_config_file)[Rails.env]
elsif
  facebook_settings = {"APP_ID" => ENV["app_id"], "SECRET_KEY" => ENV["secret_key"]}
end

FACEBOOK_APP_ID = facebook_settings['app_id']
FACEBOOK_SECRET_KEY = facebook_settings['secret_key']