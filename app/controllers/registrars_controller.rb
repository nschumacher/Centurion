class RegistrarsController < ApplicationController
  before_action :set_registrar, only: [:show, :edit, :update, :destroy]

  # GET /registrars
  # GET /registrars.json
  def index
    @registrars = Registrar.all
  end

  # GET /registrars/1
  # GET /registrars/1.json
  def show
  end

  # GET /registrars/new
  def new
    @registrar = Registrar.new
  end

  # GET /registrars/1/edit
  def edit
  end

  # POST /registrars
  # POST /registrars.json
  def create
    @registrar = Registrar.new(registrar_params)

    respond_to do |format|
      if @registrar.save
        format.html { redirect_to @registrar, notice: 'Registrar was successfully created.' }
        format.json { render :show, status: :created, location: @registrar }
      else
        format.html { render :new }
        format.json { render json: @registrar.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /registrars/1
  # PATCH/PUT /registrars/1.json
  def update
    respond_to do |format|
      if @registrar.update(registrar_params)
        format.html { redirect_to @registrar, notice: 'Registrar was successfully updated.' }
        format.json { render :show, status: :ok, location: @registrar }
      else
        format.html { render :edit }
        format.json { render json: @registrar.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /registrars/1
  # DELETE /registrars/1.json
  def destroy
    @registrar.destroy
    respond_to do |format|
      format.html { redirect_to registrars_url, notice: 'Registrar was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_registrar
      @registrar = Registrar.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def registrar_params
      params.require(:registrar).permit(:name, :attackID)
    end
end
