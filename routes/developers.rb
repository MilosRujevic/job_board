class Developers < Cuba
  define do
    on get, root do
      render("developer/dashboard", title: "Dashboard")
    end

    on "dashboard" do
      apply_id = session[:apply_id]
      favorite_id = session[:favorite_id]

      if apply_id
        session.delete(:apply_id)
        res.redirect "/apply/#{apply_id}"
      end

      if favorite_id
        session.delete(:favorite_id)
        res.redirect "/favorite/#{favorite_id}"
      end

      on default do
        render("developer/applications", title: "My applications")
      end
    end

    on "search" do
      run Searches
    end

    on "applications" do
      render("developer/applications", title: "My applications")
    end

    on "remove/:id" do |id|
      Application[id].delete
      session[:success] = "Application successfully removed!"
      res.redirect "/applications"
    end

    on "favorites" do
      render("developer/favorites", title: "Favorites")
    end

    on "apply/:id" do |id|
      time = Time.new.to_i
      developer = current_developer
      post = Post[id]

      params = { date: time,
        developer_id: developer.id,
        post_id: id }

      if !developer.applied?(post.id)
        application = Application.create(params)

        session[:success] = "You have successfully applied for a job!"
        res.redirect "/search"
      end

      on default do
        res.redirect "/search"
      end
    end

    on "message/:post_id/:developer_id" do |post_id, developer_id|
      applications = Post[post_id].applications

      application = Application[applications.find(:developer_id => developer_id).ids[0]]

      on param("message") do |message|
        msg = SendMessage.new(:message => message)

        on msg.valid? do
          application.update(:message => message)
        end

        on defaul do
          session[:error] = "Your message exceeds the character limit."
        end
      end

      on get, root do
        res.redirect "/search"
      end

      on(default) { not_found! }
    end

    on "note/:id" do |id|
      application = Application[id]

      on param("note") do |note|
        if note == "empty"
          note = ""
        end

        text = AddNote.new(:note => note)

        on text.valid? do
          application.update(:note => note)
        end

        on defaul do
          session[:error] = "Your message exceeds the character limit."
        end
      end

      on get, root do
        res.redirect "/search"
      end

      on(default) { not_found! }
    end

    on "favorite/:id" do |id|
      post = Post[id]
      favorites = current_user.favorites
      favorited_by = post.favorited_by

      on !favorites.member?(post) do
        favorites.add(post)
        favorited_by.add(current_user)

        res.redirect "/search"
      end

      on favorites.member?(post) do
        on session[:origin] do
          session.delete(:origin)
          res.redirect "/search"
        end

        on default do
          favorites.delete(post)
          favorited_by.delete(current_user)

          res.redirect "/search"
        end
      end

      on get, root do
        res.redirect "/favorites"
      end

      on(default) { not_found! }
    end

    on "profile" do
      on post, param("developer") do |params|
        developer = current_developer

        if !params["url"].empty? &&
          !params["url"].start_with?("http")
          params["url"] = "http://" + params["url"]
        end

        login = DeveloperLogin.new(params)

        on login.valid? do
          developer.update(params)

          session[:success] = "Your account was successfully updated!"
          res.redirect "/profile"
        end

        on default do
          session[:error] = "All fields are required and must be valid"
          render("developer/profile", title: "Edit profile")
        end
      end

      on get, root do
        render("developer/profile", title: "Edit profile")
      end

      on(default) { not_found! }
    end

    on "logout" do
      logout(Developer)

      session[:success] = "You have successfully logged out!"
      res.redirect "/"
    end

    on "about" do
      render("about", title: "About us")
    end

    on "faq" do
      render("faq", title: "FAQ")
    end

    on "contact" do
      run Contacts
    end

    on "terms" do
      render("terms", title: "Terms and Conditions")
    end

    on "privacy" do
      render("privacy", title: "Privacy Policy")
    end

    on "delete" do
      current_user.delete

      session[:success] = "You have deleted your account."
      res.redirect "/"
    end

    on(default) { not_found! }
  end
end
