defmodule Radius.Pipeline.Jobs.SessionSchedular do
  alias Oban
  require Logger

  def schedule(customer, in_mins, service_type) do
    config = get_config()
    queue = config[:queues][service_type]
    worker = config[:workers][service_type]
    Logger.info("Scheduling #{service_type} Sessions for customer #{customer}")

    %{customer: customer, prune_after: in_mins * 60, service_type: service_type}
    |> Oban.Job.new(queue: queue, worker: worker, schedule_in: in_mins * 60)
    |> Oban.insert()
  end

  defp get_config() do
    Application.get_env(:radius, __MODULE__)
  end
end
