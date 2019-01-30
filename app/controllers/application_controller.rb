class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  # helpers/sessions_helper.rbを読み込み。全体で使えるように。
  include SessionsHelper

  # def hello
  #   render html: "hello, world!"
  # end
end
