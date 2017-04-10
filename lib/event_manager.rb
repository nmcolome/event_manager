require 'csv'
require 'sunlight/congress'
require 'erb'

Sunlight::Congress.api_key = "e179a6973728c4dd3fb1204283aaccb5"

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5,"0")[0..4]
end

def legislators_by_zipcode(zipcode)
  Sunlight::Congress::Legislator.by_zipcode(zipcode)
end

def save_thank_you_letters(id,form_letter)
  Dir.mkdir("output") unless Dir.exists?("output")

  filename = "output/thanks_#{id}.html"

  File.open(filename,'w') do |file|
    file.puts form_letter
  end
end

def clean_phone_numbers(phone_number)
  phone = phone_number.to_s.split(//).select do |char|
    ("0".."9").to_a.include?(char)
  end

  if phone.length == 10
    phone.join("")
  elsif
    phone.length == 11 && phone[0] == 1
    phone[1..9].join("")
  else
    ""
  end

end

def transf(registered_date)
  DateTime.strptime(registered_date, "%m/%d/%y %H:%M")
end

puts "EventManager initialized."

contents = CSV.open 'event_attendees.csv', headers: true, header_converters: :symbol

template_letter = File.read "form_letter.erb"
erb_template = ERB.new template_letter

  hours = []
  wkdays = []

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])
  legislators = legislators_by_zipcode(zipcode)
  phone_number = clean_phone_numbers(row[:homephone])
  # p peak_hours 
  hours << transf(row[:regdate]).hour
  wkdays << transf(row[:regdate]).strftime("%A")
  # form_letter = erb_template.result(binding)

  # save_thank_you_letters(id,form_letter)
end

peaks_h = hours.group_by { |hour| hours.count(hour) }
peaks_h.sort_by { |fr,hour| -fr}

peak_wkdays = wkdays.group_by { |wkday| wkdays.count(wkday) }
peak_wkdays.sort_by { |fr,wkday| -fr}