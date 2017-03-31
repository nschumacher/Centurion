class AttacksController < ApplicationController
  before_action :set_attack, only: [:show, :edit, :update, :destroy]

  # GET /attacks
  # GET /attacks.json
  def index
    @attacks = Attack.paginate(:page => params[:page], :per_page => 14)

    # allow for ajax
    respond_to do |format|
      format.js
      format.html
    end
  end

  # Searching for attacks
  def search
    if params[:search].present?
        @attacks = Attack.search(params[:search], page: params[:page], per_page: 14)
    else
      @attacks = nil
    end

    # allow for ajax
    respond_to do |format|
      format.js
      format.html
    end
  end


  # GET /attacks/1
  # GET /attacks/1.json
  def show
    respond_to do |format|
      format.js
      format.html
    end
  end

  # GET /attacks/new
  def new
    @lastAttackID = Attack.order("created_at").last.attackID
    @lastAttackID[0]=""
    @lastAttackID[0]=""
    @lastAttackID = @lastAttackID.to_i
    @lastAttackID = @lastAttackID + 1
    @lastAttackID.to_s
    @lastAttackID = "AX#{@lastAttackID}"

    @attack = Attack.new
    # @case = Case.new

    # allow for ajax
    respond_to do |format|
      format.js
      format.html
    end
  end

  # GET /attacks/1/edit
  def edit
    # allow for ajax
    respond_to do |format|
      format.js
      format.html
    end
  end

  # POST /attacks
  # POST /attacks.json
  def create
    # replace the "=>" in the params with ':'
    fixed_params = clean_my_params(params[:attack].to_s)

    # Parse the fixed parameters and extract the URL
    attackJson = JSON.parse(fixed_params)
    myURL = attackJson["url"]

    # Check the status
    status = check_url_status(myURL)

    # create the attack with the new status parameter
    @attack = Attack.new(attack_params.merge(:status => status))

    # @case = Case.new(params[:caseID])
    # @case.attackID = @attack.attackID
    # @case.caseID = @attack.caseID
    # @case.target = @attack.target

    respond_to do |format|
      if @attack.save
        format.html { redirect_to @attack, notice: 'Attack was successfully created.' }
        format.json { render :show, status: :created, location: @attack }
      else
        format.html { render :new }
        format.json { render json: @attack.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /attacks/1
  # PATCH/PUT /attacks/1.json
  def update
    respond_to do |format|
      if @attack.update(attack_params)
        format.html { redirect_to @attack, notice: 'Attack was successfully updated.' }
        format.json { render :show, status: :ok, location: @attack }
      else
        format.html { render :edit }
        format.json { render json: @attack.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /attacks/1
  # DELETE /attacks/1.json
  def destroy
    @attack.destroy
    respond_to do |format|
      format.html { redirect_to attacks_url, notice: 'Attack was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def update_status
    # replace the "=>" in the params with ':'
    fixed_params = clean_my_params(params[:attack].to_s)

    # Parse the fixed parameters and extract the URL
    attackJson = JSON.parse(fixed_params)
    myURL = attackJson["url"]

    # Check the status
    status = check_url_status(myURL)

    # update the attack with the new status parameter
    respond_to do |format|
      if @attack.update(attack_params.merge(:status => status))
        format.html { redirect_to @attack, notice: 'Attack was successfully updated.' }
        format.json { render :show, status: :ok, location: @attack }
      else
        format.html { render :edit }
        format.json { render json: @attack.errors, status: :unprocessable_entity }
      end
    end
  end

  # takes in a url as a string and returns the status string
  def check_url_status(url)
    begin
      conn = Faraday.new(:url => url)
      response = conn.get
    rescue Faraday::ConnectionFailed => e
      p "\n\nhere is the URL #{url}\n\n\n"
      return "Unknown. Requires attention."
    else
      statusNum = response.status
      if (statusNum == 200)
        return "Online"
      elsif (statusNum == 403)
        return "Access Forbidden"
      elsif (statusNum == 302)
        status = "Redirecting"
      elsif (statusNum == 301)
        status = "Moved Permanantly"
      else
        return"Status Code: #{statusNum}"
      end
    end
  end

  # clean the parameters...
  # replace the "=>" in the params with ':'
  def clean_my_params(dem_params)
    i = 0
    while i < dem_params.length
      if dem_params[i] == '='
        dem_params[i] = ':'
      elsif dem_params[i] == '>'
        dem_params[i] = ''
      else
      end
      i = i+1
    end
    return dem_params
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_attack
      @attack = Attack.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def attack_params
      params.require(:attack).permit(:status, :caseID, :attackID, :target, :functionality, :url, :registrationDate, :notes)
    end
end
