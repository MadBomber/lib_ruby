# frozen_string_literal: true

class CompaniesControllerTest < ControllerTest
  def test_index
    sign_in
    co = insert_company(name: "Acme Inc")

    resp = get("/companies")

    ok resp.status == 200
    ok resp.body.include?("Acme Inc")
  end

  def test_create
    sign_in

    resp = post("/companies", {company: {name: "New Co"}})

    ok resp.status == 302
    ok flash[:notice] == "Company created"
    ok cookies["remember_token"] == "test"
  end
end
