module TranslatorsHelper
  def plain_hash(h, level=0, t_id="", t_path="", r={})
    h.each_pair do |key, value|
      id = ( !t_id.empty? ? "#{t_id}_" : t_id ) + "#{key}"
      path = t_path + "[#{key}]"
      r[id] = {key: key, path: path, is_group: true, level: level}
      if h[key].class == Hash
        plain_hash(h[key], level+1, id, path, r)
      else
        r[id][:value] = value
        r[id][:is_group] = false
      end
    end
    return r
  end

  def locales_list_with_mark src_code
    Translator.locales.map {|k,v| [ v["name"]+" (#{k})"+( Translator.can_autotranslate?(src_code, k) ? " * " : ""), k ]}
  end
    
end
