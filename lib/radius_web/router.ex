defmodule RadiusWeb.Router do
  use RadiusWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/v1/api", RadiusWeb do
    pipe_through :api

    # Hotspot Policy routes
    post "/policies/hotspot", PolicyController, :create_hotspot
    put "/policies/hotspot/:plan", PolicyController, :update_hotspot
    delete "/policies/hotspot/:plan", PolicyController, :delete_hotspot

    # Hotspot auth routes
    post "/auth/hotspot/login", AuthController, :hotspot_login
    post "/auth/hotspot/logout/:customer", AuthController, :hotspot_logout

    # PPPoE Policy routes
    post "/policies/ppoe", PolicyController, :create_ppoe
    put "/policies/ppoe/:plan", PolicyController, :update_ppoe
    delete "/policies/ppoe/:plan", PolicyController, :delete_ppoe

    # PPPoE Auth routes
    post "/auth/ppoe/login", AuthController, :ppp_login
    post "/auth/ppoe/logout/:customer", AuthController, :ppp_logout

    # Clear session
    post "/auth/session/extend", AuthController, :extend_session
    post "/auth/session/clear", AuthController, :clear_session

    # NAS routes
    get "/nas", NasController, :index
    get "/nas/list/:company", NasController, :index
    post "/nas", NasController, :create
    get "/nas/:id", NasController, :show
    put "/nas/:id", NasController, :update
    delete "/nas/:id", NasController, :delete
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:radius, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: RadiusWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
