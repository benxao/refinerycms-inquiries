require "spec_helper"

module Refinery
  describe "inquiries" do
    before(:each) do
      Factory(:refinery_user)

      # load in seeds we use in migration
      Refinery::Inquiries::Engine.load_seed
    end

    context "when valid data" do
      it "is successful" do
        visit new_inquiry_path

        fill_in "Name", :with => "Ugis Ozols"
        fill_in "Email", :with => "ugis.ozols@refinerycms.com"
        fill_in "Message", :with => "Hey, I'm testing!"
        click_button "Send message"

        page.current_path.should == thank_you_inquiries_path
        page.should have_content("Thank You")

        within "#body_content_left" do
          page.should have_content("We've received your inquiry and will get back to you with a response shortly.")
          page.should have_content("Return to the home page")
          page.should have_selector("a[href='/']")
        end

        Refinery::Inquiry.count.should == 1
      end
    end

    context "when invalid data" do
      it "is not successful" do
        visit new_inquiry_path

        click_button "Send message"

        page.current_path.should == new_inquiry_path
        page.should have_content("There were problems with the following fields")
        page.should have_content("Name can't be blank")
        page.should have_content("Email is invalid")
        page.should have_content("Message can't be blank")
        page.should have_no_content("Phone can't be blank")

        Refinery::Inquiry.count.should == 0
      end
    end

    describe "privacy" do
      context "when show contact privacy link setting set to false" do
        it "won't show link" do
          visit new_inquiry_path

          page.should have_no_content("We value your privacy")
          page.should have_no_selector("a[href='/pages/privacy-policy']")
        end
      end

      context "when show contact privacy link setting set to true" do
        before(:each) do
          Refinery::Setting.set(:show_contact_privacy_link, 
                                { :value => true, :scoping => "inquiries" })
        end

        it "shows the link" do
          visit new_inquiry_path

          page.should have_content("We value your privacy")
          page.should have_selector("a[href='/pages/privacy-policy']")
        end
      end
    end
  end
end
