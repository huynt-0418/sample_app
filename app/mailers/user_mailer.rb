class UserMailer < ApplicationMailer
  def account_activation user
    @user = user

    mail to: user.email, subject: t("mailer.user_mailer.account_activation.subject")
  end
end
