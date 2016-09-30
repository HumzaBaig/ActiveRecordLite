class AttrAccessorObject
  def self.my_attr_accessor(*names)

    names.each do |attribute|

      define_method("#{attribute}=") do |val|
        self.instance_variable_set("@#{attribute}", val)
      end

      define_method("#{attribute}") do
        self.instance_variable_get("@#{attribute}")
      end
      
    end
  end
end
