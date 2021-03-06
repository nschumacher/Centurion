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
    @attackMode = "New"
    #puts @myURL
    #/^((http[s]?|ftp):\/)?\/?([^:\/\s]+)((\/\w+)*\/)/
    matchData = @myURL.to_s.match(/(http(s)?:\/\/.)?(www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#?&\/=]*)/).to_s
    if matchData.length == 0
      respond_to do |format|
       format.js
       format.html { redirect_to new_attack_url, warn: 'Invalid URL' }
      end
    else
      #puts matchData'
      matchData << "//"
      urlOnly = matchData.match(/^((http[s]?|ftp):\/)?\/?([^:\/\s]+)/).to_s
      #puts urlOnly
      foldersOnly = matchData[urlOnly.length..matchData.length]
      #puts foldersOnly
      if foldersOnly.length > 1 #there is at least one /../
        foldersOnly[0] = ''
        folders = foldersOnly.split('/')
        #p folders
        #puts folders.lengt
        @matches = Array.new
        results = Attack.where("url LIKE ?", "#{urlOnly}%")
        results.each do |result|
          if !@matches.collect{|match| match.url}.include? result[:url]
            @matches.push(result)
          end
        end
        # @matches.push(Attack.where("url LIKE ?", "#{urlOnly}%"))
        urlOnly << '/'

        folders.each do |folder|
          urlOnly << folder << '/'
          #puts urlOnly
          # @matches.push(Attack.where("url LIKE ?", "#{urlOnly}%"))
          results = Attack.where("url LIKE ?", "#{urlOnly}%")
          results.each do |result|
            if !@matches.collect{|match| match.url}.include? result[:url]
              @matches.push(result)
            end
          end
        #p @matches
        end
      else# either an empty address or only an empty address + /
      end
      @matches.sort!
      @attack = Attack.new
      respond_to do |format|
          #format.js
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
    @myURL = Attack.find(params[:id]).url
    @attackMode = "Editing"
    respond_to do |format|
      # format.js
      format.html
    end
  end

  # POST /attacks
  # POST /attacks.json
  def create
    # replace the "=>" in the params with ':'
    remove_image_params = params[:attack]
    image_param = params[:attack][:image]
    remove_image_params.delete :image
    fixed_params = clean_my_params(remove_image_params.to_s)

    # fixed_params = remove_image_params
    puts "\n\n\n\n==============="
    puts fixed_params.inspect
    # for fixed_params[0..6] do |key,value|
    #   puts "Param #{key}: #{value}\n\n"
    # end
    puts "\n\n\n\n==============="

    # Parse the fixed parameters and extract the URL
    attackJson = JSON.parse(fixed_params)
    myURL = attackJson["url"]

    # removing trailing /
    puts "\n====="
    urlSlash = myURL.match(/^((http[s]?|ftp):\/)?\/?([^:\/\s]+)/).to_s
    puts "urlSlash: " + urlSlash
    myURL = urlSlash
    puts "\n====="

    # add http:// if it isn't there
    if myURL[0..3] == "www."
      tURL = "http://" + myURL
      myURL = tURL
    elsif myURL[0..3] != "http"
      tURL = "http://" + myURL
      myURL = tURL
    else end

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
      rstName = "unknown"
      @allWhois += rstName + " \n"
    else
      if rstName != nil
        @allWhois += "Registrant Name: " + rstName + " \n"
      end
      if rstOrg != nil
        @allWhois += "Registrant Org: " + rstOrg + " \n"
      end
      if rstEmail != nil
        @allWhois += "Registrant Email: " + rstEmail + " \n"
      end
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
        netName = "unknown"
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
        netHandle = "unknown"
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
        orgName = "unknown"
      else
        @allWhois += "OrgName: " + orgName
      end
    end

    # ====== Nameservers ====== #
    begin
      ns = p.nameservers
    rescue
      ns = "unknown"
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

#--------------------------------- Start of creation ----------------------------------------------
    # Create the Registrar
    registrar_name = ""
    if rarName != nil
      registrar_name = rarName
    else
      registrar_name = "Unknown"
    end
    Registrar.create(name: registrar_name, attackID: params[:attack][:attackID])

    # Create the ISP
    isp_name = ""
    if orgName != "unknown"
      isp_name = orgName
    elsif netHandle != "unknown"
      isp_name = netHandle
    elsif netName != "unknown"
      isp_name = netName
    else
      isp_name = "unknown"
    end
    Isp.create(name: isp_name, attackID: params[:attack][:attackID])

    # Create the Webhost(s)
    if ns[0] != "unknown"
      i = 0
      while ns[i] != nil do
        webhost_name = ns[i].to_s
        Webhost.create(name: webhost_name, attackID: params[:attack][:attackID])
        i += 1
      end
    else
      webhost_name = "unknown"
      Webhost.create(name: webhost_name, attackID: params[:attack][:attackID])
    end

    # Create the Registrant
    if rstName != "unknown"
      registrant_name = rstName
      Registrant.create(name: registrant_name, attackID: params[:attack][:attackID])
    else
      registrant_name = "unknown"
      Registrant.create(name: registrant_name, attackID: params[:attack][:attackID])
    end

    # create the attack with the new status parameter
    @attack = Attack.new(attack_params.merge(
      :status => status,
      :domain => @dom,
      :registrationDate => @createdOn,
      :expireryDate => @expiresOn,
      :whois_text => @allWhois,
      :image => image_param
    ))
#--------------------------------- End of creation ----------------------------------------------

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
    @myURL = Attack.find(params[:id]).url
    @attackMode = "Editing"
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
      return "Unknown. Requires attention."
    else
      statusNum = response.status
      puts case statusNum
      when 200
        return "200: Online"
      when 201
        return "201: Created"
      when 204
        return "204: No Content"
      when 301
        return "301: Moved Permanantly"
      when 302
        return "302: Redirecting"
      when 304
        return "304: Not Modified"
      when 400
        return "400: Bad Request"
      when 401
        return "401: Unauthorized"
      when 403
        return "403: Access Forbidden"
      when 404
        return "404: Not Found"
      when 409
        return "409: Conflict"
      when 500
        return "500: Internal Server Error"
      else
        return "Status code: #{statusNum}"
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
      params.require(:attack).permit(:status, :caseID, :attackID, :target, :functionality, :url, :registrationDate,:expireryDate, :notes, :image, :whois_text)
    end
end
