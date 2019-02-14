class UserMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.account_activation.subject
  #
  # def account_activation
  #   @greeting = "Hi"
  #
  #   mail to: "to@example.org"
  # end

  # アカウント有効化リンクをメール送信する
  def account_activation(user)
    @user = user
    mail to: user.email, subject: "Account activation"
  end


  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.password_reset.subject
  #
  # def password_reset
  #   @greeting = "Hi"
  #
  #   mail to: "to@example.org"
  # end

  # パスワード再設定のリンクをメール送信する
  def password_reset(user)
    @user = user
    mail to: user.email, subject: "Password reset"
  end
end
