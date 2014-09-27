class Wikipedia
  include Mongoid::Document
  include Mongoid::Timestamps

  field :title
  field :body
  
  embedded_in :point

  def url
    "http://en.wikipedia.org/wiki/#{self.title}"
  end

  def paragraph(n = 1)
    doc = Nokogiri::HTML(self.body)
    doc.css('p').first(n).map(&:to_s).join
  end

  def self.article(title, location)
    url = 'http://en.wikipedia.org/w/api.php'
    params = {
      action: 'query',
      prop: 'coordinates|extracts|images',
      format: 'json',
      colimit: 10,
      exlimit: 10,
      exintro: '',
      imlimit: 10,
      titles: title,
      redirects: ''
    }

    response = RestClient.get(url, { params: params })
    data = JSON.parse(response)
    pages = data['query']['pages'].values

    page = pages.find do |p|
      next unless p.has_key?('coordinates')
      lon, lat = location['coordinates']
      p['coordinates'].any? do |coords|
        (coords['lon'] - lon).abs < 1 && (coords['lat'] - lat).abs < 1
      end
    end

    return nil if page.nil?

    Wikipedia.new(title: page['title'], body: page['extract'])
  end
end
