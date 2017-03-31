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
    #puts "\n.#{myURL}.\n"

    # Check the status
    status = check_url_status(myURL)

    tempURL = myURL[7..-1]

    #### live here ####
    @allWhois = "1\n"

    # -- Domain -- #
    begin
      mywhois = Whois.whois(tempURL)
      p = mywhois.parser
      @dom = p.domain
      @allWhois += "Domain:" + @dom +"\n"
    rescue
      @dom = "\nDomain not retrieved\n"
    else
    end


    # --- Domain creation and expiration --- #
    begin
      @createdOn = p.created_on
      @expiresOn = p.expires_on
      avail = p.available?
      reg = p.registered?


      # if @createdOn == ""
      #   #puts "\n CREATION WAS EMPTY\n"
      #   @createdOn = "NA"
      #   @expiresOn = "NA"
      # elsif @createdOn == nil
      #   @createdOn = "NA"
      #   @expiresOn = "NA"
      # else
      #   puts "\nIf it's not empty... what in it? .#{@createdOn}. "
      # end
    rescue
      #puts "\nDomain creation/expiration dates NA\n"
      @createdOn = "Creation date unavailable"
      @expiresOn = "Expiration date unavailable"
      @allWhois += "Created On: "+ @createdOn.to_s + "\n" + "Expires On: " + @expiresOn.to_s + "\n"

    else
      @allWhois += "Created On: "+ @createdOn.to_s + "\n" + "Expires On: " + @expiresOn.to_s + "\n"
      # puts "Creation date: #{@createdOn}"
      # puts "Expiration date: #{@expiresOn}"
    end

    puts "\n\n"
    puts @allWhois
    puts "\n"

    # --- Registrar --- #
    begin
      rarstruct = p.registrar
      puts rarName = p.registrar['name']
      puts rarOrg = p.registrar['organization']
      puts rarID = p.registrar['id']
    rescue
      rarName = "Couldn't retrieve registrar info"
      @allWhois += "Registrar Name: " + rarName + "\n"
    else
      if rarName != nil
        @allWhois += "Registrar Name: " + rarName + "\n"
      else end
#"\nRegistrar Org: " + rarOrg + "\nRegistrar ID: " + rarID +
        #puts "Rar struct: #{@rarstruct} "
        #puts "Rar name:   #{@rarName} "
        #puts "Rar ID:     #{@rarID} "
        #puts "Rar Org:    #{@rarOrg} "
        #puts "\n"
    end

    puts "\n\n"
    puts @allWhois
    puts "\n"

    # # --- ISP --- #
    # begin
    #   networkWhois = Whois.whois(ip[0])
    #   networkWhois = networkWhois.to_s
    # rescue
    #   puts "Couldn't retrieve Network whois"
    # else
    #   ## NetName ##
    #   nni = networkWhois.index(/NetName:/)
    #   nni = nni+9
    #   temp = networkWhois[nni..-1]
    #   nni2 = temp.index(/\n/)
    #   nni2 = nni2+nni
    #   netName = networkWhois[nni..nni2]
    # end
    # --- IP --- #
    # begin
    #   ip = Resolv.getaddresses(myURL)
    # rescue
    #   puts = "\n\n The IP broke Scottie!\n"
    # else
    # end

    # # --- Registrant --- #
    # begin
    #   rstStruct = p.registrant_contacts
    #   rstName = rstStruct[0]['name']
    #   #rstOrg = rstStruct[0]['organization']
    #   #rstEmail = rstStruct[0]['email']
    # rescue
    #   rstName = "Couldn't get registrant info"
    # else
    #   #puts @rstStruct
    #   #puts "Registrant name: #{@rstName} "
    #   #puts "Registrant Org: #{@rstOrg} "
    #   #puts "Registrant email: #{@rstEmail} "
    #   #puts "\n"
    # end
    #### end of Whois Retrevial ####

    # create the attack with the new status parameter
    @attack = Attack.new(attack_params.merge(
      :status => status,
      :domain => @dom,
      :registrationDate => @createdOn,
      :expireryDate => @expiresOn
    ))

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
      return "Unknown. Requires attention."
    else
      statusNum = response.status
      if (statusNum == 200)
        return "Online"
      elsif (statusNum == 403)
        return "Access Forbidden"
      else
        return"Status code: #{statusNum}"
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
      params.require(:attack).permit(:status, :caseID, :attackID, :target, :functionality, :url, :registrationDate,:expireryDate, :notes)
    end
end
