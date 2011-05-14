class Paper
  attr_accessor :pmid, :title, :affiliation 
    
  def initialize(pmid, title, affiliation)
    @pmid = pmid
    @title = title
    @affiliation = affiliation
  end
end