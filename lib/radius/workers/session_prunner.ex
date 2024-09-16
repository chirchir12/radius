defmodule Radius.Workers.SessionPrunner do
  use Oban.Worker, queue: :prune_all_expired_sessions, max_attempts: 5, unique: [period: 60]


  @impl Oban.Worker
  def perform(job) do
    IO.inspect(job, label: "JOB_GENERIC")
    :ok
  end

end
