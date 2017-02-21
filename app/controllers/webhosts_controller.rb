class WebhostsController < ApplicationController
  before_action :set_webhost, only: [:show, :edit, :update, :destroy]

  # GET /webhosts
  # GET /webhosts.json
  def index
    @webhosts = Webhost.all
  end

  # GET /webhosts/1
  # GET /webhosts/1.json
  def show
  end

  # GET /webhosts/new
  def new
    @webhost = Webhost.new
  end

  # GET /webhosts/1/edit
  def edit
  end

  # POST /webhosts
  # POST /webhosts.json
  def create
    @webhost = Webhost.new(webhost_params)

    respond_to do |format|
      if @webhost.save
        format.html { redirect_to @webhost, notice: 'Webhost was successfully created.' }
        format.json { render :show, status: :created, location: @webhost }
      else
        format.html { render :new }
        format.json { render json: @webhost.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /webhosts/1
  # PATCH/PUT /webhosts/1.json
  def update
    respond_to do |format|
      if @webhost.update(webhost_params)
        format.html { redirect_to @webhost, notice: 'Webhost was successfully updated.' }
        format.json { render :show, status: :ok, location: @webhost }
      else
        format.html { render :edit }
        format.json { render json: @webhost.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /webhosts/1
  # DELETE /webhosts/1.json
  def destroy
    @webhost.destroy
    respond_to do |format|
      format.html { redirect_to webhosts_url, notice: 'Webhost was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_webhost
      @webhost = Webhost.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def webhost_params
      params.require(:webhost).permit(:name, :attackID)
    end
end
