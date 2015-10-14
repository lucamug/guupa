# encoding: UTF-8
class Website
  attr_accessor :id

  def name
    if self.id == 0
      return "GuuPa"
    elsif self.id == 1
      return "World Heritage"
    elsif self.id == 2
      return "Ideas"
    end
  end  

  def domain
    if self.id == 0
      return nil
    elsif self.id == 1
      return "world-heritage"
    elsif self.id == 2
      return "ideas"
    end
  end  

  def translated
    if self.id == 2
      if I18n.locale == :it
        return "Idee"
      elsif I18n.locale == :ja
        return "アイデア"
      else
        return "Ideas"
      end
    elsif self.id == 1
      if I18n.locale == :it
        return "Patrimonio Mondiale"
      elsif I18n.locale == :ja
        return "世界遺産"
      else
        return "World Heritage"
      end
    else
      return "Home"
    end
  end

  def self.create_from_url(name)
    if name =~ /ideas|ideee|idea|アイデア/i
      return self.new(:id => 2)
    elsif name =~ /Patrimonio Mondiale|World Heritage|idea|世界遺産/i
      return self.new(:id => 1)
    else
      return self.new(:id => 0)
    end
  end
    
  def build_title(p = {})
    p[:current_area_obj] ||= Tag.my_find_by_id(1)
    area_translated = p[:current_area_obj].translated
    title = ""
    connection = ""
    area = area_translated
    flag = ""
    
    article = ""
    if I18n.locale == :en
      if p[:current_area_obj].level == 0
        article = "the" # the World
      end
    elsif I18n.locale == :it
      if p[:current_area_obj].level == 0
        article = "il" # Il Mondo
      elsif p[:current_area_obj].level == 2
        if area_translated =~ /^[aiueo]/i
          article = "l'" # l'Inghilterra, l'Egitto
        elsif area_translated =~ /a$/i
          article = "la" # la Francia, la Spagna
        else
          article = "il" # il Portogallo, il Giappone
        end            
      elsif p[:current_area_obj].level == 3
        if area_translated =~ /marche/i
          article = "le" # le Marche
        elsif area_translated =~ /^[aiueo]/i
          article = "l'" # l'Emilia-Romagna, l'Umbria, l'Abruzzo
        elsif area_translated =~ /friuli/i
          article = "il" # il Friuli-Venezia Giulia	 
        elsif area_translated =~ /a$/i
          article = "la" # le Toscana...
        else
          article = "il" # il Piemonte...
        end
      elsif p[:current_area_obj].level == 4
        article = "la" # la Provincia di...
      end
    end

    if self.id == 1
      title      = "World Heritage"
      title_html = "<span class='capital'>W</span>orld <span class='capital'>H</span>eritage"
      if I18n.locale == :it
        title      = "Patrimonio Mondiale"
        title_html = "<span class='capital'>P</span>atrimonio <span class='capital'>M</span>ondiale"
      end
      connection = "-"
    elsif self.id == 2
      if I18n.locale == :it
        title           = "Idee"
        title_html      = "<span class='capital'>I</span>dee"
        connection      = "per #{article}"
        connection_html = "<span class='connection'>per #{article}</span>"
      elsif I18n.locale == :ja
        title           = "アイデア"
        title_html      = "<span class='capital'>ア</span>イデア"
        connection      = "のための"
        connection_html = "<span class='connection'>のための</span>"
      else
        title           = "Ideas"
        title_html      = "<span class='capital'>I</span>deas"
        connection      = "for #{article}"
        connection_html = "<span class='connection'>for #{article}</span>"
      end
    end
    if p[:current_area_obj].level.to_i == 2
      flag = "<div class = 'flag #{Util.from_country_to_two_letter_code(p[:current_area_obj].clean_name)}'>"
    end  
    # h make sure that the html is escaped, html_safe, make the new tag working...
    # area_translated = h(p[:current_area_obj].translated).gsub(/([A-Z])/){|n| "<span class='capital'>#{n}</span>"}
    area_translated = Tag.name_for_display(p[:current_area_obj].translated)
    area_translated_html = (area_translated).gsub(/([A-Z])/){|n| "<span class='capital'>#{n}</span>"}

    inside = ""
    if p[:current_area_obj].level == 0
      if I18n.locale == :it
        inside = "nel" # "nel Mondo"
      else
        inside = "in the" # "in the World"
      end
    else
      if I18n.locale == :it
        if p[:current_area_obj].level == 5
          inside = "a" # "a Firenze" "a Scandicci"
        else
          inside = "in" # "in Toscana" "in Italia"
        end
      else
        inside = "in" # "in Japan" "in Florence"
      end
    end
        
    if I18n.locale == :ja
      return ["#{area_translated_html}#{connection_html}#{title_html}".html_safe, "#{area_translated}#{connection}#{title}" + " - Guupa", inside]
    else
      return ["#{title_html} #{connection_html} #{area_translated_html}".html_safe, "#{title} #{connection} #{area_translated}" + " - Guupa", inside]
    end
  end
end
