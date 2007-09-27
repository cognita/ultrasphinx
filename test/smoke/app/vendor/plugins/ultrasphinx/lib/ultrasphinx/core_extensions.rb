
class Array
  def _flatten_once
    self.inject([]) do |set, element| 
      set + Array(element)
    end
  end
end

class Object
  def _metaclass 
    class << self
      self
    end
  end
  
  def _deep_dup
    # Cause Ruby's dup sucks.
    Marshal.load(Marshal.dump(self))
  end
end

class String
  def _to_numeric
    zeroless = self.squeeze(" ").strip.sub(/^0+(\d)/, '\1')
    zeroless.sub!(/(\...*?)0+$/, '\1')
    if zeroless.to_i.to_s == zeroless
      zeroless.to_i
    elsif zeroless.to_f.to_s == zeroless
      zeroless.to_f
    elsif date = Chronic.parse(self)
      date.to_i
    else
      self
    end
  end
end

class Hash
  def _coerce_basic_types
    Hash[*self.map do |key, value|
      [key.to_s,
        if value.respond_to?(:to_i) && value.to_i.to_s == value
          value.to_i
        elsif value == ""
          nil
        else
          value
        end]
      end._flatten_once]
  end
  
  def _to_conf_string(section = nil)
    inner = self.map do |key, value|
      "  #{key} = #{value}"
    end.join("\n")
    section ? "#{section} {\n#{inner}\n}\n" : inner
  end
  
  def _deep_stringify_keys
    Hash[*(self.map do |key, value|
#      puts "#{key.inspect}, #{value.inspect}"
      z = [key.to_s,
        case value
          when Hash
            value._deep_stringify_keys
          when Array
            value.map do |subvalue|
              if subvalue.is_a? Hash or subvalue.is_a? Array
                subvalue._deep_stringify_keys
              else
                subvalue
              end
            end
          else
            value
        end
      ]
#      p z
#      z
    end._flatten_once)]
  end
end
