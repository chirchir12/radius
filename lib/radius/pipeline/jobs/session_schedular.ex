defmodule Radius.Pipeline.Jobs.SessionSchedular do
  alias Oban
  require Logger

  def schedule(customer, in_mins, service_type) do
    queue = :clear_individual_internet_sessions
    worker = Radius.Pipeline.Workers.SubscriptionWorker
    Logger.info("Scheduling #{service_type} Sessions for customer #{customer}")

    %{customer: customer, prune_after: in_mins * 60, service_type: service_type}
    |> Oban.Job.new(queue: queue, worker: worker, schedule_in: in_mins * 60)
    |> Oban.insert()
  end
end
