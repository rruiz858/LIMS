class OrderMailer < ApplicationMailer
 default from: 'ChemTrack@epa.gov'
 require 'logger'
 include TestEnvironment

  def order_confirmation(order, chemadmin, current_user)
    @order = order
    @user = current_user
    @chemadmin = chemadmin
    @comments = @order.order_comments
    mail(to: chemadmin.email, subject: 'Order has been finalized')
    unless test_environment
    email_logger(@chemadmin.username, @user.username)
    end
  end

  def order_return_mail(order, chemadmin, comment)
    @order = order
    @chemadmin = chemadmin
    @cor = @order.user
    @comment = comment
    mail(to: @cor.email, subject: 'Order has been returned')
    unless test_environment
    email_logger(@cor.username, @chemadmin.username)
    end
  end

  def email_logger(reciever, sender)
    file = File.open('log/email.log', File::WRONLY | File::APPEND | File::CREAT)
    logger = Logger.new(file)
    logger.info("mail was sent to #{reciever} from #{sender} at #{Time.now}")
  end

end
