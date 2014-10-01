class Wikipedia
  include Mongoid::Document

  field :title, localize: true
  field :body, localize: true
  field :fetched_at, localize: true, type: Time
  
  embedded_in :point

  def url
    "http://#{I18n.locale.to_s}.wikipedia.org/wiki/#{self.title}"
  end

  def paragraph(n = 1)
    doc = Nokogiri::HTML(self.body)
    doc.css('p:not(:empty)').first(n).map(&:to_s).join
  end

  def fetch_article(title, location)
    return true if self.fetched_at || 1.month.ago > 1.month.ago

    url = "http://#{I18n.locale.to_s}.wikipedia.org/w/api.php"
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

    if page.nil?
      false
    else
      self.update(
        title: page['title'],
        body: page['extract'],
        fetched_at: Time.now
      )
    end
  end
end
