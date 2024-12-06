defmodule StockWeb.Components.MishkaComponents do
  defmacro __using__(_) do
    quote do
      import StockWeb.Components.Button,
        only: [button_group: 1, button: 1, input_button: 1, button_link: 1]

      import StockWeb.Components.Card,
        only: [card: 1, card_title: 1, card_media: 1, card_content: 1, card_footer: 1]

      import StockWeb.Components.CheckboxField, only: [checkbox_field: 1, group_checkbox: 1]

      import StockWeb.Components.Dropdown,
        only: [dropdown: 1, dropdown_trigger: 1, dropdown_content: 1]

      import StockWeb.Components.EmailField, only: [email_field: 1]
      import StockWeb.Components.FormWrapper, only: [form_wrapper: 1]
      import StockWeb.Components.InputField, only: [input_field: 1]
      import StockWeb.Components.Modal, only: [modal: 1]
      import StockWeb.Components.Navbar, only: [navbar: 1]
      import StockWeb.Components.Pagination, only: [pagination: 1]
      import StockWeb.Components.PasswordField, only: [password_field: 1]

      import StockWeb.Components.Rating, only: [rating: 1]
      import StockWeb.Components.SearchField, only: [search_field: 1]
      import StockWeb.Components.Sidebar, only: [sidebar: 1]
      import StockWeb.Components.Table, only: [table: 1, th: 1, tr: 1, td: 1]

      import StockWeb.Components.TableContent,
        only: [table_content: 1, content_wrapper: 1, content_item: 1]

      import StockWeb.Components.Tabs, only: [tabs: 1]
      import StockWeb.Components.TelField, only: [tel_field: 1]
      import StockWeb.Components.TextField, only: [text_field: 1]
      import StockWeb.Components.TextareaField, only: [textarea_field: 1]
      import StockWeb.Components.Toast, only: [toast: 1, toast_group: 1]
      import StockWeb.Components.ToggleField, only: [toggle_field: 1]
    end
  end
end
