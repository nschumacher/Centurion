class AttacksController < ApplicationController
  before_action :set_attack, only: [:show, :edit, :update, :destroy]

  # GET /attacks
  # GET /attacks.json
  def index
    @attacks = Attack.paginate(:page => params[:page], :per_page => 15)

    # allow for ajax
    respond_to do |format|
      # format.js
      format.html
    end
  end

  # Searching for attacks
  def search
    if params[:search].present?
        @attacks = Attack.search(params[:search], page: params[:page], per_page: 15)
    else
      @attacks = nil
    end

    # allow for ajax
    respond_to do |format|
      # format.js
      format.html
    end
  end


  # GET /attacks/1
  # GET /attacks/1.json
  def show
    respond_to do |format|
      # format.js
      format.html
    end
  end

  def check
    @lastAttackID = Attack.order("created_at").last.attackID
    @lastAttackID[0]=""
    @lastAttackID[0]=""
    @lastAttackID = @lastAttackID.to_i
    @lastAttackID = @lastAttackID + 1
    @lastAttackID.to_s
    @lastAttackID = "AX#{@lastAttackID}"
    @myURL = params[:attack][:url]
    #puts @myURL
    #/^((http[s]?|ftp):\/)?\/?([^:\/\s]+)((\/\w+)*\/)/
    matchData = @myURL.to_s.match(/^((http[s]?|ftp):\/)?\/?([^:\/\s]+)((\/\w+)*\/)/).to_s
    puts "1 matchData: " + matchData

    if matchData.length == 0
      puts "\n==== 1 ==== "
      matchData = @myURL.to_s + "/"
      puts "2 matchData: " + matchData

      matchData = matchData.match(/^((http[s]?|ftp):\/)?\/?([^:\/\s]+)((\/\w+)*\/)/).to_s

      puts "3 matchData: " + matchData

      if matchData.length == 0
        puts "\n==== 2 ==== "
        respond_to do |format|

          # format.js
         format.html { redirect_to new_attack_url, warn: 'Invalid URL' }
        end
      end

    end
      puts "\ns============="
      puts "matchData: " + matchData
      urlOnly = matchData.match(/^((http[s]?|ftp):\/)?\/?([^:\/\s]+)/).to_s
      puts "urlOnly: " + urlOnly
      foldersOnly = matchData[urlOnly.length..matchData.length]
      puts "folderOnly: " + foldersOnly
      puts "=============\n"

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
          # format.js
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
      # format.js
      format.html
    end
  end

  # GET /attacks/1/edit
  def edit
    # allow for ajax
    respond_to do |format|
      # format.js
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

    # removing trailing /
    puts "\n====="
    urlSlash = myURL.match(/^((http[s]?|ftp):\/)?\/?([^:\/\s]+)/).to_s
    puts "urlSlash: " + urlSlash
    myURL = urlSlash
    puts "\n====="


    if myURL[0..3] == "www."
      tURL = "http://" + myURL
      myURL = tURL
    elsif myURL[0..3] != "http"
      tURL = "http://" + myURL
      myURL = tURL
    else end

    #puts "\n.#{myURL}.\n"

    # Check the status
    status = check_url_status(myURL)


        #### live here ####
     puts "\n====="
     puts "Starting myURL: " + myURL + "\n"

    # check for http and https then check for www
    newURL = myURL

    if newURL[0..4] == "https"
      newURL = newURL[8..-1]
    elsif newURL[0..3] == "http"
      newURL = newURL[7..-1]
    else end

    if newURL[0..3] == "www."
      newURL = newURL[4..-1]
    else end

     puts "====="
     puts "newURL: " + newURL
     puts "====="

    myURL = newURL


    @allWhois = "\n"

    # ------ Domain ------ #
    begin
      mywhois = Whois.whois(myURL)
      p = mywhois.parser
      @dom = p.domain
      @allWhois += "Domain:" + @dom +" \n"
    rescue
      @dom = "\nDomain not retrieved \n"
    else
    end

    # ------ IP ------ #
    begin
      ip = IPSocket::getaddress(myURL)
    rescue
      ip = "Network Whois unreachable :( \n"
      @allWhois += ip
    else
      @allWhois += "IP Address: " + ip + " \n"
    end

    # ------ Domain creation and expiration ------ #
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
      @allWhois += "Created On: "+ @createdOn.to_s + " \n" + "Expires On: " + @expiresOn.to_s + " \n"

    else
      @allWhois += "Created On: "+ @createdOn.to_s + " \n" + "Expires On: " + @expiresOn.to_s + " \n"
      # puts "Creation date: #{@createdOn}"
      # puts "Expiration date: #{@expiresOn}"
    end

    @allWhois += " \n"

    # ------ Registrant ------ #
    begin
      rstStruct = p.registrant_contacts
      rstName = rstStruct[0]['name']
      rstOrg = rstStruct[0]['organization']
      rstEmail = rstStruct[0]['email']
    rescue
      rstName = "Couldn't get registrant info"
      @allWhois += rstName + " \n"
    else
      if rstName != nil
        @allWhois += "Registrant Name: " + rstName + " \n"
      else end
      if rstOrg != nil
        @allWhois += "Registrant Org: " + rstOrg + " \n"
      else end
      if rstEmail != nil
        @allWhois += "Registrant Email: " + rstEmail + " \n"
      else end
      #puts @rstStruct
    end

    @allWhois += " \n"

    # ------ Registrar ------ #
    begin
      rarstruct = p.registrar
      rarName = p.registrar['name']
      rarOrg = p.registrar['organization']
      rarID = p.registrar['id']
    rescue
      rarName = "Couldn't retrieve registrar info"
      @allWhois += "Registrar Name: " + rarName + " \n"
    else
      if rarName != nil
        @allWhois += "Registrar Name: " + rarName + " \n"
      else end
      if rarOrg != nil
        @allWhois += "Registrar Org: " + rarOrg + " \n"
      else end
      if rarID != nil
        @allWhois += "Registrar ID: " + rarID + " \n"
      else end
    end

    @allWhois += " \n"

    # ------ IP ------ #
    # begin
    #   @ip = Resolv.getaddresses(myURL)
    # rescue
    #   @ip = "The IP broke Scottie! \n"
    #   #@allWhois += @ip
    # else
    #   @allWhois += "IP Address: " + @ip + " \n"
    # end


    # --- ISP --- #
    begin
      ccc = Whois::Client.new
      networkWhois = ccc.lookup(ip)

      networkWhois = networkWhois.to_s

      #puts "\n\nNetWhois: " + networkWhois + "\nend\n"

    rescue
      puts "\nCouldn't retrieve Network whois \n"
    else
      ###### NetName ######
      begin
        nni = networkWhois.index(/NetName:/)
        nni = nni+9
        temp = networkWhois[nni..-1]
        nni2 = temp.index(/\n/)
        nni2 = nni2+nni
        netName = networkWhois[nni..nni2]
      rescue
        netName = "NetName not available \n"
      else
        @allWhois += "NetName: " + netName
      end

      ###### NetHandle #######
      begin
        nhi = networkWhois.index(/NetHandle:/)
        nhi = nhi+11
        temp = networkWhois[nhi..-1]
        nhi2 = temp.index(/\n/)
        nhi2 = nhi2 + nhi
        netHandle = networkWhois[nhi..nhi2]
      rescue
        netHandle = "NetHandle not available \n"
      else
        @allWhois += "NetHandle: " + netHandle
      end

      ###### OrgName #######
      begin
        on = networkWhois.index(/OrgName:/)
        on = on+9
        temp = networkWhois[on..-1]
        on2 = temp.index(/\n/)
        on2 = on2 + on
        orgName = networkWhois[on..on2]
      rescue
        orgName = "OrgName not available \n"
      else
        @allWhois += "OrgName: " + orgName
      end
    end

    # ====== Nameservers ====== #
    begin
      ns = p.nameservers
    rescue
      ns = "Unable to retrieve nameserver information \n"
    else
      i = 0
      while ns[i] != nil do
        @allWhois += "Nameserver #{i}: " + ns[i].to_s + "\n"
        i += 1
      end
    end

    puts "\n"
    puts @allWhois
    puts "\n"
    #### end of Whois Retrevial ####

    # create the attack with the new status parameter
    @attack = Attack.new(attack_params.merge(
      :status => status,
      :domain => @dom,
      :registrationDate => @createdOn,
      :expireryDate => @expiresOn,
      :notes => @allWhois
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
    puts "\n\n\n\nwtf: #{attack_params}\n\n\n\n"
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
    #fixed_params = clean_my_params(params[:attack].to_s)

    # Parse the fixed parameters and extract the URL
    #attackJson = JSON.parse(fixed_params)
    @attack = Attack.find_by_id(params[:attack][:id])
    myURL = params[:attack][:url] #attackJson["url"]

    # Check the status
    status = check_url_status(myURL)
    p status
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
      elsif dem_params[i] == '\''
        dem_params[i] = '"'
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
