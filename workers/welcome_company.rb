require_relative "../app"

Ost[:welcome_company].each do |id|
  company = Company[id]
  text = Mailer.render("welcome_company", { company: company })

  Mailer.deliver(company.email,
    "Welcome to Job Board!", text)
end