require 'spec_helper'

describe SupportBee do
  before do
    SupportBee.configure do |config|
      config.company = 'gobiasindustries'
      config.auth_token = 'abc123'
    end
  end

  describe "creating a ticket" do
    context "when successful" do
      it "returns a formatted ticket" do
        stub_request(:post, "https://gobiasindustries.supportbee.com/tickets")
          .to_return(status: 201, body: SupportBee::Stubs["ticket"])

        ticket = SupportBee.create_ticket({
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


    context "when validation fails" do
      it "raises SupportBee::BadRequest" do
        stub_request(:post, "https://gobiasindustries.supportbee.com/tickets")
          .to_return(status: 400, body: <<-RESP
            {
              "error": "Validation failed: Requester can't be blank, Requester can't be blank, Requester email can't be blank, Requester email email is invalid"
            }
          RESP
        )

        # without required `requester_email` field
        ticket = {
          subject: "Where are my hard-boiled eggs?",
          requester_name: "Tobias Funke",
          content: {
            text: "My eggs are no longer in the fridge."
          }
        }

        expect { SupportBee.create_ticket(ticket) }.to raise_error(SupportBee::BadRequest)
      end
    end
  end

  describe "fetching a ticket" do
    context "when successful" do
      it "returns a formatted ticket" do
        stub_request(:get, "https://gobiasindustries.supportbee.com/tickets/4784806")
          .with(query: { auth_token: "abc123" })
          .to_return(status: 200, body: SupportBee::Stubs["ticket"])

        ticket = SupportBee.ticket(4784806)

        expect(ticket.id).to eql(4784806)
        expect(ticket.subject).to eql("Where are my hard-boiled eggs?")
        expect(ticket.requester.name).to eql("Tobias Funke")
        expect(ticket.requester.email).to eql("tobiasfunke@example.com")
        expect(ticket.content.text).to eql("My eggs are no longer in the fridge.")
        expect(ticket.content.html).to eql("My eggs are no longer in the fridge.")
      end
    end

    context "when ticket doesn't exit" do
      it "raises SupportBee::NotFound" do
        stub_request(:get, "https://gobiasindustries.supportbee.com/tickets/4784985")
          .with(query: { auth_token: "abc123" })
          .to_return(status: 404, body: <<-RESP
            {"error":"Couldn't find Ticket with id=4784985 [WHERE \"tickets\".\"company_id\" = 5]"}
          RESP
          )

        expect { SupportBee.ticket(4784985) }.to raise_error(SupportBee::NotFound)
      end
    end
  end

  describe "label requests" do
    context "when successful" do
      it "can create a label" do
        stub_request(:post, "https://gobiasindustries.supportbee.com/tickets/4784985/labels/important")
          .with(query: { auth_token: "abc123" })
          .to_return(status: 201, body: SupportBee::Stubs["label"])

        label = SupportBee.add_label(4784985, "important")

        expect(label.id).to eql(9839577)
        expect(label.label).to eql("important")
        expect(label.ticket).to eql(4784985)
      end
    end

    context "when label doesn't exist" do
      it "raises SupportBee::NotFound" do
        stub_request(:post, "https://gobiasindustries.supportbee.com/tickets/4784985/labels/non-existent-label")
          .with(query: { auth_token: "abc123" })
          .to_return(status: 404)

        expect { SupportBee.add_label(4784985, "non-existent-label") }.to raise_error(SupportBee::NotFound)
      end
    end
  end
end
