class MessageMailer < ApplicationMailer
	default from: "Contact us"
	default to: "apptitutordevs@gmail.com"

	def new_message(message)
		@message = message
		mail subject: "Centurion - subject: #{message.subject}"
	end
end