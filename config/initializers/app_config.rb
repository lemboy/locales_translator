require 'yaml'
require 'erb'

LOCALES_LIST = YAML.load(ERB.new(File.new(Rails.root.join("config", "locales_list.yml")).read).result)['locales'] || {}