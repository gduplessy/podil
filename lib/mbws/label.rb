module MBWS
  class Label < Resource
    attr_accessor :name, :type, :disambiguation, :begin, :end, :label_code, :country

    def initialize(hash, options)
      @aliases = nil

      super

      attrs = ['name', 'type', 'disambiguation', 'label-code', 'country']
      attrs.each do |a|
        instance_variable_set("@#{a.gsub('-', '_')}", hash[a])
      end

      if options.key?(:inc)
        options[:inc].map { |i| i.gsub(/-/, '_') }.each do |s|
          send 'parse_' + s, hash unless s.match(/rels/)
        end
      end

      @begin = hash['life-span']['begin'] if hash['life-span']
      @end = hash['life-span']['end'] if hash['life-span']
    end

    def aliases
      return @aliases if @aliases
      label_xml = Request.get("label/#{mid}", inc: 'aliases')
      parse_aliases(label_xml['label'][0])
      @aliases
    end

    private
  end
end
