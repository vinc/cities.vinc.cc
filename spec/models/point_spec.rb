require 'rails_helper'

RSpec.describe Point do
  let(:point) do
    fields = {
      name: 'San Francisco',
      location: {
        'type' => 'Point',
        'coordinates' => [-122.45, 37.75]
      }
    }
    Fabricate(:point, fields)
  end

  it 'has a title' do
    expect(point.title).to eq('San Francisco')
  end

  it 'has a slug' do
    expect(point.slug).to eq('san-francisco')
  end

  it 'has a wikipedia article in English' do
    I18n.locale = :en

    VCR.use_cassette('wikipedia_en') do
      point.wikipedia!
    end

    expect(point.wikipedia.title).to eq('San Francisco')
    expect(point.wikipedia.paragraph(2)).to match(/the most densely settled/)
  end

  it 'has a wikipedia article in French' do
    I18n.locale = :fr

    VCR.use_cassette('wikipedia_fr') do
      point.wikipedia!
    end

    expect(point.wikipedia.title).to eq('San Francisco')
    expect(point.wikipedia.paragraph(2)).to match(/la plus densément peuplée/)
  end
end
