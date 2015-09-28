require 'gds_api/publishing_api'

class Redirect
  include Mongoid::Document
  include Mongoid::Timestamps

  field :from_path, type: String
  field :to_path, type: String

  belongs_to :short_url_request

  validates :from_path, :to_path, presence: true
  validates :from_path, :to_path, format: { with: /\A\//, message: 'must be specified as a relative path (eg. "/hmrc/tax-returns")' }, allow_blank: true
  validates_uniqueness_of :from_path

  before_save :create_redirect_in_publishing_api

  index({from_path: 1}, {unique: true})

private
  def create_redirect_in_publishing_api
    api_params = {
      "base_path" => from_path,
      "format" => "redirect",
      "publishing_app" => "short-url-manager",
      "update_type" => "major",
      "redirects" => [
        { "path" => from_path, "type" => "exact", "destination" => to_path }
      ]
    }
    publishing_api.put_content_item(from_path, api_params)
  rescue GdsApi::HTTPErrorResponse => e
    Airbrake.notify_or_ignore(e, :params => api_params)
    errors.add(:base, "An error posting to the publishing API prevented this redirect from being created: #{e}")
    false # Do not continue to save
  end

  def publishing_api
    @publishing_api ||= GdsApi::PublishingApi.new(Plek.current.find('publishing-api'))
  end
end
