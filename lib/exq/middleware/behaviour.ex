defmodule Exq.Middleware.Behaviour do
  alias Exq.Middleware.Pipeline

  @callback before_work(%Pipeline{}) :: %Pipeline{}
  @callback after_processed_work(%Pipeline{}) :: %Pipeline{}
  @callback after_failed_work(%Pipeline{}) :: %Pipeline{}
end
