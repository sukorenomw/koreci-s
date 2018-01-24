require "spec_helper"

describe HomeController do
  describe "GET /index" do
    context "user not login" do
      it "will redirect to login page" do
        get :index

        expect(response).to have_http_status :redirect
        expect(response).to redirect_to "users/login"
      end
    end

    context "user login" do
      it "will redirect to dashboard home" do
        get :index

        expect(response).to have_http_status :redirect
        expect(response).to redirect_to "users/login"
      end
    end
  end
end
