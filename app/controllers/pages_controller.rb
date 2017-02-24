class PagesController < ApplicationController
  def about
    # allow for ajax
    respond_to do |format|
      format.js
      format.html
    end
  end

  def contact
  end
end
