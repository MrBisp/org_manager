# README

This README contains my own notes on how the application works. Writing this down forced me to get a good understanding of what is going on, and how things work.

This README also documents the steps necessary to get the application up and running.

## Development Setup

* Ruby version: 3.4.2
* Database: SQLite3
* System dependencies: Docker (if running in container)

## Running Locally

You can run the application either directly or using Docker.

### Direct Setup:
1. Install Ruby 3.4.2
2. Run `bundle install`
3. Set up the database: `rails db:setup`
4. Start the server: `rails server`

### Docker Setup:
1. Build the image:
   ```bash
   docker build -t org-manager:latest .
   ```
2. Run the container:
   ```bash
   docker run -p 3000:8080 org-manager:latest
   ```
3. Access the application at http://localhost:3000

## Deployment

This application is deployed using Docker on DigitalOcean. Here's how to deploy:

### Prerequisites
- Docker Hub account
- DigitalOcean account

### Deployment Steps

1. Build and push the Docker image:
   ```bash
   docker build -t your-dockerhub-username/org-manager:latest .
   docker push your-dockerhub-username/org-manager:latest
   ```

2. Create a DigitalOcean Droplet

3. SSH into your Droplet:
   ```bash
   ssh root@your-droplet-ip
   ```

4. Pull and run the container:
   ```bash
   docker pull your-dockerhub-username/org-manager:latest
   docker run -d -p 80:8080 --restart unless-stopped your-dockerhub-username/org-manager:latest
   ```

Your application should now be accessible at http://your-droplet-ip (notice http not https).
The docker image also comes with a sqlite3 database!

## How the application works.

## New user
When a new user visits the site for the first time, we first look at config/route.rb and see `root "organizations#index"`. This means that the organizations index is used as root. Organizations index is defined in app/controllers/organizations_controller.rb.

But before any controller action runs, we have defined `include Authentication` (in the application controller /app/controllers/application_controller.rb). 

This includes /app/controllers/concerns/authentication.rb, which requires authentication `before_action :require_authentication` on all views except for actions in controllers where the before_action has been skipped using the `allow_unauthenticated_access` class method.
 
In the same file, we define the new_session_path, which is using the Rails naming conventions to points to /app/views/sessions/new.html.erb. You may notice that /app/controllers/sessions_controller.rb includes `allow_unauthenticated_access`, meaning that we can see the view. 

The server renders the clients html. In this case, it starts with app/views/layouts/application.html.erb. This includes the _navbar.html.erg partial (similar to a component in React), and the rest of the DOM, which is /app/views/sessions/new.html.erb.

## Signing in
In /app/views/sessions/new.html.erb is actually very straight forward. It simply uses the session controller - notice here the beauty of the naming conventions.

In the session controller (/app/controllers/sessions_controller.rb), we can see that it has access to methods such as start_new_session_for and User.authenticate_by. The latter of these comes from the `has_secure_password` feature, which is defined in /app/models/user.rb. This does many things such as:
- Adds password encryption automatically
- Adds authenticate_by 

The former (start_new_session_for) comes from the concern /app/controllers/concerns/authentication.rb. And with this we simply create the session and redirects to either root or the originally requested page!

## Signed in user
When a user is signed in, the root path routes to the OrganizationsController#index action. 
This action queries all organizations from the database using `Organization.all`, which Active Record translates into a SQL query. The controller then passes these organizations to the view (/app/views/organizations/index.html.erb) through the @organizations instance variable, where they are rendered as a list.

Active Record is Rails' built in Object-Relational Mapping (ORM) system, which translates between ruby objects such as classes, methods and so on, and database tables. This means that most of the time (if not all?) we don't have to worry about accessing the models in the db - it is just handled automatically.

In this case we always renders all organizations. 


### Users in an organization
If we navigate to /organizations/2/users, we are rendering what is defined in config/routes.rb. In this case the user path route is a nested route that maps to UserController#index, defined in /app/controllers/users_controller.rb. 
You may notice that have the set_organization before_action, meaning we get access to the right organization. The controller actions then only query the data from that organization.

## CSS Organization

The CSS in this application is organized into modular files for better maintainability:

- `base.css`: Reset, typography, containers, and utility classes
- `navbar.css`: Navigation styles
- `forms.css`: Form elements and authentication forms
- `buttons.css`: Button styles and action bars
- `tables.css`: Table styling
- `organizations.css`: Organization-specific components
- `users.css`: User-specific components

Files are loaded alphabetically by the asset pipeline and compiled into a single CSS file for production.

