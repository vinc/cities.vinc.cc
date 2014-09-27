class Point
  include Mongoid::Document
  include Mongoid::Slug
  include Location

  field :name, type: String

  embeds_one :wikipedia, class_name: 'Wikipedia'

  slug :title

  def title
    self.name
  end

  def wikipedia!
    # Update cache if needed
    if self.wikipedia.nil? || self.wikipedia.created_at > 1.month.ago
      self.wikipedia = Wikipedia.article(self.title, self.location)
      if self.wikipedia.nil?
        self.wikipedia = Wikipedia.article(self.name, self.location)
      end
    end

    self.wikipedia
  end
end
