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

  def check
    @myURL = params[:attack][:url]
    #puts @myURL
    #/^((http[s]?|ftp):\/)?\/?([^:\/\s]+)((\/\w+)*\/)/
    matchData = @myURL.to_s.match(/^((http[s]?|ftp):\/)?\/?([^:\/\s]+)((\/\w+)*\/)/).to_s
    if matchData.length == 0
      respond_to do |format|
      format.js
       format.html { redirect_to new_attack_url, warn: 'Invalid URL' }
      end
    else
      #puts matchData
      urlOnly = matchData.match(/^((http[s]?|ftp):\/)?\/?([^:\/\s]+)/).to_s
      #puts urlOnly
      foldersOnly = matchData[urlOnly.length..matchData.length]
      #puts foldersOnly

      if foldersOnly.length > 1 #there is at least one /../
        foldersOnly[0] = ''
        folders = foldersOnly.split('/')
        #p folders
        #puts folders.length

        @matches = Array.new
        @matches.push(Attack.where("url LIKE ?", "#{urlOnly}%"))
        urlOnly << '/'

        folders.each do |folder|
          urlOnly << folder << '/'
          #puts urlOnly
          @matches.push(Attack.where("url LIKE ?", "#{urlOnly}%"))
        end
        #p @matches
      else # either an empty address or only an empty address + /

      end

      @attack = Attack.new
      respond_to do |format|
          format.js
          format.html
      end
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
    @myURL = params[:url]
    # here is where the code will go to check it's status and grab the whois and such

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
    @attack = Attack.new(attack_params)
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
