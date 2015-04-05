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

Translate API note
-------

Free version Yandex.Translate API, currently used in this app, has some limitations:
> the volume of the text translated: 1,000,000 characters per day but not more than 10,000,000 per month.

Full [Terms of Use](http://legal.yandex.com/translate_api/?ncrnd=2118).

Testing
-------

Add API Key to *config/secrets.yml* file 
```ruby
test:
  yandex_api_key: trnsl.1.1._xxx_
```
and run
```
bundle exec rspec spec
```
Most likely you will need to adjust the Selenium::WebDriver before. See at the end of *spec/rails_helper.rb* 

Demo
-------

Demo app is [here](http://locales-translator.herokuapp.com/)