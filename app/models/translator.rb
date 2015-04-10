class Translator < ActiveRecord::Base
  class << self
    attr_accessor :autotranslate_dirs
  end

  def self.translate_api_key
    Rails.application.secrets.yandex_api_key
  end

  def self.locales
    LOCALES_LIST
  end

  def self.request_size_ok? request_url
    (request_url.bytesize.to_f/1024)<10 # limit 10kB in Yandex.Translate API
  end

  def self.set_autotranslate_dirs
    url = URI.parse("https://translate.yandex.net/api/v1.5/tr.json/getLangs?key=#{self.translate_api_key}&ui=en")
    request = Net::HTTP::Get.new(url.to_s)
    responce = Net::HTTP.start(url.host, use_ssl: true, verify_mode: OpenSSL::SSL::VERIFY_NONE) {|http|
      http.request(request)
    }
    if responce.code == '200'
      self.autotranslate_dirs = ActiveSupport::JSON.decode(responce.body)['dirs']
    else
      self.autotranslate_dirs = nil
      Rails.logger.debug "YandexApi - #{ActiveSupport::JSON.decode(responce.body)['code']}:#{ActiveSupport::JSON.decode(responce.body)['message']}"
    end
  end

  def self.can_autotranslate? src_code, trgt_code = ""
    !self.autotranslate_dirs.nil? && autotranslate_dirs.find { |e| /#{src_code}-#{trgt_code}/ =~ e }.present?
  end

  def self.lang_name lang_code
    LOCALES_LIST.include?(lang_code) ? LOCALES_LIST[lang_code]['name'] : "No lang name found"
  end

  def self.translate text, dir
    url = URI.parse("https://translate.yandex.net/api/v1.5/tr.json/translate?key=#{self.translate_api_key}&lang=#{dir}&text=#{text}")

    return [ "-1", "Too big for translate API" ] if !self.request_size_ok? url.request_uri

    request = Net::HTTP::Post.new(url.to_s)
    responce = Net::HTTP.start(url.host, use_ssl: true, verify_mode: OpenSSL::SSL::VERIFY_NONE) {|http|
      http.request(request)
    }
    target_text = responce.code == '200' ? ActiveSupport::JSON.decode(responce.body)['text'].join : ActiveSupport::JSON.decode(responce.body)['message']
    [ responce.code, target_text ]
  end

end
