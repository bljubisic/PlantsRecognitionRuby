require 'uri'
require 'net/https'
require 'json'
links = Array.new
totalResults = 0

def extractLinks(json) 
    items = json["items"]
    for item in items do
        puts(item["link"])
    end
end

def processCustomSearchLink(start) 
    params = ""
    if(start == 0)
        params = "key=AIzaSyAMgn6w3yDAoUbKnjrssnVWi2TEISp1quM&cx=010127211360517059129:3k2jpgzwx10&q=quercus+leaves+closeup&searchType=image&imgType=photo&imgDominantColor=green"
    else
        params = "key=AIzaSyAMgn6w3yDAoUbKnjrssnVWi2TEISp1quM&cx=010127211360517059129:3k2jpgzwx10&q=quercus+leaves+closeup&searchType=image&imgType=photo&imgDominantColor=green&count=10&start=#{start}"
    end

    uri = URI.parse("https://www.googleapis.com/customsearch/v1?#{params}")
    puts("link: #{uri}")
    http= Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    r=http.request(Net::HTTP::Get.new(uri.request_uri))


    json = JSON.parse(r.body)
    if(json["queries"]["nextPage"] != nil)
        nextStartIndex = json["queries"]["nextPage"][0]["startIndex"]
    end
    extractLinks(json)
    
    if nextStartIndex != nil
        processCustomSearchLink(nextStartIndex)
    end
end

processCustomSearchLink(0)
puts(links)


