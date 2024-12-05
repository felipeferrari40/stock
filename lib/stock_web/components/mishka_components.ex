defmodule StockWeb.Components.MishkaComponents do
  defmacro __using__(_) do
    quote do
      import StockWeb.Components.Accordion, only: [accordion: 1, native_accordion: 1]
      import StockWeb.Components.Alert, only: [flash: 1, flash_group: 1, alert: 1]
      import StockWeb.Components.Avatar, only: [avatar: 1, avatar_group: 1]
      import StockWeb.Components.Badge, only: [badge: 1]
      import StockWeb.Components.Banner, only: [banner: 1]
      import StockWeb.Components.Blockquote, only: [blockquote: 1]
      import StockWeb.Components.Breadcrumb, only: [breadcrumb: 1]

      import StockWeb.Components.Button,
        only: [button_group: 1, button: 1, input_button: 1, button_link: 1]

      import StockWeb.Components.Card,
        only: [card: 1, card_title: 1, card_media: 1, card_content: 1, card_footer: 1]

      import StockWeb.Components.Carousel, only: [carousel: 1]
      import StockWeb.Components.Chat, only: [chat: 1, chat_section: 1]
      import StockWeb.Components.CheckboxField, only: [checkbox_field: 1, group_checkbox: 1]
      import StockWeb.Components.ColorField, only: [color_field: 1]
      import StockWeb.Components.DateTimeField, only: [date_time_field: 1]
      import StockWeb.Components.DeviceMockup, only: [device_mockup: 1]
      import StockWeb.Components.Divider, only: [divider: 1, hr: 1]
      import StockWeb.Components.Drawer, only: [drawer: 1]

      import StockWeb.Components.Dropdown,
        only: [dropdown: 1, dropdown_trigger: 1, dropdown_content: 1]

      import StockWeb.Components.EmailField, only: [email_field: 1]
      import StockWeb.Components.Fieldset, only: [fieldset: 1]
      import StockWeb.Components.FileField, only: [file_field: 1]
      import StockWeb.Components.Footer, only: [footer: 1, footer_section: 1]
      import StockWeb.Components.FormWrapper, only: [form_wrapper: 1]
      import StockWeb.Components.Gallery, only: [gallery: 1, gallery_media: 1]
      import StockWeb.Components.Image, only: [image: 1]
      import StockWeb.Components.Indicator, only: [indicator: 1]
      import StockWeb.Components.InputField, only: [input_field: 1]
      import StockWeb.Components.Jumbotron, only: [jumbotron: 1]
      import StockWeb.Components.Keyboard, only: [keyboard: 1]
      import StockWeb.Components.List, only: [list: 1, li: 1, ul: 1, ol: 1, list_group: 1]
      import StockWeb.Components.MegaMenu, only: [mega_menu: 1]
      import StockWeb.Components.Menu, only: [menu: 1]
      import StockWeb.Components.Modal, only: [modal: 1]
      import StockWeb.Components.NativeSelect, only: [native_select: 1, select_option_group: 1]
      import StockWeb.Components.Navbar, only: [navbar: 1]
      import StockWeb.Components.NumberField, only: [number_field: 1]
      import StockWeb.Components.Overlay, only: [overlay: 1]
      import StockWeb.Components.Pagination, only: [pagination: 1]
      import StockWeb.Components.PasswordField, only: [password_field: 1]

      import StockWeb.Components.Popover,
        only: [popover: 1, popover_trigger: 1, popover_content: 1]

      import StockWeb.Components.Progress, only: [progress: 1, progress_section: 1]
      import StockWeb.Components.RadioField, only: [radio_field: 1]
      import StockWeb.Components.RangeField, only: [range_field: 1]
      import StockWeb.Components.Rating, only: [rating: 1]
      import StockWeb.Components.SearchField, only: [search_field: 1]
      import StockWeb.Components.Sidebar, only: [sidebar: 1]
      import StockWeb.Components.Skeleton, only: [skeleton: 1]
      import StockWeb.Components.SpeedDial, only: [speed_dial: 1]
      import StockWeb.Components.Spinner, only: [spinner: 1]
      import StockWeb.Components.Stepper, only: [stepper: 1, stepper_section: 1]
      import StockWeb.Components.Table, only: [table: 1, th: 1, tr: 1, td: 1]

      import StockWeb.Components.TableContent,
        only: [table_content: 1, content_wrapper: 1, content_item: 1]

      import StockWeb.Components.Tabs, only: [tabs: 1]
      import StockWeb.Components.TelField, only: [tel_field: 1]
      import StockWeb.Components.TextField, only: [text_field: 1]
      import StockWeb.Components.TextareaField, only: [textarea_field: 1]
      import StockWeb.Components.Timeline, only: [timeline: 1, timeline_section: 1]
      import StockWeb.Components.Toast, only: [toast: 1, toast_group: 1]
      import StockWeb.Components.ToggleField, only: [toggle_field: 1]
      import StockWeb.Components.Tooltip, only: [tooltip: 1]

      import StockWeb.Components.Typography,
        only: [
          h1: 1,
          h2: 1,
          h3: 1,
          h4: 1,
          h5: 1,
          h6: 1,
          p: 1,
          strong: 1,
          em: 1,
          dl: 1,
          dt: 1,
          dd: 1,
          figure: 1,
          figcaption: 1,
          abbr: 1,
          mark: 1,
          small: 1,
          s: 1,
          u: 1,
          cite: 1,
          del: 1
        ]

      import StockWeb.Components.UrlField, only: [url_field: 1]
      import StockWeb.Components.Video, only: [video: 1]
    end
  end
end
