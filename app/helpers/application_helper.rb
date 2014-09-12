module ApplicationHelper
  def json_for_collection(collection)
    ActiveModel::ArraySerializer.new(collection).to_json.html_safe
  end
end
