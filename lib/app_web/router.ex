defmodule AppWeb.Router do
  use AppWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end


  scope "/api", AppWeb do
    pipe_through :api
    
    resources "/articles", ArticleController, except: [:new, :edit]
  end
end
