class Seller < ActiveRecord::Base
  belongs_to :user
  has_and_belongs_to_many :categories
  delegate :address, :to => :user
  
  is_indexed :fields => [
    {:field => :company_name, :facet => true, :sortable => true},
    {:field => 'mission_statement', :sortable => true},
    'created_at', 
    :capitalization, 
    :user_id
  ],
    :concatenate => [
      { :class_name => 'Category',
        :field => 'categories_sellers.category_id',
        :as => 'category_id',
        :association_sql => 'left outer join categories_sellers on categories_sellers.seller_id = sellers.id'
      }
  ],
    :delta => true
  
  def name 
    company_name
  end
  
  def metadata
    "sfdkjl fsdjkl sdfjl fdsjk #{company_name} " * 5
  end  
end
