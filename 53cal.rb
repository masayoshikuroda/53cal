require 'nokogiri'
require 'net/http'
require 'open-uri'
require 'date'

class GomiCal
    BASE_URL = 'http://www.53cal.jp/areacalendar'

    attr_reader :name, :city_id, :area_id
    attr_reader :date
    attr_reader :info

    def initialize(city_id, area_id)
        @city_id = city_id
        @area_id = area_id

        @url = getUrl()
        ua = 'Mozilla/5.0 (iPhone; CPU iPhone OS 10_3_1 like Mac OS X) AppleWebKit/603.1.30 (KHTML, like Gecko) Version/10.0 Mobile/14E304 Safari/602.1'
        html = open(@url, 'User-Agent' => ua) do |f| f.read end
        page = Nokogiri::HTML.parse(html, nil, 'UTF-8')

	puts page.css(#sm_page h3") puts test
        #@name   = page.css('#sm_page h3').inner_text
	puts @name
        @jmonth = page.css('div.arealist_01 table')[0].css('tr td h3').inner_text
        @date   = Date.today
        @jday   = page.css('div.arealist_01 table')[1].css('tr')[@date.mday - 1].css('td')[0].inner_text
        @info   = page.css('div.arealist_01 table')[1].css('tr')[@date.mday - 1].css('td')[1].inner_text
    end

    def getUrl
        return BASE_URL + "/?city=#{@city_id}&area=#{@area_id}"
    end

    def isBurnableDay
        return @info.include?('可燃ごみ')
    end

    def isPetDay
        return @info.include?('ペットボトル・プラクル')
    end

    def isNonBurnableDay
        return @info.include?('不燃ごみ')
    end

    def isReusableDay
        return @info.include?('資源再生物')
    end
end

if __FILE__ == $0
    city_id = ARGV[0] #1140131
    area_id = ARGV[1] #1140131103
    cal = GomiCal.new(city_id, area_id)

    message = ''
    if cal.isBurnableDay() then
      message += '可燃ゴミの日です。'
    end
    if cal.isPetDay() then
      message += 'プラクル・ペットボトルゴミの日です。'
    end
    if cal.isNonBurnableDay() then
      message += '不燃ゴミの日です。'
    end
    if cal.isReusableDay() then
      message += '資源再生物ゴミの日です。'
    end
    if message.size == 0 then
      message = 'ゴミの収集はありません。'
    end
    
    puts '{'
    puts '  "name": ' + sprintf('"%s"', cal.name) + ','
    puts '  "date": ' + cal.date.strftime('"%Y年%m月%d日"') + ','
    puts '  "message": ' + sprintf('"%s"', message)
    puts '}'

end
