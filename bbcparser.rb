require 'rubygems'

gem 'hpricot', '>=0.6'
require 'hpricot'

require 'open-uri'
require 'rubyful_soup'
require 'sinatra'
require 'builder'


get "/" do
  erb :default
end


get "/candidate/:id" do
    
      @bbcURL = "http://news.bbc.co.uk/democracylive/hi/representatives/profiles/" + params[:id] + ".stm"
 
      @reply = ""

      puts @bbcURL

      # Grab the document
      open(@bbcURL, "User-Agent" => "Ruby/#{RUBY_VERSION}",
        "From" => "tim@timduckett.co.uk",
        "Referer" => "http://www.adoptioncurve.net") { |f|

          # Save the response body
          @reply = f.read
        }

        # Push reply through Hpricot and dump the results in @doc
        @doc = Hpricot(@reply)

        # OK, let's process this sucker.

            # Grab constituency name
            # /html/body/div/div/div[2]/div[2]/div/div[2]/div/div/div/h1/span[2]/span
            @constituency_array = @doc/"/html/body/div/div/div[2]/div[2]/div/div[2]/div/div/div/h1/span[2]/span"

            @split_array = @constituency_array.innerHTML.split(',')
            @constituency = @split_array[0]

            # Start by grabbing the Name array
            # /html/body/div/div/div[2]/div[2]/div/div[2]/div[3]/div[2]/table[@class="candidate-results"]/tbody/tr/td[@class='a']

            @names_array = @doc/"/html/body/div/div/div[2]/div[2]/div/div[2]/div[3]/div[2]/table[@class='candidate-results']/tbody/tr/td[@class='a']"

            # Grab the Party array
            # /html/body/div/div/div[2]/div[2]/div/div[2]/div[3]/div[2]/table[@class="candidate-results"]/tbody/tr/td[@class='b']

            @parties_array = @doc/"/html/body/div/div/div[2]/div[2]/div/div[2]/div[3]/div[2]/table[@class='candidate-results']/tbody/tr/td[@class='b']"

            # Grab the Votes array
            # /html/body/div/div/div[2]/div[2]/div/div[2]/div[3]/div[2]/table[@class="candidate-results"]/tbody/tr/td[@class='c']

            @votes_array = @doc/"/html/body/div/div/div[2]/div[2]/div/div[2]/div[3]/div[2]/table[@class='candidate-results']/tbody/tr/td[@class='c']"

            # Grab the Percentages array
            # /html/body/div/div/div[2]/div[2]/div/div[2]/div[3]/div[2]/table[@class="candidate-results"]/tbody/tr/td[@class='d']

            @percentages_array = @doc/"/html/body/div/div/div[2]/div[2]/div/div[2]/div[3]/div[2]/table[@class='candidate-results']/tbody/tr/td[@class='d']"

        # OK, now let's assemble the XML content

            # First, how many candidates are we dealing with?
            number = @names_array.count

            # Create a new empty array for the individual candidate details
            @candidate = Array.new
            @candidates = Array.new

            # now iterate across the arrays
            for i in 0..(number -1 ) do

              #Clean up the candidate names

                split_names = @names_array[i].innerHTML.to_s.split(",")

                @first_name = split_names[1].lstrip

                @last_name = split_names[0].lstrip

              #Grab party names

                @party = @parties_array[i].innerHTML.to_s

              #Grab votes and clean up

                @vote = @votes_array[i].innerHTML.to_s.sub(",", "")

              #Grab percentage and clean up

                @percentage = @percentages_array[i].innerHTML.to_s.lstrip

              # Now stuff all of these into an hash

              @candidate = {
                              "first_name" => @first_name,
                              "last_name" => @last_name,
                              "party" => @party,
                              "vote" => @vote,
                              "percentage" => @percentage
                            }
                            
              # And place the hash into the array of candidates
              @candidates[i] = @candidate

            end
              
          erb :body    
              
        end
      
     

