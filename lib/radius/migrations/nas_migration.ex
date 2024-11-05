defmodule Radius.Migrations.NasMigration do
  @moduledoc """
  this module is used to migrate data from previus database to this
  """
  require Logger

  def run do
    nas_file_name = "nas.csv"
    path = Path.join(["/tmp/radius", nas_file_name])

    count =
      path
      |> File.stream!()
      |> CSV.decode(headers: true, field_transform: &String.trim/1)
      |> Enum.reduce(0, fn row, acc ->
        case transform(row) do
          {:ok, _} -> acc + 1
          _ -> acc
        end
      end)

    Logger.info("inserted #{count} Rows!!")
    {:ok, count}
  end

  defp transform({:ok, row}) do
    %{
      id: String.to_integer(row["id"]),
      nasname: if(row["nasname"] == "NULL", do: nil, else: row["nasname"]),
      shortname: if(row["shortname"] == "NULL", do: nil, else: row["shortname"]),
      type: if(row["type"] == "NULL", do: nil, else: row["type"]),
      ports: if(row["ports"] == "NULL", do: nil, else: row["ports"]),
      secret: if(row["secret"] == "NULL", do: nil, else: row["secret"]),
      server: if(row["server"] == "NULL", do: nil, else: row["server"]),
      community: if(row["community"] == "NULL", do: nil, else: row["community"]),
      description: if(row["description"] == "NULL", do: nil, else: row["description"]),
      company_id: if(row["company_id"] == "NULL", do: nil, else: row["company_id"]),
      uuid: row["uuid"]
    }
    |> Radius.Nas.create_router()
  end
end
