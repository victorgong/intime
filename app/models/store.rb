class Store < ActiveRecord::Base
  belongs_to :company
  belongs_to :region
  has_many :product
  has_many :promotion
  attr_accessible :address, :desc, :gpsalt, :gpslatit, :gpslngit, :latit, :lngit, :name, :status, :telephone
  
     include Tire::Model::Search
  index_name ES_DEFAULT_INDEX
  document_type 'esstores'
end
