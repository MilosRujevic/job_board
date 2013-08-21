class Companies < Cuba
  define do
    on "dashboard" do
      render("company/dashboard", title: "Dashboard")
    end

    on "profile" do
      render("company/profile", title: "Profile")
    end

    on "edit" do
      on post, param("company") do |params|
        edit = EditCompanyAccount.new(params)

        if edit.password.empty?
          edit.password = current_company.crypted_password
          edit.password_confirmation = current_company.crypted_password
        end

        on edit.valid? do
          params.delete("password_confirmation")

          on current_company.email != edit.email &&
            Company.with(:email, edit.email) do
            session[:error] = "E-mail is already registered"
            render("company/edit", title: "Edit profile")
          end

          on default do
            current_company.update(params)
            session[:success] = "Your account was successfully updated!"
            res.redirect "/profile"
          end
        end

        on edit.errors[:password] == [:not_confirmed] do
          session[:error] = "Passwords don't match"
          render("company/edit", title: "Edit profile")
        end

        on default do
          session[:error] = "Name, E-mail and URL are required and must be valid"
          render("company/edit", title: "Edit profile")
        end
      end

      on default do
        render("company/edit", title: "Edit profile")
      end
    end

    on "post/new" do
      on post, param("post") do |params|
        post = PostJobOffer.new(params)

        on post.valid? do
          time = Time.new.to_i

          params[:company_id] = current_company.id
          params[:date] = time
          params[:expiration_date] = time + (30 * 24 * 60 * 60)

          Post.create(params)

          session[:success] = "You have successfully posted a job offer!"
          res.redirect "/dashboard"
        end

        on post.errors[:title] == [:not_in_range] do
          session[:error] = "Title should not exceed 80 characters"
          render("company/post/new", title: "Post job offer", post: params)
        end

        on post.errors[:description] == [:not_in_range] do
          session[:error] = "Description should not exceed 600 characters"
          render("company/post/new", title: "Post job offer", post: params)
        end

        on default do
          session[:error] = "All fields are required"
          render("company/post/new", title: "Post job offer", post: params)
        end
      end

      on default do
        render("company/post/new", title: "Post job offer", post: {})
      end
    end

    on "post/remove/:id" do |id|
      Post[id].delete
      session[:success] = "Post successfully removed!"
      res.redirect "/dashboard"
    end

    on "post/edit/:id" do |id|
      on post, param("post") do |params|
        post = PostJobOffer.new(params)

        if post.valid?
          Post[id].update(params)

          session[:success] = "Post successfully edited!"
          res.redirect "/dashboard"
        else
          session[:error] = "All fields are required"
          render("company/post/edit", title: "Edit post", id: id)
        end
      end

      on default do
        render("company/post/edit", title: "Edit post", id: id)
      end
    end

    on "post/applications/:id" do |id|
      render("company/post/applications", title: "Applicants", id: id)
    end

    on "application/remove/:id" do |id|
      application = Application[id]
      developer = application.developer
      post = Application[id].post
      company = post.company

      Malone.deliver(to: developer.email,
            cc: company.email,
            subject: "Regarding" + post.title,
            html: "<p>" + "Dear " + developer.name + "</p>" +
            "<p>We are sorry to inform you that you have not been selected for the " +
            post.title + "</p>" +
            "<p>Remember that there are a lot more jobs waiting at jobboard.com!</p>")

      Application[id].delete

      session[:success] = "Applicant successfully removed!"
      res.redirect "/dashboard"
    end

    on "application/contact/:id" do |id|
      on post, param("message") do |params|
        mail = Contact.new(params)

        if mail.valid?
          company = current_company

          Malone.deliver(to: Developer[id].email,
            cc: company.email,
            subject: params["subject"],
            html: "<p>" + params["body"] +
            "</p>" + "<a href='mailto:" +
            company.email + "?subject=RE: " +
            params["subject"] +
            "&body=" + "From " + company.name + ":\n" +
            params["body"] +
            "'>Reply to company</a>")

          session[:success] = "You just sent an e-mail to the applicant!"
          res.redirect "/dashboard"
        else
          session[:error] = "All fields are required"
          render("company/post/contact", title: "Contact developer",
            id: id, message: params)
        end

      end

      on default do
        render("company/post/contact", title: "Contact developer",
          id: id, message: {})
      end
    end

    on "posts" do
      render("posts", title: "Posts")
    end

    on "logout" do
      logout(Company)
      session[:success] = "You have successfully logged out!"
      res.redirect "/"
    end

    on default do
      render("company/dashboard", title: "Dashboard")
    end
  end
end
