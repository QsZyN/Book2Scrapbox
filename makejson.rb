#
# 自炊PDFから分解したjpgをS3とGyazoにアップロードしてScrapboxのJSONを作成
#
require 'json'
require 'gyazo'

jsondata = {}
pages = []
jsondata['pages'] = pages

bookname = ARGV[0]
page_offset = ARGV[1].to_i
jpegfiles = ARGV.grep /\.jpg/i

token = ENV['GYAZO_ACCESS_TOKEN']
gyazo = Gyazo::Client.new access_token: token

(0..jpegfiles.length).each { |i|
  file = jpegfiles[i]

  data = nil
  begin
    data = File.read(file)
  rescue
  end

  if data
    STDERR.puts file

    currentPage = i+1+page_offset
    
    # Gyazoにアップロード
    STDERR.puts "gyazo-cli #{file}"
    res = gyazo.upload imagefile: file, referer_url: "https://scrapbox.io/himitsu-untitled/📃#{bookname}_#{i+1+page_offset}", desc: bookname
    gyazourl = res[:permalink_url]
    STDERR.puts gyazourl
    
    sleep 2

    page = {}
    page['title'] = sprintf("%03d",i)
    lines = []
    page['lines'] = lines
    lines << page['title']
    lines << "[]"
    lines << "[📃#{bookname}_#{sprintf('%03d',currentPage-1)}]📍[📃#{bookname}_#{sprintf('%03d',currentPage+1)}]"
    lines << "[[#{gyazourl}]]"
    lines << line1
    lines << ""

    pages << page

  end
}

puts jsondata.to_json
