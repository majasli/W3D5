class AttrAccessorObject
  def self.my_attr_accessor(*names)
    names.each do | method_name|
      define_method(method_name) do
        instance_variable_get("@#{method_name}")
      end

      define_method("#{method_name}=") do |value|
        instance_variable_set("@#{method_name}", value)
      end
    end
  end
end


#define_method("pet_name=(name)") do
#...
#end

# # --> getter
# def tag_list
#   @tag_list
# end
#
# # --> setter
# def tag_list=(val)
#   @tag_list = val
# end
