defmodule StockWeb.Components.PasswordField do
  @moduledoc """
  The `StockWeb.Components.PasswordField` module is a Phoenix component designed to render a customizable
  password input field within LiveView applications. It provides a flexible and highly configurable
  way to integrate password inputs with various visual styles, handling for error messages, and
  toggle functionality for showing or hiding password text.

  This module includes built-in support for multiple configuration options, such as color themes,
  border styles, size, and spacing. It also allows users to easily add custom slots to render
  additional content before and after the input field, enhancing the field's usability and appearance.

  Moreover, it handles the common requirements for form input components, including error display,
  label positioning, and visual feedback on user interaction. The module is intended to be integrated
  seamlessly with Phoenix forms and is ideal for applications that require an interactive and
  user-friendly password field.
  """
  use Phoenix.Component
  alias Phoenix.LiveView.JS
  import Phoenix.LiveView.Utils, only: [random_id: 0]

  @colors [
    "white",
    "primary",
    "secondary",
    "dark",
    "success",
    "warning",
    "danger",
    "info",
    "light",
    "misc",
    "dawn",
    "silver"
  ]

  @doc """
  Renders a customizable `password_field` with options for size, color, label, and validation errors.

  It includes support for showing and hiding the password with an icon toggle.
  You can add start and end sections with custom icons or text, and handle validation
  errors with custom messages.

  ## Examples

  ```elixir
  <.password_field
    name="password"
    value=""
    space="small"
    color="danger"
    description="Enter your password"
    label="Password"
    placeholder="Enter your password"
    floating="outer"
    show_password={true}
  >
    <:start_section>
      <.icon name="hero-lock-closed" class="size-4" />
    </:start_section>
    <:end_section>
      <.icon name="hero-eye-slash" class="size-4" />
    </:end_section>
  </.password_field>

  <.password_field name="confirm_password" value="" color="success" show_password={true}/>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"
  attr :color, :string, values: @colors, default: "light", doc: "Determines color theme"
  attr :border, :string, default: "extra_small", doc: "Determines border style"
  attr :rounded, :string, default: "small", doc: "Determines the border radius"
  attr :variant, :string, default: "outline", doc: "Determines the style"
  attr :description, :string, default: nil, doc: "Determines a short description"
  attr :space, :string, default: "medium", doc: "Space between items"

  attr :size, :string,
    default: "extra_large",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :show_password, :boolean, default: false, doc: ""

  attr :ring, :boolean,
    default: true,
    doc:
      "Determines a ring border on focused input, utilities for creating outline rings with box-shadows."

  attr :floating, :string, default: "none", doc: "none, inner, outer"
  attr :error_icon, :string, default: nil, doc: "Icon to be displayed alongside error messages"
  attr :label, :string, default: nil, doc: "Specifies text for the label"

  slot :start_section, required: false, doc: "Renders heex content in start of an element" do
    attr :class, :string, doc: "Custom CSS class for additional styling"
    attr :icon, :string, doc: "Icon displayed alongside of an item"
  end

  slot :end_section, required: false, doc: "Renders heex content in end of an element" do
    attr :class, :string, doc: "Custom CSS class for additional styling"
    attr :icon, :string, doc: "Icon displayed alongside of an item"
  end

  attr :errors, :list, default: [], doc: "List of error messages to be displayed"
  attr :name, :any, doc: "Name of input"
  attr :value, :any, doc: "Value of input"

  attr :field, Phoenix.HTML.FormField, doc: "a form field struct retrieved from the form"

  attr :rest, :global,
    include: ~w(autocomplete disabled form maxlength minlength pattern placeholder
        readonly required size spellcheck inputmode title autofocus),
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  @spec password_field(map()) :: Phoenix.LiveView.Rendered.t()
  def password_field(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []

    assigns
    |> assign(field: nil, id: assigns.id || field.id || random_id())
    |> assign(:errors, Enum.map(errors, &translate_error(&1)))
    |> assign_new(:value, fn -> field.value end)
    |> password_field()
  end

  def password_field(%{floating: floating} = assigns) when floating in ["inner", "outer"] do
    assigns = assign(assigns, field: nil, id: assigns.id || random_id() <> "-password-field")

    ~H"""
    <div class={[
      color_variant(@variant, @color, @floating),
      rounded_size(@rounded),
      border_class(@border),
      size_class(@size),
      space_class(@space),
      @ring && "[&_.password-field-wrapper]:focus-within:ring-[0.03rem]",
      @class
    ]}>
      <div :if={!is_nil(@description)} class="text-xs pb-2">
        <%= @description %>
      </div>
      <div class={[
        "password-field-wrapper transition-all ease-in-out duration-200 w-full flex flex-nowrap",
        @errors != [] && "password-field-error"
      ]}>
        <div
          :if={@start_section}
          class={[
            "flex items-center justify-center shrink-0 ps-2 h-[inherit]",
            @start_section[:class]
          ]}
        >
          <%= render_slot(@start_section) %>
        </div>
        <div class="relative w-full z-[2]">
          <input
            type="password"
            name={@name}
            id={@id}
            value={@value}
            class={[
              "disabled:opacity-80 block w-full z-[2] focus:ring-0 placeholder:text-transparent pb-1 pt-2.5 px-2",
              "text-sm appearance-none bg-transparent border-0 focus:outline-none peer"
            ]}
            {@rest}
          />

          <label
            class={[
              "floating-label px-1 start-1 -z-[1] absolute text-xs duration-300 transform scale-75 origin-[0]",
              variant_label_position(@floating)
            ]}
            for={@id}
          >
            <%= @label %>
          </label>
        </div>

        <div
          :if={@end_section}
          class={["flex items-center justify-center shrink-0 pe-2 h-[inherit]", @end_section[:class]]}
        >
          <%= render_slot(@end_section) %>
        </div>
        <div
          :if={@show_password}
          class={["flex items-center justify-center shrink-0 pe-2 h-[inherit]"]}
        >
          <button phx-click={
            JS.toggle_class("fa-eye-slash")
            |> JS.toggle_attribute({"type", "password", "text"}, to: "##{@id}")
          }>
            <.icon name="fa-eye" class="password-field-icon" />
          </button>
        </div>
      </div>

      <.error :for={msg <- @errors} icon={@error_icon}><%= msg %></.error>
    </div>
    """
  end

  def password_field(assigns) do
    assigns = assign(assigns, field: nil, id: assigns.id || random_id() <> "-password-field")

    ~H"""
    <div class={[
      color_variant(@variant, @color, @floating),
      rounded_size(@rounded),
      border_class(@border),
      size_class(@size),
      space_class(@space),
      @ring && "[&_.password-field-wrapper]:focus-within:ring-[0.03rem]",
      @class
    ]}>
      <div>
        <.label for={@id}><%= @label %></.label>
        <div :if={!is_nil(@description)} class="text-xs">
          <%= @description %>
        </div>
      </div>

      <div class={[
        "password-field-wrapper overflow-hidden transition-all ease-in-out duration-200 flex flex-nowrap",
        @errors != [] && "password-field-error"
      ]}>
        <div
          :if={@start_section}
          class={[
            "flex items-center justify-center shrink-0 ps-2 h-[inherit]",
            @start_section[:class]
          ]}
        >
          <%= render_slot(@start_section) %>
        </div>

        <input
          type="password"
          name={@name}
          id={@id}
          value={@value}
          class={[
            "flex-1 py-1 px-2 text-sm disabled:opacity-80 block w-full appearance-none",
            "bg-transparent border-0 focus:outline-none focus:ring-0"
          ]}
          {@rest}
        />

        <div
          :if={@end_section}
          class={["flex items-center justify-center shrink-0 pe-2 h-[inherit]", @end_section[:class]]}
        >
          <%= render_slot(@end_section) %>
        </div>
        <div
          :if={@show_password}
          class={["flex items-center justify-center shrink-0 pe-2 h-[inherit]", @end_section[:class]]}
        >
          <button phx-click={
            JS.toggle_class("fa-eye-slash")
            |> JS.toggle_attribute({"type", "password", "text"}, to: "##{@id}")
          }>
            <.icon name="fa-eye" class="password-field-icon" />
          </button>
        </div>
      </div>

      <.error :for={msg <- @errors} icon={@error_icon}><%= msg %></.error>
    </div>
    """
  end

  @doc type: :component
  attr :for, :string, default: nil, doc: "Specifies the form which is associated with"
  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"
  slot :inner_block, required: true, doc: "Inner block that renders HEEx content"

  defp label(assigns) do
    ~H"""
    <label for={@for} class={["block text-sm font-semibold leading-6", @class]}>
      <%= render_slot(@inner_block) %>
    </label>
    """
  end

  @doc type: :component
  attr :icon, :string, default: nil, doc: "Icon displayed alongside of an item"
  slot :inner_block, required: true, doc: "Inner block that renders HEEx content"

  defp error(assigns) do
    ~H"""
    <p class="mt-3 flex items-center gap-3 text-sm leading-6 text-rose-700">
      <.icon :if={!is_nil(@icon)} name={@icon} class="shrink-0" />
      <%= render_slot(@inner_block) %>
    </p>
    """
  end

  defp variant_label_position("outer") do
    [
      "-translate-y-4 top-2 origin-[0] peer-focus:px-1 peer-placeholder-shown:scale-100",
      "peer-placeholder-shown:-translate-y-1/2 peer-placeholder-shown:top-1/2 peer-focus:top-2 peer-focus:scale-75 peer-focus:-translate-y-4",
      "rtl:peer-focus:translate-x-1/4 rtl:peer-focus:left-auto"
    ]
  end

  defp variant_label_position("inner") do
    [
      "-translate-y-4 scale-75 top-4 origin-[0] peer-placeholder-shown:scale-100 peer-placeholder-shown:translate-y-0",
      "peer-focus:scale-75 peer-focus:-translate-y-4 rtl:peer-focus:translate-x-1/4 rtl:peer-focus:left-auto"
    ]
  end

  defp size_class("extra_small") do
    "[&_.password-field-wrapper_input]:h-7 [&_.password-field-wrapper_.password-field-icon]:size-3"
  end

  defp size_class("small") do
    "[&_.password-field-wrapper_input]:h-8 [&_.password-field-wrapper_.password-field-icon]:size-3.5"
  end

  defp size_class("medium") do
    "[&_.password-field-wrapper_input]:h-9 [&_.password-field-wrapper_.password-field-icon]:size-4"
  end

  defp size_class("large") do
    "[&_.password-field-wrapper_input]:h-10 [&_.password-field-wrapper_.password-field-icon]:size-5"
  end

  defp size_class("extra_large") do
    "[&_.password-field-wrapper_input]:h-12 [&_.password-field-wrapper_.password-field-icon]:size-6"
  end

  defp size_class(_), do: size_class("medium")

  defp rounded_size("extra_small"), do: "[&_.password-field-wrapper]:rounded-sm"

  defp rounded_size("small"), do: "[&_.password-field-wrapper]:rounded"

  defp rounded_size("medium"), do: "[&_.password-field-wrapper]:rounded-md"

  defp rounded_size("large"), do: "[&_.password-field-wrapper]:rounded-lg"

  defp rounded_size("extra_large"), do: "[&_.password-field-wrapper]:rounded-xl"

  defp rounded_size("full"), do: "[&_.password-field-wrapper]:rounded-full"

  defp rounded_size(_), do: "[&_.password-field-wrapper]:rounded-none"

  defp border_class("none"), do: "[&_.password-field-wrapper]:border-0"
  defp border_class("extra_small"), do: "[&_.password-field-wrapper]:border"
  defp border_class("small"), do: "[&_.password-field-wrapper]:border-2"
  defp border_class("medium"), do: "[&_.password-field-wrapper]:border-[3px]"
  defp border_class("large"), do: "[&_.password-field-wrapper]:border-4"
  defp border_class("extra_large"), do: "[&_.password-field-wrapper]:border-[5px]"
  defp border_class(params) when is_binary(params), do: params
  defp border_class(_), do: border_class("extra_small")

  defp space_class("extra_small"), do: "space-y-1"

  defp space_class("small"), do: "space-y-1.5"

  defp space_class("medium"), do: "space-y-2"

  defp space_class("large"), do: "space-y-2.5"

  defp space_class("extra_large"), do: "space-y-3"

  defp space_class(params) when is_binary(params), do: params

  defp space_class(_), do: space_class("medium")

  defp color_variant("outline", "white", floating) do
    [
      "text-white [&_.password-field-wrapper:not(:has(.password-field-error))]:border-white",
      "[&_.password-field-wrapper.password-field-error]:border-rose-700",
      "[&_.password-field-wrapper>input]:placeholder:text-white focus-within:[&_.password-field-wrapper]:ring-white",
      floating == "outer" && "[&_.password-field-wrapper_.floating-label]:bg-white"
    ]
  end

  defp color_variant("outline", "silver", floating) do
    [
      "text-[#afafaf] [&_.password-field-wrapper:not(:has(.password-field-error))]:border-[#afafaf]",
      "[&_.password-field-wrapper.password-field-error]:border-rose-700",
      "[&_.password-field-wrapper>input]:placeholder:text-[#afafaf] focus-within:[&_.password-field-wrapper]:ring-[#afafaf]",
      floating && "[&_.password-field-wrapper_.floating-label]:bg-white"
    ]
  end

  defp color_variant("outline", "primary", floating) do
    [
      "text-[#2441de] [&_.password-field-wrapper:not(:has(.password-field-error))]:border-[#2441de]",
      "[&_.password-field-wrapper.password-field-error]:border-rose-700",
      "[&_.password-field-wrapper>input]:placeholder:text-[#2441de] focus-within:[&_.password-field-wrapper]:ring-[#2441de]",
      floating && "[&_.password-field-wrapper_.floating-label]:bg-white"
    ]
  end

  defp color_variant("outline", "secondary", floating) do
    [
      "text-[#877C7C] [&_.password-field-wrapper:not(:has(.password-field-error))]:border-[#877C7C]",
      "[&_.password-field-wrapper.password-field-error]:border-rose-700",
      "[&_.password-field-wrapper>input]:placeholder:text-[#877C7Cb] focus-within:[&_.password-field-wrapper]:ring-[#877C7C]",
      floating && "[&_.password-field-wrapper_.floating-label]:bg-white"
    ]
  end

  defp color_variant("outline", "success", floating) do
    [
      "text-[#047857] [&_.password-field-wrapper:not(:has(.password-field-error))]:border-[#047857]",
      "[&_.password-field-wrapper.password-field-error]:border-rose-700",
      "[&_.password-field-wrapper>input]:placeholder:text-[#047857] focus-within:[&_.password-field-wrapper]:ring-[#047857]",
      floating && "[&_.password-field-wrapper_.floating-label]:bg-white"
    ]
  end

  defp color_variant("outline", "warning", floating) do
    [
      "text-[#FF8B08] [&_.password-field-wrapper:not(:has(.password-field-error))]:border-[#FF8B08]",
      "[&_.password-field-wrapper.password-field-error]:border-rose-700",
      "[&_.password-field-wrapper>input]:placeholder:text-[#FF8B08] focus-within:[&_.password-field-wrapper]:ring-[#FF8B08]",
      floating && "[&_.password-field-wrapper_.floating-label]:bg-white"
    ]
  end

  defp color_variant("outline", "danger", floating) do
    [
      "text-[#E73B3B] [&_.password-field-wrapper:not(:has(.password-field-error))]:border-[#E73B3B]",
      "[&_.password-field-wrapper.password-field-error]:border-rose-700",
      "[&_.password-field-wrapper>input]:placeholder:text-[#E73B3B] focus-within:[&_.password-field-wrapper]:ring-[#E73B3B]",
      floating && "[&_.password-field-wrapper_.floating-label]:bg-white"
    ]
  end

  defp color_variant("outline", "info", floating) do
    [
      "text-[#004FC4] [&_.password-field-wrapper:not(:has(.password-field-error))]:border-[#004FC4]",
      "[&_.password-field-wrapper.password-field-error]:border-rose-700",
      "[&_.password-field-wrapper>input]:placeholder:text-[#004FC4] focus-within:[&_.password-field-wrapper]:ring-[#004FC4]",
      floating && "[&_.password-field-wrapper_.floating-label]:bg-white"
    ]
  end

  defp color_variant("outline", "misc", floating) do
    [
      "text-[#52059C] [&_.password-field-wrapper:not(:has(.password-field-error))]:border-[#52059C]",
      "[&_.password-field-wrapper.password-field-error]:border-rose-700",
      "[&_.password-field-wrapper>input]:placeholder:text-[#52059C] focus-within:[&_.password-field-wrapper]:ring-[#52059C]",
      floating && "[&_.password-field-wrapper_.floating-label]:bg-white"
    ]
  end

  defp color_variant("outline", "dawn", floating) do
    [
      "text-[#4D4137] [&_.password-field-wrapper:not(:has(.password-field-error))]:border-[#4D4137]",
      "[&_.password-field-wrapper.password-field-error]:border-rose-700",
      "[&_.password-field-wrapper>input]:placeholder:text-[#4D4137] focus-within:[&_.password-field-wrapper]:ring-[#4D4137]",
      floating && "[&_.password-field-wrapper_.floating-label]:bg-white"
    ]
  end

  defp color_variant("outline", "light", floating) do
    [
      "text-[#707483] [&_.password-field-wrapper:not(:has(.password-field-error))]:border-[#707483]",
      "[&_.password-field-wrapper.password-field-error]:border-rose-700",
      "[&_.password-field-wrapper>input]:placeholder:text-[#707483] focus-within:[&_.password-field-wrapper]:ring-[#707483]",
      floating && "[&_.password-field-wrapper_.floating-label]:bg-white"
    ]
  end

  defp color_variant("outline", "dark", floating) do
    [
      "text-[#1E1E1E] [&_.password-field-wrapper]:text-text-[#1E1E1E] [&_.password-field-wrapper:not(:has(.password-field-error))]:border-[#050404]",
      "[&_.password-field-wrapper.password-field-error]:border-rose-700",
      "[&_.password-field-wrapper>input]:placeholder:text-[#1E1E1E] focus-within:[&_.password-field-wrapper]:ring-[#050404]",
      floating && "[&_.password-field-wrapper_.floating-label]:bg-white"
    ]
  end

  defp color_variant("default", "white", floating) do
    [
      "[&_.password-field-wrapper]:bg-white text-[#3E3E3E] [&_.password-field-wrapper:not(:has(.password-field-error))]:border-[#DADADA]",
      "[&_.password-field-wrapper.password-field-error]:border-rose-700",
      "[&_.password-field-wrapper>input]:placeholder:text-[#3E3E3E] focus-within:[&_.password-field-wrapper]:ring-[#DADADA]",
      floating && "[&_.password-field-wrapper_.floating-label]:bg-white"
    ]
  end

  defp color_variant("default", "primary", floating) do
    [
      "[&_.password-field-wrapper]:bg-[#4363EC] text-[#4363EC] [&_.password-field-wrapper:not(:has(.password-field-error))]:border-[#2441de]",
      "[&_.password-field-wrapper.password-field-error]:border-rose-700 [&_.password-field-wrapper]:text-white",
      "[&_.password-field-wrapper>input]:placeholder:text-white focus-within:[&_.password-field-wrapper]:ring-[#2441de]",
      floating && "[&_.password-field-wrapper_.floating-label]:bg-[#4363EC]"
    ]
  end

  defp color_variant("default", "secondary", floating) do
    [
      "[&_.password-field-wrapper]:bg-[#6B6E7C] text-[#6B6E7C] [&_.password-field-wrapper:not(:has(.password-field-error))]:border-[#877C7C]",
      "[&_.password-field-wrapper.password-field-error]:border-rose-700 [&_.password-field-wrapper]:text-white",
      "[&_.password-field-wrapper>input]:placeholder:text-white focus-within:[&_.password-field-wrapper]:ring-[#877C7C]",
      floating && "[&_.password-field-wrapper_.floating-label]:bg-[#6B6E7C]"
    ]
  end

  defp color_variant("default", "success", floating) do
    [
      "[&_.password-field-wrapper]:bg-[#ECFEF3] text-[#047857] [&_.password-field-wrapper:not(:has(.password-field-error))]:border-[#6EE7B7]",
      "[&_.password-field-wrapper.password-field-error]:border-rose-700",
      "[&_.password-field-wrapper>input]:placeholder:text-[#047857] focus-within:[&_.password-field-wrapper]:ring-[#6EE7B7]",
      floating && "[&_.password-field-wrapper_.floating-label]:bg-[#ECFEF3]"
    ]
  end

  defp color_variant("default", "warning", floating) do
    [
      "[&_.password-field-wrapper]:bg-[#FFF8E6] text-[#FF8B08] [&_.password-field-wrapper:not(:has(.password-field-error))]:border-[#FF8B08]",
      "[&_.password-field-wrapper.password-field-error]:border-rose-700",
      "[&_.password-field-wrapper>input]:placeholder:text-[#FF8B08] focus-within:[&_.password-field-wrapper]:ring-[#FF8B08]",
      floating && "[&_.password-field-wrapper_.floating-label]:bg-[#FFF8E6]"
    ]
  end

  defp color_variant("default", "danger", floating) do
    [
      "[&_.password-field-wrapper]:bg-[#FFE6E6] text-[#E73B3B] [&_.password-field-wrapper:not(:has(.password-field-error))]:border-[#E73B3B]",
      "[&_.password-field-wrapper.password-field-error]:border-rose-700",
      "[&_.password-field-wrapper>input]:placeholder:text-[#E73B3B] focus-within:[&_.password-field-wrapper]:ring-[#E73B3B]",
      floating && "[&_.password-field-wrapper_.floating-label]:bg-[#FFE6E6]"
    ]
  end

  defp color_variant("default", "info", floating) do
    [
      "[&_.password-field-wrapper]:bg-[#E5F0FF] text-[#004FC4] [&_.password-field-wrapper:not(:has(.password-field-error))]:border-[#004FC4]",
      "[&_.password-field-wrapper.password-field-error]:border-rose-700",
      "[&_.password-field-wrapper>input]:placeholder:text-[#004FC4] focus-within:[&_.password-field-wrapper]:ring-[#004FC4]",
      floating && "[&_.password-field-wrapper_.floating-label]:bg-[#E5F0FF]"
    ]
  end

  defp color_variant("default", "misc", floating) do
    [
      "[&_.password-field-wrapper]:bg-[#FFE6FF] text-[#52059C] [&_.password-field-wrapper:not(:has(.password-field-error))]:border-[#52059C]",
      "[&_.password-field-wrapper.password-field-error]:border-rose-700",
      "[&_.password-field-wrapper>input]:placeholder:text-[#52059C] focus-within:[&_.password-field-wrapper]:ring-[#52059C]",
      floating && "[&_.password-field-wrapper_.floating-label]:bg-[#FFE6FF]"
    ]
  end

  defp color_variant("default", "dawn", floating) do
    [
      "[&_.password-field-wrapper]:bg-[#FFECDA] text-[#4D4137] [&_.password-field-wrapper:not(:has(.password-field-error))]:border-[#4D4137]",
      "[&_.password-field-wrapper.password-field-error]:border-rose-700",
      "[&_.password-field-wrapper>input]:placeholder:text-[#4D4137] focus-within:[&_.password-field-wrapper]:ring-[#4D4137]",
      floating && "[&_.password-field-wrapper_.floating-label]:bg-[#FFECDA]"
    ]
  end

  defp color_variant("default", "light", floating) do
    [
      "[&_.password-field-wrapper]:bg-[#E3E7F1] text-[#707483] [&_.password-field-wrapper:not(:has(.password-field-error))]:border-[#707483]",
      "[&_.password-field-wrapper.password-field-error]:border-rose-700",
      "[&_.password-field-wrapper>input]:placeholder:text-[#707483] focus-within:[&_.password-field-wrapper]:ring-[#707483]",
      floating && "[&_.password-field-wrapper_.floating-label]:bg-[#E3E7F1]"
    ]
  end

  defp color_variant("default", "dark", floating) do
    [
      "[&_.password-field-wrapper]:bg-[#1E1E1E] text-[#1E1E1E] [&_.password-field-wrapper]:text-white [&_.password-field-wrapper:not(:has(.password-field-error))]:border-[#050404]",
      "[&_.password-field-wrapper.password-field-error]:border-rose-700",
      "[&_.password-field-wrapper>input]:placeholder:text-white focus-within:[&_.password-field-wrapper]:ring-[#050404]",
      floating && "[&_.password-field-wrapper_.floating-label]:bg-[#1E1E1E]"
    ]
  end

  defp color_variant("unbordered", "white", floating) do
    [
      "[&_.password-field-wrapper]:bg-white [&_.password-field-wrapper]:border-transparent text-[#3E3E3E]",
      "[&_.password-field-wrapper>input]:placeholder:text-[#3E3E3E]",
      floating == "outer" && "[&_.password-field-wrapper_.floating-label]:bg-white"
    ]
  end

  defp color_variant("unbordered", "primary", floating) do
    [
      "[&_.password-field-wrapper]:bg-[#4363EC] text-[#4363EC] [&_.password-field-wrapper]:border-transparent text-white",
      "[&_.password-field-wrapper>input]:placeholder:text-white",
      floating == "outer" && "[&_.password-field-wrapper_.floating-label]:bg-[#4363EC]"
    ]
  end

  defp color_variant("unbordered", "secondary", floating) do
    [
      "[&_.password-field-wrapper]:bg-[#6B6E7C] text-[#6B6E7C] [&_.password-field-wrapper]:border-transparent text-white",
      "[&_.password-field-wrapper>input]:placeholder:text-white",
      floating == "outer" && "[&_.password-field-wrapper_.floating-label]:bg-[#6B6E7C]"
    ]
  end

  defp color_variant("unbordered", "success", floating) do
    [
      "[&_.password-field-wrapper]:bg-[#ECFEF3] [&_.password-field-wrapper]:border-transparent text-[#047857]",
      "[&_.password-field-wrapper>input]:placeholder:text-[#047857]",
      floating == "outer" && "[&_.password-field-wrapper_.floating-label]:bg-[#ECFEF3]"
    ]
  end

  defp color_variant("unbordered", "warning", floating) do
    [
      "[&_.password-field-wrapper]:bg-[#FFF8E6] [&_.password-field-wrapper]:border-transparent text-[#FF8B08]",
      "[&_.password-field-wrapper>input]:placeholder:text-[#FF8B08]",
      floating == "outer" && "[&_.password-field-wrapper_.floating-label]:bg-[#FFF8E6]"
    ]
  end

  defp color_variant("unbordered", "danger", floating) do
    [
      "[&_.password-field-wrapper]:bg-[#FFE6E6] [&_.password-field-wrapper]:border-transparent text-[#E73B3B]",
      "[&_.password-field-wrapper>input]:placeholder:text-[#E73B3B]",
      floating == "outer" && "[&_.password-field-wrapper_.floating-label]:bg-[#FFE6E6]"
    ]
  end

  defp color_variant("unbordered", "info", floating) do
    [
      "[&_.password-field-wrapper]:bg-[#E5F0FF] [&_.password-field-wrapper]:border-transparent text-[#004FC4]",
      "[&_.password-field-wrapper>input]:placeholder:text-[#004FC4]",
      floating == "outer" && "[&_.password-field-wrapper_.floating-label]:bg-[#E5F0FF]"
    ]
  end

  defp color_variant("unbordered", "misc", floating) do
    [
      "[&_.password-field-wrapper]:bg-[#FFE6FF] [&_.password-field-wrapper]:border-transparent text-[#52059C]",
      "[&_.password-field-wrapper>input]:placeholder:text-[#52059C]",
      floating == "outer" && "[&_.password-field-wrapper_.floating-label]:bg-[#FFE6FF]"
    ]
  end

  defp color_variant("unbordered", "dawn", floating) do
    [
      "[&_.password-field-wrapper]:bg-[#FFECDA] [&_.password-field-wrapper]:border-transparent text-[#4D4137]",
      "[&_.password-field-wrapper>input]:placeholder:text-[#4D4137]",
      floating == "outer" && "[&_.password-field-wrapper_.floating-label]:bg-[#FFECDA]"
    ]
  end

  defp color_variant("unbordered", "light", floating) do
    [
      "[&_.password-field-wrapper]:bg-[#E3E7F1] [&_.password-field-wrapper]:border-transparent text-[#707483]",
      "[&_.password-field-wrapper>input]:placeholder:text-[#707483]",
      floating == "outer" && "[&_.password-field-wrapper_.floating-label]:bg-[#E3E7F1]"
    ]
  end

  defp color_variant("unbordered", "dark", floating) do
    [
      "[&_.password-field-wrapper]:bg-[#1E1E1E] text-[#1E1E1E] [&_.password-field-wrapper]:border-transparent text-white",
      "[&_.password-field-wrapper>input]:placeholder:text-white",
      floating == "outer" && "[&_.password-field-wrapper_.floating-label]:bg-[#1E1E1E]"
    ]
  end

  defp color_variant("shadow", "white", floating) do
    [
      "[&_.password-field-wrapper]:bg-white text-[#3E3E3E] [&_.password-field-wrapper:not(:has(.password-field-error))]:border-[#DADADA]",
      "[&_.password-field-wrapper.password-field-error]:border-rose-700",
      "[&_.password-field-wrapper]:shadow [&_.password-field-wrapper>input]:placeholder:text-[#3E3E3E]",
      floating == "outer" && "[&_.password-field-wrapper_.floating-label]:bg-[#3E3E3E]"
    ]
  end

  defp color_variant("shadow", "primary", floating) do
    [
      "[&_.password-field-wrapper]:bg-[#4363EC] text-[#4363EC] [&_.password-field-wrapper:not(:has(.password-field-error))]:border-[#4363EC]",
      "[&_.password-field-wrapper.password-field-error]:border-rose-700",
      "[&_.password-field-wrapper]:shadow [&_.password-field-wrapper>input]:placeholder:text-white",
      floating == "outer" && "[&_.password-field-wrapper_.floating-label]:bg-[#3E3E3E]"
    ]
  end

  defp color_variant("shadow", "secondary", floating) do
    [
      "[&_.password-field-wrapper]:bg-[#6B6E7C] text-[#6B6E7C] [&_.password-field-wrapper:not(:has(.password-field-error))]:border-[#6B6E7C]",
      "[&_.password-field-wrapper.password-field-error]:border-rose-700",
      "[&_.password-field-wrapper]:shadow [&_.password-field-wrapper>input]:placeholder:text-white",
      floating == "outer" && "[&_.password-field-wrapper_.floating-label]:bg-[#6B6E7C]"
    ]
  end

  defp color_variant("shadow", "success", floating) do
    [
      "[&_.password-field-wrapper]:bg-[#ECFEF3] text-[#227A52] [&_.password-field-wrapper:not(:has(.password-field-error))]:border-[#047857]",
      "[&_.password-field-wrapper.password-field-error]:border-rose-700",
      "[&_.password-field-wrapper]:shadow [&_.password-field-wrapper>input]:placeholder:text-[#047857]",
      floating == "outer" && "[&_.password-field-wrapper_.floating-label]:bg-[#ECFEF3]"
    ]
  end

  defp color_variant("shadow", "warning", floating) do
    [
      "[&_.password-field-wrapper]:bg-[#FFF8E6] text-[#FF8B08] [&_.password-field-wrapper:not(:has(.password-field-error))]:border-[#FFF8E6]",
      "[&_.password-field-wrapper.password-field-error]:border-rose-700",
      "[&_.password-field-wrapper]:shadow [&_.password-field-wrapper>input]:placeholder:text-[#FF8B08]",
      floating == "outer" && "[&_.password-field-wrapper_.floating-label]:bg-[#FFF8E6]"
    ]
  end

  defp color_variant("shadow", "danger", floating) do
    [
      "[&_.password-field-wrapper]:bg-[#FFE6E6] text-[#E73B3B] [&_.password-field-wrapper:not(:has(.password-field-error))]:border-[#FFE6E6]",
      "[&_.password-field-wrapper.password-field-error]:border-rose-700",
      "[&_.password-field-wrapper]:shadow [&_.password-field-wrapper>input]:placeholder:text-[#E73B3B]",
      floating == "outer" && "[&_.password-field-wrapper_.floating-label]:bg-[#FFE6E6]"
    ]
  end

  defp color_variant("shadow", "info", floating) do
    [
      "[&_.password-field-wrapper]:bg-[#E5F0FF] text-[#004FC4] [&_.password-field-wrapper:not(:has(.password-field-error))]:border-[#E5F0FF]",
      "[&_.password-field-wrapper.password-field-error]:border-rose-700",
      "[&_.password-field-wrapper]:shadow [&_.password-field-wrapper>input]:placeholder:text-[#004FC4]",
      floating == "outer" && "[&_.password-field-wrapper_.floating-label]:bg-[#E5F0FF]"
    ]
  end

  defp color_variant("shadow", "misc", floating) do
    [
      "[&_.password-field-wrapper]:bg-[#FFE6FF] text-[#52059C] [&_.password-field-wrapper:not(:has(.password-field-error))]:border-[#FFE6FF]",
      "[&_.password-field-wrapper.password-field-error]:border-rose-700",
      "[&_.password-field-wrapper]:shadow [&_.password-field-wrapper>input]:placeholder:text-[#52059C]",
      floating == "outer" && "[&_.password-field-wrapper_.floating-label]:bg-[#FFE6FF]"
    ]
  end

  defp color_variant("shadow", "dawn", floating) do
    [
      "[&_.password-field-wrapper]:bg-[#FFECDA] text-[#4D4137] [&_.password-field-wrapper:not(:has(.password-field-error))]:border-[#FFECDA]",
      "[&_.password-field-wrapper.password-field-error]:border-rose-700",
      "[&_.password-field-wrapper]:shadow [&_.password-field-wrapper>input]:placeholder:text-[#4D4137]",
      floating == "outer" && "[&_.password-field-wrapper_.floating-label]:bg-[#FFECDA]"
    ]
  end

  defp color_variant("shadow", "light", floating) do
    [
      "[&_.password-field-wrapper]:bg-[#E3E7F1] text-[#707483] [&_.password-field-wrapper:not(:has(.password-field-error))]:border-[#E3E7F1]",
      "[&_.password-field-wrapper.password-field-error]:border-rose-700",
      "[&_.password-field-wrapper]:shadow [&_.password-field-wrapper>input]:placeholder:text-[#707483]",
      floating == "outer" && "[&_.password-field-wrapper_.floating-label]:bg-[#E3E7F1]"
    ]
  end

  defp color_variant("shadow", "dark", floating) do
    [
      "[&_.password-field-wrapper]:bg-[#1E1E1E] text-[#1E1E1E] [&_.password-field-wrapper:not(:has(.password-field-error))]:border-[#1E1E1E]",
      "[&_.password-field-wrapper.password-field-error]:border-rose-700",
      "[&_.password-field-wrapper]:shadow [&_.password-field-wrapper>input]:placeholder:text-white",
      floating == "outer" && "[&_.password-field-wrapper_.floating-label]:bg-[#1E1E1E]"
    ]
  end

  defp color_variant("transparent", "white", _) do
    [
      "[&_.password-field-wrapper]:bg-transparent text-[#DADADA] [&_.password-field-wrapper]:border-transparent",
      "[&_.password-field-wrapper>input]:placeholder:text-[#DADADA]",
      "focus-within:[&_.password-field-wrapper]:ring-transparent"
    ]
  end

  defp color_variant("transparent", "primary", _) do
    [
      "[&_.password-field-wrapper]:bg-transparent text-[#4363EC] [&_.password-field-wrapper]:border-transparent",
      "[&_.password-field-wrapper>input]:placeholder:text-[#4363EC]",
      "focus-within:[&_.password-field-wrapper]:ring-transparent"
    ]
  end

  defp color_variant("transparent", "secondary", _) do
    [
      "[&_.password-field-wrapper]:bg-transparent text-[#6B6E7C] [&_.password-field-wrapper]:border-transparent",
      "[&_.password-field-wrapper>input]:placeholder:text-[#6B6E7C]",
      "focus-within:[&_.password-field-wrapper]:ring-transparent"
    ]
  end

  defp color_variant("transparent", "success", _) do
    [
      "[&_.password-field-wrapper]:bg-transparent text-[#047857] [&_.password-field-wrapper]:border-transparent",
      "[&_.password-field-wrapper>input]:placeholder:text-[#047857]",
      "focus-within:[&_.password-field-wrapper]:ring-transparent"
    ]
  end

  defp color_variant("transparent", "warning", _) do
    [
      "[&_.password-field-wrapper]:bg-transparent text-[#FF8B08] [&_.password-field-wrapper]:border-transparent",
      "[&_.password-field-wrapper>input]:placeholder:text-[#FF8B08]",
      "focus-within:[&_.password-field-wrapper]:ring-transparent"
    ]
  end

  defp color_variant("transparent", "danger", _) do
    [
      "[&_.password-field-wrapper]:bg-transparent text-[#E73B3B] [&_.password-field-wrapper]:border-transparent",
      "[&_.password-field-wrapper>input]:placeholder:text-[#E73B3B]",
      "focus-within:[&_.password-field-wrapper]:ring-transparent"
    ]
  end

  defp color_variant("transparent", "info", _) do
    [
      "[&_.password-field-wrapper]:bg-transparent text-[#004FC4] [&_.password-field-wrapper]:border-transparent",
      "[&_.password-field-wrapper>input]:placeholder:text-[#004FC4]",
      "focus-within:[&_.password-field-wrapper]:ring-transparent"
    ]
  end

  defp color_variant("transparent", "misc", _) do
    [
      "[&_.password-field-wrapper]:bg-transparent text-[#52059C] [&_.password-field-wrapper]:border-transparent",
      "[&_.password-field-wrapper>input]:placeholder:text-[#52059C]",
      "focus-within:[&_.password-field-wrapper]:ring-transparent"
    ]
  end

  defp color_variant("transparent", "dawn", _) do
    [
      "[&_.password-field-wrapper]:bg-transparent text-[#4D4137] [&_.password-field-wrapper]:border-transparent",
      "[&_.password-field-wrapper>input]:placeholder:text-[#4D4137]",
      "focus-within:[&_.password-field-wrapper]:ring-transparent"
    ]
  end

  defp color_variant("transparent", "light", _) do
    [
      "[&_.password-field-wrapper]:bg-transparent text-[#707483] [&_.password-field-wrapper]:border-transparent",
      "[&_.password-field-wrapper>input]:placeholder:text-[#707483]",
      "focus-within:[&_.password-field-wrapper]:ring-transparent"
    ]
  end

  defp color_variant("transparent", "dark", _) do
    [
      "[&_.password-field-wrapper]:bg-transparent text-[#1E1E1E] [&_.password-field-wrapper]:border-transparent",
      "[&_.password-field-wrapper>input]:placeholder:text-[#1E1E1E]",
      "focus-within:[&_.password-field-wrapper]:ring-transparent"
    ]
  end

  defp translate_error({msg, opts}) do
    # When using gettext, we typically pass the strings we want
    # to translate as a static argument:
    #
    #     # Translate the number of files with plural rules
    #     dngettext("errors", "1 file", "%{count} files", count)
    #
    # However the error messages in our forms and APIs are generated
    # dynamically, so we need to translate them by calling Gettext
    # with our gettext backend as first argument. Translations are
    # available in the errors.po file (as we use the "errors" domain).
    if count = opts[:count] do
      Gettext.dngettext(StockWeb.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(StockWeb.Components.PasswordField.Gettext, "errors", msg, opts)
    end
  end

  attr :name, :string, required: true
  attr :type, :string, default: "regular", values: ~w(brands regular solid)
  attr :class, :any, default: nil

  defp icon(%{name: "fa-" <> _} = assigns) do
    ~H"""
    <span class={["fa-#{@type}", @name, @class]} />
    """
  end
end
