require_relative 'config'
require_relative 'http'

module LinkedData
  module Client
    module Collection
      
      def self.class_for_typed(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        ##
        # Allows for arbitrary find_by methods. For example:
        #   Ontology.find_by_acronym("BRO")
        #   Ontology.find_by_group_and_category("UMLS", "Anatomy")
        def method_missing(meth, *class_for_typeblock)
          if meth.to_s =~ /^find_by_(.+)$/
            find_by($1, *args, &block)
          else
            super
          end
        end
      
        ##
        # Get all top-level links for the API
        def top_level_links
          HTTP.get(LinkedData::Client.settings.rest_url)
        end
      
        ##
        # Return a link given an object (with links) and a media type
        def uri_from_context(object, media_type)
          object.links.each do |type, link|
            return link if link.media_type && link.media_type.downcase.eql?(media_type.downcase)
          end
        end
      
        ##
        # Get the first collection of resources for a given type
        def entry_point(media_type)
          HTTP.get(uri_from_context(top_level_links, media_type), include: @include_attrs)
        end
      
        ##
        # Get all resources from the base collection for a resource
        def all(*args)
          entry_point(@media_type)
        end
        
        ##
        # Find certain resources from the collection by passing a block that filters results
        def where(params = {}, &block)
          if block_given?
            return all.select {|e| block.call(e)}
          else
            raise ArgumentException("Must provide a block to find ontologies")
          end
        end
      
        ##
        # Find a resource by id
        def find(id, params = {})
          found = where do |obj|
            obj.send("@id").eql?(id)
          end
          found.first
        end
      
        ##
        # Find a resource by a combination of attributes
        def find_by(attrs, *args)
          attributes = attrs.split("_and_")
          where do |obj|
            bools = []
            attributes.each_with_index do |attr, index|
              if obj.respond_to?(attr)
                value = obj.send(attr)
                if value.is_a?(Enumerable)
                  bools << value.include?(args[index])
                else
                  bools << (value == args[index])
                end
              end
            end
            bools.all?
          end
        end
      end
    end
  end
end
