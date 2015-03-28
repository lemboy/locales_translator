Locales Translator
===================

Translator for RoR locale YML files with machine translation ability (Yandex API).


Setup
-------

Add translate API Key to *config/secrets.yml* file 

```ruby
development:
  yandex_api_key: trnsl.1.1._xxx_

production:
  yandex_api_key: <%= ENV["YANDEX_API_KEY"] %>
```