defmodule Radius.Diralink.Auth do
  use Joken.Config
  import Radius.Helper

  # Define a custom token configuration
  def token_config do
    default_claims(skip: [:aud, :iss, :jti])
    |> add_claim("exp", nil, &(&1 > current_time()))
    |> add_claim("iss", fn -> "diralink" end)
    |> add_claim("type", fn -> "access" end)
  end

  def decode_token(jwt_string, is_system) do
    decode(jwt_string, is_system)
  end

  defp decode(jwt_string, is_system)

  defp decode(jwt_string, is_system) when is_system == true do
    signer = get_signer(:system_secret)
    verify_token(jwt_string, signer)
  end

  defp decode(jwt_string, is_system) when is_system == false do
    signer = get_signer(:users_secret)
    verify_token(jwt_string, signer)
  end

  defp verify_token(jwt_string, signer) do
    case verify_and_validate(jwt_string, signer) do
      {:ok, claims} -> {:ok, claims}
      {:error, reason} -> {:error, reason}
    end
  end

  defp get_signer(key_type) do
    :radius
    |> Application.get_env(__MODULE__)
    |> kw_to_map()
    |> Map.get(key_type)
  end
end
