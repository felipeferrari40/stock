defmodule StockWeb.Helpers.EnumHelpers do

  def translate_enum(nil) do
    nil
  end

  def translate_enum(value) when is_atom(value) do
    value = Phoenix.Naming.humanize(value)

    Gettext.dgettext(StockWeb.Gettext, "enums", value)
  end

  def translate_select_enums(module, field) do
    module
    |> Ecto.Enum.values(field)
    |> Enum.map(fn value -> {translate_enum(value), value} end)
  end
end
