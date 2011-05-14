class Country < ActiveRecord::Base
  
  def self.initialize_counters
    Country.delete_all
    $COUNTRY_NAMES.each do |country_name|
      Country.create!(:name => country_name, :total_papers_count => 0)
    end
  end

  

  

end
