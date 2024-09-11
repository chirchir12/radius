defmodule RadiusWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, components, channels, and so on.

  This can be used in your application as:

      use RadiusWeb, :controller
      use RadiusWeb, :html

  The definitions below will be executed for every controller,
  component, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define additional modules and import
  those modules here.
  """

  # This module, RadiusWeb, serves as the main configuration point for the web interface of the Radius application.
  # It defines several functions that set up different parts of the web framework:

  # Defines static file paths that Phoenix will serve
  def static_paths, do: ~w(assets fonts images favicon.ico robots.txt)

  # Configures the router with common imports
  def router do
    quote do
      use Phoenix.Router, helpers: false
      import Plug.Conn
      import Phoenix.Controller
    end
  end

  # Sets up Phoenix channels for real-time communication
  def channel do
    quote do
      use Phoenix.Channel
    end
  end

  # Configures controllers with necessary imports and settings
  def controller do
    quote do
      use Phoenix.Controller,
        formats: [:html, :json],
        layouts: [html: RadiusWeb.Layouts]

      import Plug.Conn
      import RadiusWeb.Gettext

      unquote(verified_routes())
    end
  end

  # Sets up verified routes for the application
  def verified_routes do
    quote do
      use Phoenix.VerifiedRoutes,
        endpoint: RadiusWeb.Endpoint,
        router: RadiusWeb.Router,
        statics: RadiusWeb.static_paths()
    end
  end

  # This macro allows the use of RadiusWeb functionalities in other modules
  @doc """
  When used, dispatch to the appropriate controller/live_view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end

  # The `__using__` macro is a special Elixir construct that allows this module to be used with `use RadiusWeb, :something`.
  # It will call the appropriate function (router, channel, controller, etc.) based on the atom passed to it.
  # This design allows for a clean and modular setup of different web components in the Radius application.
end
