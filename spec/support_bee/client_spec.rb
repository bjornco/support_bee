require 'spec_helper'

describe SupportBee::Client do
  before do
    @client = SupportBee::Client.new(company: 'gobiasindustries', auth_token: 'abc123')
  end

  describe "creating a ticket" do
    context "when successful" do
      it "returns a formatted ticket" do
        stub_request(:post, "https://gobiasindustries.supportbee.com/tickets")
          .with(query: { auth_token: "abc123" })
          .to_return(status: 201, body: SupportBee::Stubs["ticket"])

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


    context "when validation fails" do
      it "raises SupportBee::BadRequest" do
        stub_request(:post, "https://gobiasindustries.supportbee.com/tickets")
          .with(query: { auth_token: "abc123" })
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

        expect { @client.create_ticket(ticket) }.to raise_error(SupportBee::BadRequest)
      end
    end
  end

  describe "fetching a ticket" do
    context "when successful" do
      it "returns a formatted ticket" do
        stub_request(:get, "https://gobiasindustries.supportbee.com/tickets/4784806")
          .with(query: { auth_token: "abc123" })
          .to_return(status: 200, body: SupportBee::Stubs["ticket"])

        ticket = @client.ticket(4784806)

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

        expect { @client.ticket(4784985) }.to raise_error(SupportBee::NotFound)
      end
    end
  end

  describe "archiving a ticket" do
    context "when successful" do
      it "archives a ticket" do
        stub_request(:post, "https://gobiasindustries.supportbee.com/tickets/4784806/archive")
          .with(query: { auth_token: "abc123" })
          .to_return(status: 204, body: "")

        expect(@client.archive_ticket(4784806)).to eq(true)
      end
    end

    context "when ticket doesn't exist" do
      it "raises SupportBee::NotFound" do
        stub_request(:post, "https://gobiasindustries.supportbee.com/tickets/4784806/archive")
          .with(query: { auth_token: "abc123" })
          .to_return(status: 404, body: <<-RESP
            {"error":"Couldn't find Ticket with id=4784806 [WHERE \"tickets\".\"company_id\" = 5]"}
          RESP
          )

        expect { @client.archive_ticket(4784806) }.to raise_error(SupportBee::NotFound)
      end
    end
  end

  describe "label requests" do
    context "when successful" do
      it "can create a label" do
        stub_request(:post, "https://gobiasindustries.supportbee.com/tickets/4784985/labels/important")
          .with(query: { auth_token: "abc123" })
          .to_return(status: 201, body: SupportBee::Stubs["label"])

        label = @client.add_label(4784985, "important")

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

        expect { @client.add_label(4784985, "non-existent-label") }.to raise_error(SupportBee::NotFound)
      end
    end
  end
end
