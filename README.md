# README

This README contains my own notes on how the application works. Writing this down forced me to get a good understanding of what is going on, and how things work.

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...


# How the application works.

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

## Deploying to Production

Rails comes with a deployment tool called Kamal that we can use to deploy our application directly to a server. Kamal uses Docker containers to run your application and deploy with zero downtime.

By default, Rails comes with a production-ready Dockerfile that Kamal will use to build the Docker image, creating a containerized version of your application with all its dependencies and configurations. This Dockerfile uses Thruster to compress and serve assets efficiently in production.

### Prerequisites

To deploy with Kamal, you'll need:

- A server running Ubuntu LTS with 1GB RAM or more
- A Docker Hub account and access token

### Step 1: Set up Docker Hub

1. Create a Docker Hub account if you don't already have one
2. Create a new repository for your application image (e.g., "org-manager")
3. Create an access token with Read & Write permissions

### Step 2: Configure Deployment

Open `config/deploy.yml` and update it with your server details:

```yaml
# Name of your application. Used to uniquely configure containers.
service: org-manager

# Name of the container image.
image: your-dockerhub-username/org-manager

# Deploy to these servers.
servers:
  web:
    - your-server-ip-address

# Credentials for your image host.
registry:
  # Specify the registry server, if you're not using Docker Hub
  # server: registry.digitalocean.com / ghcr.io / ...
  username: your-dockerhub-username
```

To enable SSL for your application, add a domain under the `proxy` section:

```yaml
proxy:
  ssl: true
  host: app.example.com
```

Make sure your DNS record points to your server, and Kamal will use LetsEncrypt to issue an SSL certificate for the domain.

### Step 3: Deploy the Application

Export your Docker Hub access token:

```bash
export KAMAL_REGISTRY_PASSWORD=your-access-token
```

Run the setup command to configure your server and deploy your application:

```bash
bin/kamal setup
```

This will:
1. Install necessary dependencies on your server
2. Build and push the Docker image
3. Set up the container and database
4. Configure a web server with SSL if specified

### Step 4: View Your Application

Open your browser and enter your server's IP address or domain. You should see your application running.

### Step 5: Adding a User in Production

To create an admin user in production, open a production Rails console:

```bash
bin/kamal console
```

Then create a user:

```ruby
org_manager(prod)> User.create!(
  email_address: "you@example.org", 
  password: "s3cr3t", 
  password_confirmation: "s3cr3t",
  role: :admin
)
```

### Future Deployments

When you make changes to your application and want to update the production environment:

```bash
bin/kamal deploy
```

This will build a new Docker image, push it to Docker Hub, and deploy it to your server with zero downtime.