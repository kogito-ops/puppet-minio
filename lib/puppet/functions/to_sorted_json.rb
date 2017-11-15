# Take a data structure and output it as sorted JSON
#
# @example how to output pretty JSON
#   # output pretty json to a file
#     file { '/tmp/my.json':
#       ensure  => file,
#       content => to_sorted_json($myhash),
#     }
#
#
require 'json'

Puppet::Functions.create_function(:to_sorted_json) do
  dispatch :to_sorted_json do
    param 'Hash', :arg
  end

  def sorted_generate(obj)
    case obj
    when Integer, Float, TrueClass, FalseClass, NilClass
      return obj.to_json
    when String
      obj.to_json
    when Array
      array_ret = []
      obj.each do |a|
        array_ret.push(sorted_generate(a))
      end
      '[' << array_ret.join(',') << ']'
    when Hash
      ret = []
      obj.keys.sort.each do |k|
        ret.push(k.to_json << ':' << sorted_generate(obj[k]))
      end
      '{' << ret.join(',') << '}'
    else
      raise Exception('Unable to handle object of type <%s>' % obj.class.to_s)
    end
  end

  def to_sorted_json(h)
    sorted_generate(h)
  end
end
