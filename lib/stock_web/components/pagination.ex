defmodule StockWeb.Components.Pagination do
  alias Plug.Conn.Query
  use StockWeb, :html

  attr :path, :string, required: true

  def pagination(%{meta: meta} = assigns) do
    range = first..last//1 = get_pagination_range(meta.current_page, meta.total_pages)

    query_params =
      ~r/(.*)\?(.*)/
      |> Regex.run(assigns.path, capture: :all_but_first)
      |> case do
        nil -> %{}
        list -> list |> List.last() |> URI.decode_query()
      end

    assigns = assign(assigns, first: first, last: last, range: range, query_params: query_params)

    ~H"""
    <nav>
      <ul class="flex gap-2">
        <.pagination_item
          page={@meta.current_page - 1}
          path={@path}
          current_page={@meta.current_page}
          disabled={@meta.current_page <= 1}
          query_params={@query_params}
        >
          <.icon name="fa-chevron-left" />
        </.pagination_item>

        <.pagination_item
          :if={@first > 1}
          page={1}
          path={@path}
          current_page={@meta.current_page}
          query_params={@query_params}
        />

        <.navigate_item :if={@first > 2}>
          <.icon name="fa-ellipsis" />
        </.navigate_item>

        <.pagination_item
          :for={page <- @range}
          page={page}
          path={@path}
          current_page={@meta.current_page}
          query_params={@query_params}
        />

        <.navigate_item :if={@last < @meta.total_pages - 1}>
          <.icon name="fa-ellipsis" />
        </.navigate_item>

        <.pagination_item
          :if={@last < @meta.total_pages}
          page={@meta.total_pages}
          path={@path}
          current_page={@meta.current_page}
          query_params={@query_params}
        />

        <.pagination_item
          page={@meta.current_page + 1}
          path={@path}
          current_page={@meta.current_page}
          disabled={@meta.current_page >= @meta.total_pages}
          query_params={@query_params}
        >
          <.icon name="fa-chevron-right" />
        </.pagination_item>
      </ul>
    </nav>
    """
  end

  attr :page, :integer, required: true
  attr :current_page, :integer, required: true
  attr :disabled, :boolean, default: false
  attr :path, :string, required: true
  attr :query_params, :map, required: true
  slot :inner_block, required: false

  defp pagination_item(assigns) do
    page = if assigns.disabled, do: assigns.current_page, else: assigns.page

    new_path =
      assigns.query_params
      |> Map.put("page", page)
      |> Query.encode()

    assigns = assign(assigns, path: "?#{new_path}")

    ~H"""
    <.link patch={@path}>
      <.navigate_item active={@page == @current_page}>
        <%= render_slot(@inner_block) || @page %>
      </.navigate_item>
    </.link>
    """
  end

  attr :active, :boolean, default: false
  slot :inner_block, required: true

  defp navigate_item(assigns) do
    ~H"""
    <li class={[
      "w-8 h-8 rounded-lg text-sm font-semibold flex items-center justify-center border cursor-pointer",
      (@active && "font-bold text-white bg-black") ||
        "text-neutral/70 border-transparent hover:bg-neutral/10 hover:border-neutral "
    ]}>
      <%= render_slot(@inner_block) %>
    </li>
    """
  end

  defp get_pagination_range(current_page, total_pages, max_pages \\ 3) do
    # Número de paginas que devem aparecer antes ou depois da página atual
    additional = ceil(max_pages / 2)

    cond do
      total_pages == 0 ->
        1..1

      max_pages >= total_pages ->
        1..total_pages

      current_page + additional > total_pages ->
        (total_pages - max_pages + 1)..total_pages

      true ->
        first = max(current_page - additional + 1, 1)
        last = min(first + max_pages - 1, total_pages)
        first..last
    end
  end
end
