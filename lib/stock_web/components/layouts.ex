defmodule StockWeb.Layouts do
  @moduledoc """
  This module holds different layouts used by your application.

  See the `layouts` directory for all templates available.
  The "root" layout is a skeleton rendered as part of the
  application router. The "app" layout is set as the default
  layout on both `use StockWeb, :controller` and
  `use StockWeb, :live_view`.
  """
  use StockWeb, :html

  embed_templates "layouts/*"
end
