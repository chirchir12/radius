defmodule RadiusWeb.FallbackController do
  use RadiusWeb, :controller

  # ... existing code ...

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(RadiusWeb.ChangesetJSON)
    |> render("error.json", changeset: changeset)
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(RadiusWeb.ErrorJSON)
    |> render(:"404")
  end

  def call(conn, {:error, :bad_request}) do
    conn
    |> put_status(:bad_request)
    |> put_view(json: RadiusWeb.ErrorJSON)
    |> render(:"400", error: %{message: "Bad Request"})
  end

  def call(conn, {:error, error_message}) when is_atom(error_message) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: RadiusWeb.ErrorJSON)
    |> render(:"422", error: %{message: error_message})
  end

  # ... existing code ...
end
