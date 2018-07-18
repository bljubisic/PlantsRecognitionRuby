require 'uri'
require 'net/https'
require 'json'
require "mechanize"


links = Array.new
@outFiles = Hash.new
totalResults = 0

def downloadImages(file, plantName)
    counter = 0
    Dir.mkdir("Images/#{plantName}") unless File.exists?("Images/#{plantName}")
    File.open(file) do |links|
        links.each do |link|
            puts(link)
            agent = Mechanize.new
            agent.get(link).save "Images/#{plantName}/Image#{counter}.jpg"
            counter = counter + 1
        end
    end
end


def extractLinks(json) 
    items = json["items"]
    if items != nil
        for item in items do
            write(item["link"] + "\n", $plantName)
            #puts(item["link"])
        end
    end
end

def write(line, plantName)
    outFile = @outFiles[plantName]
    outFile = File.open(plantName, 'w') if outFile.nil?
    outFile.write(line)
    #puts 'S ' + @name
   # puts 'S ' + @line
    @outFiles[plantName] = outFile
  end

def processCustomSearchLink(start, plant) 
    params = ""
    q = "#{plant} leaves"
    if(start == 0)
        params = "key=AIzaSyAMgn6w3yDAoUbKnjrssnVWi2TEISp1quM&cx=010127211360517059129:3k2jpgzwx10&q=#{q}&searchType=image&imgType=photo&imgDominantColor=green"
    else
        params = "key=AIzaSyAMgn6w3yDAoUbKnjrssnVWi2TEISp1quM&cx=010127211360517059129:3k2jpgzwx10&q=#{q}&searchType=image&imgType=photo&imgDominantColor=green&count=10&start=#{start}"
    end

    uri = URI.parse("https://www.googleapis.com/customsearch/v1?#{params}")
    #puts("link: #{uri}")
    http= Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    r=http.request(Net::HTTP::Get.new(uri.request_uri))


    json = JSON.parse(r.body)
    if(json["queries"] != nil && json["queries"]["nextPage"] != nil)
        nextStartIndex = json["queries"]["nextPage"][0]["startIndex"]
    end
    extractLinks(json)
    
    if nextStartIndex != nil
        processCustomSearchLink(nextStartIndex, plant)
    end
end

def readFile(file) 
    File.open(file) do |plantsFile|
        plantsFile.each do |plant|
            plantsName = plant.split(",")
            query = plantsName[0]
            $plantName = plantsName[0]
            if plantsName[1] != nil
                query = query + " " + plantsName[1]
            end
            puts($plantName)
            processCustomSearchLink(0, query)
        end
    end
end


#readFile("TreesList.csv")
#puts(links)

#downloadImages("Olea", "Olea")
#downloadImages("Platanus", "Platanus")
#downloadImages("Malus", "Malus")
#downloadImages("Prunus", "Prunus")
#downloadImages("Pyrus", "Pyrus")
downloadImages("Quercus", "Quercus")

