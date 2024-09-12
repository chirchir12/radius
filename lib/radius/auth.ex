defmodule Radius.Auth do
  import Ecto.Query, warn: false
  alias Radius.Repo
  alias Radius.Auth.{Radcheck}

  def clear_session() do
    now = DateTime.utc_now()
    query = from(r in Radcheck, where: r.expire_on < ^now)
    Repo.delete_all(query)
  end
end
