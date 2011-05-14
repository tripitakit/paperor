class HomeController < ApplicationController
  
  def index
    @countries = Country.find(:all, :order => "total_papers_count DESC, name ASC")
  end
  
  def results
   
    countries = Country.all
    countries.delete("_unknown_")
    
    @papers = Hash.new  
    @query = params[:query]
    
    if @query != ""
      @reldate = if params[:reldate] != ""
                      params[:reldate].to_i
                 else  
                  30
                 end

      retmax = if params[:retmax] != ""
                    params[:retmax].to_i
               else
                  100
               end

      ncbi = Bio::NCBI::REST.new
      Bio::NCBI.default_email = "test@pmcount.net"            
      options = { "db" => "pubmed", 
                  "rettype" => "medline", 
                  "retmax" => retmax, 
                  "reldate" => @reldate }

      # retrieve a list of pumbed ids
      pmids = ncbi.esearch(@query, options)

      # efetch PubMed and parse xml of retrieved ids
      efetch = Bio::NCBI::REST::EFetch.pubmed(pmids, "xml")
      entries = Hpricot.parse(efetch)

      # search for origin of the paper as country names in affiliation tag
      (entries/:pubmedarticle).each do |pubmed_article|

        has_origin = false
        pmid = (pubmed_article/:pmid).innerHTML
        title = (pubmed_article/:articletitle).innerHTML
        affiliation = (pubmed_article/:affiliation).innerHTML
        
        paper = Paper.new(pmid, title, affiliation)

        countries.each do |country|
          if affiliation.include? country.name
            if @papers[country.name]
              @papers[country.name] << paper
            else
              @papers[country.name] = [paper]
            end
            has_origin = true
            recorded_country = Country.find_by_name(country.name)
            new_total_papers_count = recorded_country.total_papers_count + 1
            recorded_country.update_attributes(:total_papers_count => new_total_papers_count)      
          end
        end
          
        unless has_origin
          if @papers["_unknown_"] 
            @papers["_unknown_"] << paper
          else 
            @papers["_unknown_"] = [paper]
          end  
          
          recorded_country = Country.find_by_name("_unknown_")
          new_total_papers_count = recorded_country.total_papers_count + 1
          recorded_country.update_attributes(:total_papers_count => new_total_papers_count)
        end
        
          
        # some patches to sum USA and United States counters
        if @papers["United States"] && @papers["USA"] 
                  @papers["USA"] += @papers["United States"]
  
                  us = Country.find_by_name("United States")
                  total = us.total_papers_count || 0
                  total += @papers["United States"].count
                  us.update_attributes(:total_papers_count => total)
  
                  Country.find_by_name("United States").update_attributes(:total_papers_count => 0)
                  @papers.delete("United States")
                  
        end  
        
         # some patches to sum USA and United States counters
          if @papers["United Kingdom"] && @papers["Uk."] 
                    @papers["United Kingdom"] += @papers["Uk."]
  
                    uk = Country.find_by_name("United Kingdom")
                    total = uk.total_papers_count || 0
                    total += @papers["United Kingdom"].count
                    uk.update_attributes(:total_papers_count => total)
  
                    Country.find_by_name("Uk.").update_attributes(:total_papers_count => 0)
                    @papers.delete("Uk.")
                    

          end
      end
   
      # sort country's counters desc 
      @countries = @papers.keys.sort { |a,b| @papers[b].count <=> @papers[a].count}
    else
      redirect_to :action => "index"
    end # of if @query..
  end # of results..
  
  
  def countries
    @countries = Country.find(:all, :select => :name)
  end
  
end
