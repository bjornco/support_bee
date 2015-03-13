require 'spec_helper'

describe SupportBee::Client do
  before do
    @client = SupportBee::Client.new(company: 'shopstick', auth_token: 'Qc1QJ3q2vCQij8GwNYS')
  end

  it "can create a ticket" do
    @client.create_ticket({
      subject: "Creating ticket from Ruby",
      requester_email: "danielcgilbert@gmail.com",
      content: {
        text: "Foo bar baz",
        html: "<strong>Foo bar baz</strong>"
      }
    })
  end
end
