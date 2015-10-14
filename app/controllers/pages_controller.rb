class PagesController < ApplicationController
  skip_authorization_check :only => [:privacy, :help, :cookies_error, :translations]
  #load_and_authorize_resource
  def privacy
  end
  def help
  end
  def cookies_error
  end
  def documentation
  end
  def translations
    @result = {}

    def parse_hash(chain, input)
      if input.class == Hash
        input.keys.each do |key|
          # keys_chain.push(key)
          chain.push(key)
          parse_hash(chain, input[key])
          chain.pop
        end
      else
#        if chain.size == 2
#          composed_key = "aaa." + chain[1, (chain.size - 1)].join(".")
#        else
          composed_key = chain[1, (chain.size - 1)].join(".")
#        end
        @result[composed_key] ||= {}
        @result[composed_key][chain[0]] = input
      end
    end

    def parse_language(language)
      # it = YAML::load(File.open("#{Rails.root}/config/locales/it.yml"))
      language = YAML::load(File.open("#{Rails.root}/config/locales/#{language}.yml"))
      parse_hash([], language)
    end

    parse_language("it")
    parse_language("en")
    parse_language("ja")

  end
#  def guupa
#    items = Tag.find_all_by_level(1)
#    render :guupa, :locals => {:items => items}
#  end
  
  private
end

