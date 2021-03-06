require 'rails_helper'

describe UrlHelper do
  describe "govuk_url_for" do
    it "should return a fully qualified gov.uk url from the given path" do
      expect(govuk_url_for('/some/path')).to eql 'http://www.dev.gov.uk/some/path'
    end
  end
end
