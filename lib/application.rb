# coding: utf-8

require 'sinatra/base'
require 'haml'

module Todo
  class Application < Sinatra::Base

    get '/' do
      haml :index
    end

  end
end
