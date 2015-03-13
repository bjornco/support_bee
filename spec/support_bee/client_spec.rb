require 'spec_helper'

describe SupportBee::Client do
  before do
    @client = SupportBee::Client.new(company: 'gobiasindustries', auth_token: '4J6DrGyYircgGZGgqzoV')
  end

  it "can create a ticket" do
    stub_request(:post, "https://shopstick.supportbee.com/tickets")
      .to_return(status: 200, body: <<-RESP
        {
          "ticket": {
            "id": 4784806,
            "subject": "Where are my hard-boiled eggs?",
            "replies_count": 0,
            "agent_replies_count": 0,
            "comments_count": 0,
            "last_activity_at": "2015-03-13T20:40:50Z",
            "created_at": "2015-03-13T20:40:50Z",
            "unanswered": true,
            "archived": false,
            "private": false,
            "spam": false,
            "trash": false,
            "summary": "My eggs are no longer in the fridge.",
            "draft": false,
            "source": {
              "web": "shopstick-support@supportbeemail.com"
            },
            "cc": [],
            "labels": [],
            "requester": {
              "id": 1493594,
              "email": "tobiasfunke@example.com",
              "name": "Tobias Funke",
              "agent": false,
              "picture": {
                "thumb20": "https://secure.gravatar.com/avatar/cf3bd47834635a5f769fe3ad16a99d63.png?r=PG&s=20",
                "thumb24": "https://secure.gravatar.com/avatar/cf3bd47834635a5f769fe3ad16a99d63.png?r=PG&s=24",
                "thumb32": "https://secure.gravatar.com/avatar/cf3bd47834635a5f769fe3ad16a99d63.png?r=PG&s=32",
                "thumb48": "https://secure.gravatar.com/avatar/cf3bd47834635a5f769fe3ad16a99d63.png?r=PG&s=48",
                "thumb64": "https://secure.gravatar.com/avatar/cf3bd47834635a5f769fe3ad16a99d63.png?r=PG&s=64",
                "thumb128": "https://secure.gravatar.com/avatar/cf3bd47834635a5f769fe3ad16a99d63.png?r=PG&s=128"
              }
            },
            "content": {
              "html": "My eggs are no longer in the fridge.",
              "text": "My eggs are no longer in the fridge.",
              "truncated": false,
              "attachments": []
            }
          }
        }
      RESP
      )

    ticket = @client.create_ticket({
      subject: "Where are my hard-boiled eggs?",
      requester_name: "Tobias Funke",
      requester_email: "tobiasfunke@example.com",
      content: {
        text: "My eggs are no longer in the fridge."
      }
    })

    expect(ticket.id).to eql(4784806)
    expect(ticket.subject).to eql("Where are my hard-boiled eggs?")
    expect(ticket.requester.name).to eql("Tobias Funke")
    expect(ticket.requester.email).to eql("tobiasfunke@example.com")
    expect(ticket.content.text).to eql("My eggs are no longer in the fridge.")
    expect(ticket.content.html).to eql("My eggs are no longer in the fridge.")
  end
end
