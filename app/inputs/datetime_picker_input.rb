# Public: Create a DatePicker-compatible input
# Initializes the data-value attribute to the stored value,
# so that future i18n of the control will work correctly
class DatetimePickerInput < SimpleForm::Inputs::StringInput
  def input_html_options
    { type: "text", class: 'datetimepicker', value: object.send(attribute_name).try(:strftime, "%Y/%m/%d %H:%M") }
  end
end
