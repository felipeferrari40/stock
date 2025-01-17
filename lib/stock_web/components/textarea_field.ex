defmodule StockWeb.Components.TextareaField do
  @moduledoc """
  The `StockWeb.Components.TextareaField` module provides a versatile and customizable textarea field component
  for Phoenix LiveView applications. It supports a range of styles, themes, and functional attributes
  to enhance the user experience when working with large text inputs.

  ### Features:
  - **Color Themes**: Offers a variety of color options to style the textarea field and error states.
  - **Border and Padding**: Customizable border styles and padding for a consistent look and feel.
  - **Size Options**: Allows adjustments to the height and size of the textarea field to suit different
  requirements.
  - **Floating Labels**: Supports floating labels that adapt to different styles, including inner and
  outer placements.
  - **Error Handling**: Displays error messages with optional icons, integrated seamlessly into the
  field's design.
  - **Resize Control**: Includes an option to disable textarea resizing.
  - **Accessibility**: Supports ARIA attributes for accessibility and user-friendly error handling.
  - **Slots for Customization**: Provides slots for adding content before and after the textarea field,
  enabling a high degree of customization.

  This component integrates smoothly into Phoenix LiveView forms, providing a user-friendly interface
  for text input with extensive customization options.
  """

  use Phoenix.Component

  @variants ["outline", "default", "shadow", "unbordered", "transparent"]

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
  The `textarea_field` component provides a customizable text area input with various styling options,
  including floating labels, error messages, and resizing control.

  ## Examples

  ```elixir
  <.textarea_field
    name="name"
    space="small"
    color="danger"
    description="This is description"
    label="This is outline label"
    placeholder="This is placeholder"
    floating="outer"
    disable_resize
  />

  <.textarea_field
    name="name"
    variant="unbordered"
    space="small"
    color="success"
    label="This is Unbordered Success"
    placeholder="This is placeholder"
  />
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
  attr :variant, :string, values: @variants, default: "outline", doc: "Determines the style"
  attr :description, :string, default: nil, doc: "Determines a short description"
  attr :space, :string, default: "medium", doc: "Space between items"

  attr :size, :string,
    default: "extra_large",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :disable_resize, :boolean, default: false, doc: ""
  attr :rows, :string, default: nil, doc: "Determines count of textarea rows"

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
    include:
      ~w(disabled form maxlength minlength placeholder readonly required spellcheck inputmode title autofocus wrap dirname),
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  @spec textarea_field(map()) :: Phoenix.LiveView.Rendered.t()
  def textarea_field(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []

    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(errors, &translate_error(&1)))
    |> assign_new(:value, fn -> field.value end)
    |> textarea_field()
  end

  def textarea_field(%{floating: floating} = assigns) when floating in ["inner", "outer"] do
    ~H"""
    <div class={[
      color_variant(@variant, @color, @floating),
      rounded_size(@rounded),
      border_class(@border),
      height_size(@size),
      space_class(@space),
      @ring && "[&_.textarea-field-wrapper]:focus-within:ring-[0.03rem]",
      @class
    ]}>
      <div :if={!is_nil(@description)} class="text-xs pb-2">
        <%= @description %>
      </div>
      <div class={[
        "textarea-field-wrapper transition-all ease-in-out duration-200 relative w-full z-[2]",
        @errors != [] && "textarea-field-error"
      ]}>
        <textarea
          type="text"
          name={@name}
          id={@id}
          rows={@rows}
          value={@value}
          class={[
            "disabled:opacity-80 block w-full z-[2] focus:ring-0 placeholder:text-transparent pb-1 pt-3 px-2",
            "text-sm appearance-none bg-transparent border-0 focus:outline-none peer",
            @disable_resize && "resize-none"
          ]}
          placeholder=" "
          {@rest}
        ></textarea>

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

      <.error :for={msg <- @errors} icon={@error_icon}><%= msg %></.error>
    </div>
    """
  end

  def textarea_field(assigns) do
    ~H"""
    <div class={[
      color_variant(@variant, @color, @floating),
      rounded_size(@rounded),
      border_class(@border),
      height_size(@size),
      space_class(@space),
      @ring && "[&_.textarea-field-wrapper]:focus-within:ring-[0.03rem]",
      @class
    ]}>
      <div>
        <.label for={@id}><%= @label %></.label>
        <div :if={!is_nil(@description)} class="text-xs">
          <%= @description %>
        </div>
      </div>

      <div class={[
        "textarea-field-wrapper overflow-hidden transition-all ease-in-out duration-200 flex flex-nowrap",
        @errors != [] && "textarea-field-error"
      ]}>
        <textarea
          type="text"
          name={@name}
          id={@id}
          rows={@rows}
          value={@value}
          class={[
            "flex-1 py-1 px-2 text-sm disabled:opacity-80 block w-full appearance-none",
            "bg-transparent border-0 focus:outline-none focus:ring-0",
            @disable_resize && "resize-none"
          ]}
          {@rest}
        ></textarea>
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
      "peer-placeholder-shown:-translate-y-1/2 peer-placeholder-shown:top-4 peer-focus:top-2 peer-focus:scale-75 peer-focus:-translate-y-4",
      "rtl:peer-focus:translate-x-1/4 rtl:peer-focus:left-auto"
    ]
  end

  defp variant_label_position("inner") do
    [
      "-translate-y-4 scale-75 top-4 origin-[0] peer-placeholder-shown:scale-100 peer-placeholder-shown:translate-y-0",
      "peer-focus:scale-75 peer-focus:-translate-y-4 rtl:peer-focus:translate-x-1/4 rtl:peer-focus:left-auto"
    ]
  end

  defp height_size("extra_small"), do: "[&_.textarea-field-wrapper_textarea]:h-10"

  defp height_size("small"), do: "[&_.textarea-field-wrapper_textarea]:h-12"

  defp height_size("medium"), do: "[&_.textarea-field-wrapper_textarea]:h-11"

  defp height_size("large"), do: "[&_.textarea-field-wrapper_textarea]:h-16"

  defp height_size("extra_large"), do: "[&_.textarea-field-wrapper_textarea]:h-18"

  defp height_size("auto"), do: "[&_.textarea-field-wrapper_textarea]:h-auto"

  defp height_size(_), do: height_size("medium")

  defp rounded_size("extra_small"), do: "[&_.textarea-field-wrapper]:rounded-sm"

  defp rounded_size("small"), do: "[&_.textarea-field-wrapper]:rounded"

  defp rounded_size("medium"), do: "[&_.textarea-field-wrapper]:rounded-md"

  defp rounded_size("large"), do: "[&_.textarea-field-wrapper]:rounded-lg"

  defp rounded_size("extra_large"), do: "[&_.textarea-field-wrapper]:rounded-xl"

  defp rounded_size("full"), do: "[&_.textarea-field-wrapper]:rounded-full"

  defp rounded_size(_), do: "[&_.textarea-field-wrapper]:rounded-none"

  defp border_class("none"), do: "[&_.textarea-field-wrapper]:border-0"
  defp border_class("extra_small"), do: "[&_.textarea-field-wrapper]:border"
  defp border_class("small"), do: "[&_.textarea-field-wrapper]:border-2"
  defp border_class("medium"), do: "[&_.textarea-field-wrapper]:border-[3px]"
  defp border_class("large"), do: "[&_.textarea-field-wrapper]:border-4"
  defp border_class("extra_large"), do: "[&_.textarea-field-wrapper]:border-[5px]"
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
      "text-white [&_.textarea-field-wrapper:not(:has(.textarea-field-error))]:border-white",
      "[&_.textarea-field-wrapper.textarea-field-error]:border-rose-700",
      "[&_.textarea-field-wrapper>textarea]:placeholder:text-white focus-within:[&_.textarea-field-wrapper]:ring-white",
      floating == "outer" && "[&_.textarea-field-wrapper_.floating-label]:bg-white"
    ]
  end

  defp color_variant("outline", "silver", floating) do
    [
      "text-[#afafaf] [&_.textarea-field-wrapper:not(:has(.textarea-field-error))]:border-[#afafaf]",
      "[&_.textarea-field-wrapper.textarea-field-error]:border-rose-700",
      "[&_.textarea-field-wrapper>textarea]:placeholder:text-[#afafaf] focus-within:[&_.textarea-field-wrapper]:ring-[#afafaf]",
      floating == "outer" && "[&_.textarea-field-wrapper_.floating-label]:bg-white"
    ]
  end

  defp color_variant("outline", "primary", floating) do
    [
      "text-[#2441de] [&_.textarea-field-wrapper:not(:has(.textarea-field-error))]:border-[#2441de]",
      "[&_.textarea-field-wrapper.textarea-field-error]:border-rose-700",
      "[&_.textarea-field-wrapper>textarea]:placeholder:text-[#2441de] focus-within:[&_.textarea-field-wrapper]:ring-[#2441de]",
      floating == "outer" && "[&_.textarea-field-wrapper_.floating-label]:bg-white"
    ]
  end

  defp color_variant("outline", "secondary", floating) do
    [
      "text-[#877C7C] [&_.textarea-field-wrapper:not(:has(.textarea-field-error))]:border-[#877C7C]",
      "[&_.textarea-field-wrapper.textarea-field-error]:border-rose-700",
      "[&_.textarea-field-wrapper>textarea]:placeholder:text-[#877C7Cb] focus-within:[&_.textarea-field-wrapper]:ring-[#877C7C]",
      floating == "outer" && "[&_.textarea-field-wrapper_.floating-label]:bg-white"
    ]
  end

  defp color_variant("outline", "success", floating) do
    [
      "text-[#047857] [&_.textarea-field-wrapper:not(:has(.textarea-field-error))]:border-[#047857]",
      "[&_.textarea-field-wrapper.textarea-field-error]:border-rose-700",
      "[&_.textarea-field-wrapper>textarea]:placeholder:text-[#047857] focus-within:[&_.textarea-field-wrapper]:ring-[#047857]",
      floating == "outer" && "[&_.textarea-field-wrapper_.floating-label]:bg-white"
    ]
  end

  defp color_variant("outline", "warning", floating) do
    [
      "text-[#FF8B08] [&_.textarea-field-wrapper:not(:has(.textarea-field-error))]:border-[#FF8B08]",
      "[&_.textarea-field-wrapper.textarea-field-error]:border-rose-700",
      "[&_.textarea-field-wrapper>textarea]:placeholder:text-[#FF8B08] focus-within:[&_.textarea-field-wrapper]:ring-[#FF8B08]",
      floating == "outer" && "[&_.textarea-field-wrapper_.floating-label]:bg-white"
    ]
  end

  defp color_variant("outline", "danger", floating) do
    [
      "text-[#E73B3B] [&_.textarea-field-wrapper:not(:has(.textarea-field-error))]:border-[#E73B3B]",
      "[&_.textarea-field-wrapper.textarea-field-error]:border-rose-700",
      "[&_.textarea-field-wrapper>textarea]:placeholder:text-[#E73B3B] focus-within:[&_.textarea-field-wrapper]:ring-[#E73B3B]",
      floating == "outer" && "[&_.textarea-field-wrapper_.floating-label]:bg-white"
    ]
  end

  defp color_variant("outline", "info", floating) do
    [
      "text-[#004FC4] [&_.textarea-field-wrapper:not(:has(.textarea-field-error))]:border-[#004FC4]",
      "[&_.textarea-field-wrapper.textarea-field-error]:border-rose-700",
      "[&_.textarea-field-wrapper>textarea]:placeholder:text-[#004FC4] focus-within:[&_.textarea-field-wrapper]:ring-[#004FC4]",
      floating == "outer" && "[&_.textarea-field-wrapper_.floating-label]:bg-white"
    ]
  end

  defp color_variant("outline", "misc", floating) do
    [
      "text-[#52059C] [&_.textarea-field-wrapper:not(:has(.textarea-field-error))]:border-[#52059C]",
      "[&_.textarea-field-wrapper.textarea-field-error]:border-rose-700",
      "[&_.textarea-field-wrapper>textarea]:placeholder:text-[#52059C] focus-within:[&_.textarea-field-wrapper]:ring-[#52059C]",
      floating == "outer" && "[&_.textarea-field-wrapper_.floating-label]:bg-white"
    ]
  end

  defp color_variant("outline", "dawn", floating) do
    [
      "text-[#4D4137] [&_.textarea-field-wrapper:not(:has(.textarea-field-error))]:border-[#4D4137]",
      "[&_.textarea-field-wrapper.textarea-field-error]:border-rose-700",
      "[&_.textarea-field-wrapper>textarea]:placeholder:text-[#4D4137] focus-within:[&_.textarea-field-wrapper]:ring-[#4D4137]",
      floating == "outer" && "[&_.textarea-field-wrapper_.floating-label]:bg-white"
    ]
  end

  defp color_variant("outline", "light", floating) do
    [
      "text-[#707483] [&_.textarea-field-wrapper:not(:has(.textarea-field-error))]:border-[#707483]",
      "[&_.textarea-field-wrapper.textarea-field-error]:border-rose-700",
      "[&_.textarea-field-wrapper>textarea]:placeholder:text-[#707483] focus-within:[&_.textarea-field-wrapper]:ring-[#707483]",
      floating == "outer" && "[&_.textarea-field-wrapper_.floating-label]:bg-white"
    ]
  end

  defp color_variant("outline", "dark", floating) do
    [
      "text-[#1E1E1E] [&_.textarea-field-wrapper]:text-text-[#1E1E1E] [&_.textarea-field-wrapper:not(:has(.textarea-field-error))]:border-[#050404]",
      "[&_.textarea-field-wrapper.textarea-field-error]:border-rose-700",
      "[&_.textarea-field-wrapper>textarea]:placeholder:text-[#1E1E1E] focus-within:[&_.textarea-field-wrapper]:ring-[#050404]",
      floating == "outer" && "[&_.textarea-field-wrapper_.floating-label]:bg-white"
    ]
  end

  defp color_variant("default", "white", floating) do
    [
      "[&_.textarea-field-wrapper]:bg-white text-[#3E3E3E] [&_.textarea-field-wrapper:not(:has(.textarea-field-error))]:border-[#DADADA]",
      "[&_.textarea-field-wrapper.textarea-field-error]:border-rose-700",
      "[&_.textarea-field-wrapper>textarea]:placeholder:text-[#3E3E3E] focus-within:[&_.textarea-field-wrapper]:ring-[#DADADA]",
      floating == "outer" && "[&_.textarea-field-wrapper_.floating-label]:bg-white"
    ]
  end

  defp color_variant("default", "primary", floating) do
    [
      "[&_.textarea-field-wrapper]:bg-[#4363EC] text-[#4363EC] [&_.textarea-field-wrapper:not(:has(.textarea-field-error))]:border-[#2441de]",
      "[&_.textarea-field-wrapper.textarea-field-error]:border-rose-700 [&_.textarea-field-wrapper]:text-white",
      "[&_.textarea-field-wrapper>textarea]:placeholder:text-white focus-within:[&_.textarea-field-wrapper]:ring-[#2441de]",
      floating == "outer" && "[&_.textarea-field-wrapper_.floating-label]:bg-[#4363EC]"
    ]
  end

  defp color_variant("default", "secondary", floating) do
    [
      "[&_.textarea-field-wrapper]:bg-[#6B6E7C] text-[#6B6E7C] [&_.textarea-field-wrapper:not(:has(.textarea-field-error))]:border-[#877C7C]",
      "[&_.textarea-field-wrapper.textarea-field-error]:border-rose-700 [&_.textarea-field-wrapper]:text-white",
      "[&_.textarea-field-wrapper>textarea]:placeholder:text-white focus-within:[&_.textarea-field-wrapper]:ring-[#877C7C]",
      floating == "outer" && "[&_.textarea-field-wrapper_.floating-label]:bg-[#6B6E7C]"
    ]
  end

  defp color_variant("default", "success", floating) do
    [
      "[&_.textarea-field-wrapper]:bg-[#ECFEF3] text-[#047857] [&_.textarea-field-wrapper:not(:has(.textarea-field-error))]:border-[#6EE7B7]",
      "[&_.textarea-field-wrapper.textarea-field-error]:border-rose-700",
      "[&_.textarea-field-wrapper>textarea]:placeholder:text-[#047857] focus-within:[&_.textarea-field-wrapper]:ring-[#6EE7B7]",
      floating == "outer" && "[&_.textarea-field-wrapper_.floating-label]:bg-[#ECFEF3]"
    ]
  end

  defp color_variant("default", "warning", floating) do
    [
      "[&_.textarea-field-wrapper]:bg-[#FFF8E6] text-[#FF8B08] [&_.textarea-field-wrapper:not(:has(.textarea-field-error))]:border-[#FF8B08]",
      "[&_.textarea-field-wrapper.textarea-field-error]:border-rose-700",
      "[&_.textarea-field-wrapper>textarea]:placeholder:text-[#FF8B08] focus-within:[&_.textarea-field-wrapper]:ring-[#FF8B08]",
      floating == "outer" && "[&_.textarea-field-wrapper_.floating-label]:bg-[#FFF8E6]"
    ]
  end

  defp color_variant("default", "danger", floating) do
    [
      "[&_.textarea-field-wrapper]:bg-[#FFE6E6] text-[#E73B3B] [&_.textarea-field-wrapper:not(:has(.textarea-field-error))]:border-[#E73B3B]",
      "[&_.textarea-field-wrapper.textarea-field-error]:border-rose-700",
      "[&_.textarea-field-wrapper>textarea]:placeholder:text-[#E73B3B] focus-within:[&_.textarea-field-wrapper]:ring-[#E73B3B]",
      floating == "outer" && "[&_.textarea-field-wrapper_.floating-label]:bg-[#FFE6E6]"
    ]
  end

  defp color_variant("default", "info", floating) do
    [
      "[&_.textarea-field-wrapper]:bg-[#E5F0FF] text-[#004FC4] [&_.textarea-field-wrapper:not(:has(.textarea-field-error))]:border-[#004FC4]",
      "[&_.textarea-field-wrapper.textarea-field-error]:border-rose-700",
      "[&_.textarea-field-wrapper>textarea]:placeholder:text-[#004FC4] focus-within:[&_.textarea-field-wrapper]:ring-[#004FC4]",
      floating == "outer" && "[&_.textarea-field-wrapper_.floating-label]:bg-[#E5F0FF]"
    ]
  end

  defp color_variant("default", "misc", floating) do
    [
      "[&_.textarea-field-wrapper]:bg-[#FFE6FF] text-[#52059C] [&_.textarea-field-wrapper:not(:has(.textarea-field-error))]:border-[#52059C]",
      "[&_.textarea-field-wrapper.textarea-field-error]:border-rose-700",
      "[&_.textarea-field-wrapper>textarea]:placeholder:text-[#52059C] focus-within:[&_.textarea-field-wrapper]:ring-[#52059C]",
      floating == "outer" && "[&_.textarea-field-wrapper_.floating-label]:bg-[#FFE6FF]"
    ]
  end

  defp color_variant("default", "dawn", floating) do
    [
      "[&_.textarea-field-wrapper]:bg-[#FFECDA] text-[#4D4137] [&_.textarea-field-wrapper:not(:has(.textarea-field-error))]:border-[#4D4137]",
      "[&_.textarea-field-wrapper.textarea-field-error]:border-rose-700",
      "[&_.textarea-field-wrapper>textarea]:placeholder:text-[#4D4137] focus-within:[&_.textarea-field-wrapper]:ring-[#4D4137]",
      floating == "outer" && "[&_.textarea-field-wrapper_.floating-label]:bg-[#FFECDA]"
    ]
  end

  defp color_variant("default", "light", floating) do
    [
      "[&_.textarea-field-wrapper]:bg-[#E3E7F1] text-[#707483] [&_.textarea-field-wrapper:not(:has(.textarea-field-error))]:border-[#707483]",
      "[&_.textarea-field-wrapper.textarea-field-error]:border-rose-700",
      "[&_.textarea-field-wrapper>textarea]:placeholder:text-[#707483] focus-within:[&_.textarea-field-wrapper]:ring-[#707483]",
      floating == "outer" && "[&_.textarea-field-wrapper_.floating-label]:bg-[#E3E7F1]"
    ]
  end

  defp color_variant("default", "dark", floating) do
    [
      "[&_.textarea-field-wrapper]:bg-[#1E1E1E] text-[#1E1E1E] [&_.textarea-field-wrapper]:text-white [&_.textarea-field-wrapper:not(:has(.textarea-field-error))]:border-[#050404]",
      "[&_.textarea-field-wrapper.textarea-field-error]:border-rose-700",
      "[&_.textarea-field-wrapper>textarea]:placeholder:text-white focus-within:[&_.textarea-field-wrapper]:ring-[#050404]",
      floating == "outer" && "[&_.textarea-field-wrapper_.floating-label]:bg-[#1E1E1E]"
    ]
  end

  defp color_variant("unbordered", "white", floating) do
    [
      "[&_.textarea-field-wrapper]:bg-white [&_.textarea-field-wrapper]:border-transparent text-[#3E3E3E]",
      "[&_.textarea-field-wrapper>textarea]:placeholder:text-[#3E3E3E]",
      floating == "outer" && "[&_.textarea-field-wrapper_.floating-label]:bg-white"
    ]
  end

  defp color_variant("unbordered", "primary", floating) do
    [
      "[&_.textarea-field-wrapper]:bg-[#4363EC] text-[#4363EC] [&_.textarea-field-wrapper]:border-transparent text-white",
      "[&_.textarea-field-wrapper>textarea]:placeholder:text-white",
      floating == "outer" && "[&_.textarea-field-wrapper_.floating-label]:bg-[#4363EC]"
    ]
  end

  defp color_variant("unbordered", "secondary", floating) do
    [
      "[&_.textarea-field-wrapper]:bg-[#6B6E7C] text-[#6B6E7C] [&_.textarea-field-wrapper]:border-transparent text-white",
      "[&_.textarea-field-wrapper>textarea]:placeholder:text-white",
      floating == "outer" && "[&_.textarea-field-wrapper_.floating-label]:bg-[#6B6E7C]"
    ]
  end

  defp color_variant("unbordered", "success", floating) do
    [
      "[&_.textarea-field-wrapper]:bg-[#ECFEF3] [&_.textarea-field-wrapper]:border-transparent text-[#047857]",
      "[&_.textarea-field-wrapper>textarea]:placeholder:text-[#047857]",
      floating == "outer" && "[&_.textarea-field-wrapper_.floating-label]:bg-[#ECFEF3]"
    ]
  end

  defp color_variant("unbordered", "warning", floating) do
    [
      "[&_.textarea-field-wrapper]:bg-[#FFF8E6] [&_.textarea-field-wrapper]:border-transparent text-[#FF8B08]",
      "[&_.textarea-field-wrapper>textarea]:placeholder:text-[#FF8B08]",
      floating == "outer" && "[&_.textarea-field-wrapper_.floating-label]:bg-[#FFF8E6]"
    ]
  end

  defp color_variant("unbordered", "danger", floating) do
    [
      "[&_.textarea-field-wrapper]:bg-[#FFE6E6] [&_.textarea-field-wrapper]:border-transparent text-[#E73B3B]",
      "[&_.textarea-field-wrapper>textarea]:placeholder:text-[#E73B3B]",
      floating == "outer" && "[&_.textarea-field-wrapper_.floating-label]:bg-[#FFE6E6]"
    ]
  end

  defp color_variant("unbordered", "info", floating) do
    [
      "[&_.textarea-field-wrapper]:bg-[#E5F0FF] [&_.textarea-field-wrapper]:border-transparent text-[#004FC4]",
      "[&_.textarea-field-wrapper>textarea]:placeholder:text-[#004FC4]",
      floating == "outer" && "[&_.textarea-field-wrapper_.floating-label]:bg-[#E5F0FF]"
    ]
  end

  defp color_variant("unbordered", "misc", floating) do
    [
      "[&_.textarea-field-wrapper]:bg-[#FFE6FF] [&_.textarea-field-wrapper]:border-transparent text-[#52059C]",
      "[&_.textarea-field-wrapper>textarea]:placeholder:text-[#52059C]",
      floating == "outer" && "[&_.textarea-field-wrapper_.floating-label]:bg-[#FFE6FF]"
    ]
  end

  defp color_variant("unbordered", "dawn", floating) do
    [
      "[&_.textarea-field-wrapper]:bg-[#FFECDA] [&_.textarea-field-wrapper]:border-transparent text-[#4D4137]",
      "[&_.textarea-field-wrapper>textarea]:placeholder:text-[#4D4137]",
      floating == "outer" && "[&_.textarea-field-wrapper_.floating-label]:bg-[#FFECDA]"
    ]
  end

  defp color_variant("unbordered", "light", floating) do
    [
      "[&_.textarea-field-wrapper]:bg-[#E3E7F1] [&_.textarea-field-wrapper]:border-transparent text-[#707483]",
      "[&_.textarea-field-wrapper>textarea]:placeholder:text-[#707483]",
      floating == "outer" && "[&_.textarea-field-wrapper_.floating-label]:bg-[#E3E7F1]"
    ]
  end

  defp color_variant("unbordered", "dark", floating) do
    [
      "[&_.textarea-field-wrapper]:bg-[#1E1E1E] text-[#1E1E1E] [&_.textarea-field-wrapper]:border-transparent text-white",
      "[&_.textarea-field-wrapper>textarea]:placeholder:text-white",
      floating == "outer" && "[&_.textarea-field-wrapper_.floating-label]:bg-[#1E1E1E]"
    ]
  end

  defp color_variant("shadow", "white", floating) do
    [
      "[&_.textarea-field-wrapper]:bg-white text-[#3E3E3E] [&_.textarea-field-wrapper:not(:has(.textarea-field-error))]:border-[#DADADA]",
      "[&_.textarea-field-wrapper.textarea-field-error]:border-rose-700",
      "[&_.textarea-field-wrapper]:shadow [&_.textarea-field-wrapper>textarea]:placeholder:text-[#3E3E3E]",
      floating == "outer" && "[&_.textarea-field-wrapper_.floating-label]:bg-[#3E3E3E]"
    ]
  end

  defp color_variant("shadow", "primary", floating) do
    [
      "[&_.textarea-field-wrapper]:bg-[#4363EC] text-[#4363EC] [&_.textarea-field-wrapper:not(:has(.textarea-field-error))]:border-[#4363EC]",
      "[&_.textarea-field-wrapper.textarea-field-error]:border-rose-700",
      "[&_.textarea-field-wrapper]:shadow [&_.textarea-field-wrapper>textarea]:placeholder:text-white",
      floating == "outer" && "[&_.textarea-field-wrapper_.floating-label]:bg-[#3E3E3E]"
    ]
  end

  defp color_variant("shadow", "secondary", floating) do
    [
      "[&_.textarea-field-wrapper]:bg-[#6B6E7C] text-[#6B6E7C] [&_.textarea-field-wrapper:not(:has(.textarea-field-error))]:border-[#6B6E7C]",
      "[&_.textarea-field-wrapper.textarea-field-error]:border-rose-700",
      "[&_.textarea-field-wrapper]:shadow [&_.textarea-field-wrapper>textarea]:placeholder:text-white",
      floating == "outer" && "[&_.textarea-field-wrapper_.floating-label]:bg-[#6B6E7C]"
    ]
  end

  defp color_variant("shadow", "success", floating) do
    [
      "[&_.textarea-field-wrapper]:bg-[#ECFEF3] text-[#227A52] [&_.textarea-field-wrapper:not(:has(.textarea-field-error))]:border-[#047857]",
      "[&_.textarea-field-wrapper.textarea-field-error]:border-rose-700",
      "[&_.textarea-field-wrapper]:shadow [&_.textarea-field-wrapper>textarea]:placeholder:text-[#047857]",
      floating == "outer" && "[&_.textarea-field-wrapper_.floating-label]:bg-[#ECFEF3]"
    ]
  end

  defp color_variant("shadow", "warning", floating) do
    [
      "[&_.textarea-field-wrapper]:bg-[#FFF8E6] text-[#FF8B08] [&_.textarea-field-wrapper:not(:has(.textarea-field-error))]:border-[#FFF8E6]",
      "[&_.textarea-field-wrapper.textarea-field-error]:border-rose-700",
      "[&_.textarea-field-wrapper]:shadow [&_.textarea-field-wrapper>textarea]:placeholder:text-[#FF8B08]",
      floating == "outer" && "[&_.textarea-field-wrapper_.floating-label]:bg-[#FFF8E6]"
    ]
  end

  defp color_variant("shadow", "danger", floating) do
    [
      "[&_.textarea-field-wrapper]:bg-[#FFE6E6] text-[#E73B3B] [&_.textarea-field-wrapper:not(:has(.textarea-field-error))]:border-[#FFE6E6]",
      "[&_.textarea-field-wrapper.textarea-field-error]:border-rose-700",
      "[&_.textarea-field-wrapper]:shadow [&_.textarea-field-wrapper>textarea]:placeholder:text-[#E73B3B]",
      floating == "outer" && "[&_.textarea-field-wrapper_.floating-label]:bg-[#FFE6E6]"
    ]
  end

  defp color_variant("shadow", "info", floating) do
    [
      "[&_.textarea-field-wrapper]:bg-[#E5F0FF] text-[#004FC4] [&_.textarea-field-wrapper:not(:has(.textarea-field-error))]:border-[#E5F0FF]",
      "[&_.textarea-field-wrapper.textarea-field-error]:border-rose-700",
      "[&_.textarea-field-wrapper]:shadow [&_.textarea-field-wrapper>textarea]:placeholder:text-[#004FC4]",
      floating == "outer" && "[&_.textarea-field-wrapper_.floating-label]:bg-[#E5F0FF]"
    ]
  end

  defp color_variant("shadow", "misc", floating) do
    [
      "[&_.textarea-field-wrapper]:bg-[#FFE6FF] text-[#52059C] [&_.textarea-field-wrapper:not(:has(.textarea-field-error))]:border-[#FFE6FF]",
      "[&_.textarea-field-wrapper.textarea-field-error]:border-rose-700",
      "[&_.textarea-field-wrapper]:shadow [&_.textarea-field-wrapper>textarea]:placeholder:text-[#52059C]",
      floating == "outer" && "[&_.textarea-field-wrapper_.floating-label]:bg-[#FFE6FF]"
    ]
  end

  defp color_variant("shadow", "dawn", floating) do
    [
      "[&_.textarea-field-wrapper]:bg-[#FFECDA] text-[#4D4137] [&_.textarea-field-wrapper:not(:has(.textarea-field-error))]:border-[#FFECDA]",
      "[&_.textarea-field-wrapper.textarea-field-error]:border-rose-700",
      "[&_.textarea-field-wrapper]:shadow [&_.textarea-field-wrapper>textarea]:placeholder:text-[#4D4137]",
      floating == "outer" && "[&_.textarea-field-wrapper_.floating-label]:bg-[#FFECDA]"
    ]
  end

  defp color_variant("shadow", "light", floating) do
    [
      "[&_.textarea-field-wrapper]:bg-[#E3E7F1] text-[#707483] [&_.textarea-field-wrapper:not(:has(.textarea-field-error))]:border-[#E3E7F1]",
      "[&_.textarea-field-wrapper.textarea-field-error]:border-rose-700",
      "[&_.textarea-field-wrapper]:shadow [&_.textarea-field-wrapper>textarea]:placeholder:text-[#707483]",
      floating == "outer" && "[&_.textarea-field-wrapper_.floating-label]:bg-[#E3E7F1]"
    ]
  end

  defp color_variant("shadow", "dark", floating) do
    [
      "[&_.textarea-field-wrapper]:bg-[#1E1E1E] text-[#1E1E1E] [&_.textarea-field-wrapper:not(:has(.textarea-field-error))]:border-[#1E1E1E]",
      "[&_.textarea-field-wrapper.textarea-field-error]:border-rose-700",
      "[&_.textarea-field-wrapper]:shadow [&_.textarea-field-wrapper>textarea]:placeholder:text-white",
      floating == "outer" && "[&_.textarea-field-wrapper_.floating-label]:bg-[#1E1E1E]"
    ]
  end

  defp color_variant("transparent", "white", _) do
    [
      "[&_.textarea-field-wrapper]:bg-transparent text-[#DADADA] [&_.textarea-field-wrapper]:border-transparent",
      "[&_.textarea-field-wrapper>textarea]:placeholder:text-[#DADADA]",
      "focus-within:[&_.textarea-field-wrapper]:ring-transparent"
    ]
  end

  defp color_variant("transparent", "primary", _) do
    [
      "[&_.textarea-field-wrapper]:bg-transparent text-[#4363EC] [&_.textarea-field-wrapper]:border-transparent",
      "[&_.textarea-field-wrapper>textarea]:placeholder:text-[#4363EC]",
      "focus-within:[&_.textarea-field-wrapper]:ring-transparent"
    ]
  end

  defp color_variant("transparent", "secondary", _) do
    [
      "[&_.textarea-field-wrapper]:bg-transparent text-[#6B6E7C] [&_.textarea-field-wrapper]:border-transparent",
      "[&_.textarea-field-wrapper>textarea]:placeholder:text-[#6B6E7C]",
      "focus-within:[&_.textarea-field-wrapper]:ring-transparent"
    ]
  end

  defp color_variant("transparent", "success", _) do
    [
      "[&_.textarea-field-wrapper]:bg-transparent text-[#047857] [&_.textarea-field-wrapper]:border-transparent",
      "[&_.textarea-field-wrapper>textarea]:placeholder:text-[#047857]",
      "focus-within:[&_.textarea-field-wrapper]:ring-transparent"
    ]
  end

  defp color_variant("transparent", "warning", _) do
    [
      "[&_.textarea-field-wrapper]:bg-transparent text-[#FF8B08] [&_.textarea-field-wrapper]:border-transparent",
      "[&_.textarea-field-wrapper>textarea]:placeholder:text-[#FF8B08]",
      "focus-within:[&_.textarea-field-wrapper]:ring-transparent"
    ]
  end

  defp color_variant("transparent", "danger", _) do
    [
      "[&_.textarea-field-wrapper]:bg-transparent text-[#E73B3B] [&_.textarea-field-wrapper]:border-transparent",
      "[&_.textarea-field-wrapper>textarea]:placeholder:text-[#E73B3B]",
      "focus-within:[&_.textarea-field-wrapper]:ring-transparent"
    ]
  end

  defp color_variant("transparent", "info", _) do
    [
      "[&_.textarea-field-wrapper]:bg-transparent text-[#004FC4] [&_.textarea-field-wrapper]:border-transparent",
      "[&_.textarea-field-wrapper>textarea]:placeholder:text-[#004FC4]",
      "focus-within:[&_.textarea-field-wrapper]:ring-transparent"
    ]
  end

  defp color_variant("transparent", "misc", _) do
    [
      "[&_.textarea-field-wrapper]:bg-transparent text-[#52059C] [&_.textarea-field-wrapper]:border-transparent",
      "[&_.textarea-field-wrapper>textarea]:placeholder:text-[#52059C]",
      "focus-within:[&_.textarea-field-wrapper]:ring-transparent"
    ]
  end

  defp color_variant("transparent", "dawn", _) do
    [
      "[&_.textarea-field-wrapper]:bg-transparent text-[#4D4137] [&_.textarea-field-wrapper]:border-transparent",
      "[&_.textarea-field-wrapper>textarea]:placeholder:text-[#4D4137]",
      "focus-within:[&_.textarea-field-wrapper]:ring-transparent"
    ]
  end

  defp color_variant("transparent", "light", _) do
    [
      "[&_.textarea-field-wrapper]:bg-transparent text-[#707483] [&_.textarea-field-wrapper]:border-transparent",
      "[&_.textarea-field-wrapper>textarea]:placeholder:text-[#707483]",
      "focus-within:[&_.textarea-field-wrapper]:ring-transparent"
    ]
  end

  defp color_variant("transparent", "dark", _) do
    [
      "[&_.textarea-field-wrapper]:bg-transparent text-[#1E1E1E] [&_.textarea-field-wrapper]:border-transparent",
      "[&_.textarea-field-wrapper>textarea]:placeholder:text-[#1E1E1E]",
      "focus-within:[&_.textarea-field-wrapper]:ring-transparent"
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
      Gettext.dgettext(StockWeb.Gettext, "errors", msg, opts)
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
