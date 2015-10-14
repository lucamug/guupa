require "yaml"

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
    composed_key = chain[1, (chain.size - 1)].join(".")
    @result[composed_key] ||= {}
    @result[composed_key][chain[0]] = input
  end
end

def parse_language(language)
  # it = YAML::load(File.open("#{Rails.root}/config/locales/it.yml"))
  language = YAML::load(File.open("config/locales/#{language}.yml"))
  parse_hash([], language)
end

parse_language("it")
parse_language("en")

@result.keys.sort.each do |key|
  puts key + " " + @result[key].keys.join(" ")
end
