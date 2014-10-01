class Point
  include Mongoid::Document
  include Mongoid::Slug
  include Location

  field :name

  embeds_one :wikipedia, class_name: 'Wikipedia'

  slug :title

  def title
    self.name
  end

  def wikipedia!
    self.wikipedia = Wikipedia.new if self.wikipedia.nil?

    # Update cache if needed
    unless self.wikipedia.fetch_article(self.title, self.location)
      self.wikipedia.fetch_article(self.name, self.location)
    end

    self.wikipedia.fetched_at ? self.wikipedia : nil
  end
end
