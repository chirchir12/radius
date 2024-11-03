defmodule RadiusWeb.ErrorJSON do
  def render("400.json", %{error: error}) do
    %{errors: error}
  end

  def render("401.json", %{error: error}) do
    %{errors: error}
  end

  def render("422.json", %{error: error}) do
    %{errors: error}
  end

  def render("403.json", %{error: error}) do
    %{errors: error}
  end

  # By default, Phoenix returns the status message from
  # the template name. For example, "404.json" becomes
  # "Not Found".
  def render(template, _assigns) do
    %{errors: %{detail: Phoenix.Controller.status_message_from_template(template)}}
  end
end
