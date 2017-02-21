class IsPsController < ApplicationController
  before_action :set_isp, only: [:show, :edit, :update, :destroy]

  # GET /isps
  # GET /isps.json
  def index
    @isps = Isp.all
  end

  # GET /isps/1
  # GET /isps/1.json
  def show
  end

  # GET /isps/new
  def new
    @isp = Isp.new
  end

  # GET /isps/1/edit
  def edit
  end

  # POST /isps
  # POST /isps.json
  def create
    @isp = Isp.new(isp_params)

    respond_to do |format|
      if @isp.save
        format.html { redirect_to @isp, notice: 'Isp was successfully created.' }
        format.json { render :show, status: :created, location: @isp }
      else
        format.html { render :new }
        format.json { render json: @isp.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /isps/1
  # PATCH/PUT /isps/1.json
  def update
    respond_to do |format|
      if @isp.update(isp_params)
        format.html { redirect_to @isp, notice: 'Isp was successfully updated.' }
        format.json { render :show, status: :ok, location: @isp }
      else
        format.html { render :edit }
        format.json { render json: @isp.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /isps/1
  # DELETE /isps/1.json
  def destroy
    @isp.destroy
    respond_to do |format|
      format.html { redirect_to isps_url, notice: 'Isp was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_isp
      @isp = Isp.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def isp_params
      params.require(:isp).permit(:name, :attackID)
    end
end
