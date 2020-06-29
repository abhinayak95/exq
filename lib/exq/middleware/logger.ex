defmodule Exq.Middleware.Logger do
  @behaviour Exq.Middleware.Behaviour

  alias Exq.Middleware.Pipeline
  import Pipeline
  require Logger

  def before_work(pipeline) do
    # Logger.info("#{log_context(pipeline)} start")
    assign(pipeline, :started_at, DateTime.utc_now())
  end

  def after_processed_work(pipeline) do
    delta = delta(pipeline)

    if delta > 5_000_00 do
      %{assigns: %{job: %{args: args, enqueued_at: enqueued_at}}} = pipeline


      Logger.info("#{log_context(pipeline)} args: #{args |> Enum.join(",")} enqueued_ago: #{time_since_enque_in_ms(enqueued_at)}ms done: #{formatted_diff(delta)}")
    end

    pipeline
  end

  def after_failed_work(pipeline) do
    Logger.info(to_string(pipeline.assigns.error_message))
    Logger.info("#{log_context(pipeline)} fail: #{formatted_diff(delta(pipeline))}")
    pipeline
  end

  defp delta(%Pipeline{assigns: assigns}) do
    now_usecs = DateTime.utc_now() |> DateTime.to_unix(:microsecond)
    started_usecs = assigns.started_at |> DateTime.to_unix(:microsecond)
    now_usecs - started_usecs
  end

  defp time_since_enque_in_ms(enqueued_at) do
    (Exq.Support.Time.unix_seconds() - enqueued_at) * 1_000
  end

  defp log_context(%Pipeline{assigns: assigns}) do
    "#{assigns.worker_module}[#{assigns.job.jid}]"
  end

  defp formatted_diff(diff) when diff > 1000, do: [diff |> div(1000) |> Integer.to_string(), "ms"]
  defp formatted_diff(diff), do: [diff |> Integer.to_string(), "µs"]
end
