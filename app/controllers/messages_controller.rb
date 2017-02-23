class MessagesController < ApplicationController
	def new
		@message = Message.new
	end

	def create
		@message = Message.new(message_params)

		if @message.valid?
			MessageMailer.new_message(@message).deliver_now
			redirect_to contact_path, notice: "Thanks for your feedback, we will respond shortly!"
		else
			flash[:alert] = "An error occurred while delivering this message."
			render :new
		end
	end

	private

		def message_params
			params.require(:message).permit(:email,:subject,:content)
		end
end
