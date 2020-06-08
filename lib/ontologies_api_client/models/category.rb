require_relative "../base"

module LinkedData
  module Client
    module Models
      class Category < LinkedData::Client::Base
        include LinkedData::Client::Collection
        @media_type = "http://data.bioontology.org/metadata/Category"
      end
    end
  end
end
