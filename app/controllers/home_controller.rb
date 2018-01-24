class HomeController < ApplicationController
  def index
    render body: nil, status: :ok
  end
end
