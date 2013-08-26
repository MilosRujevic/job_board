require "cuba/test"
require_relative "../../app"

prepare do
  Ohm.flush

  Company.create({ name: "Punchgirls",
          email: "punchgirls@mail.com",
          url: "http://www.punchgirls.com",
          password: "12345678" })
end

scope do
  test "should display company profile" do
    post "/login", { email: "punchgirls@mail.com",
          password: "12345678" }

    get "/profile"

    assert last_response.body["punchgirls@mail.com"]
  end
end
