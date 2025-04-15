# syntax=docker/dockerfile:1
# check=error=true

# This Dockerfile is designed for production, not development.
# docker build -t org_manager .
# docker run -d -p 8080:8080 -e SECRET_KEY_BASE=<your-secret-key> --name org_manager org_manager

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version
ARG RUBY_VERSION=3.4.2
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

# Rails app lives here
WORKDIR /rails

# Install base packages needed for runtime
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libjemalloc2 libvips sqlite3 && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Set production environment
ENV RAILS_ENV="production"
ENV BUNDLE_DEPLOYMENT="1"
ENV BUNDLE_PATH="/usr/local/bundle"
ENV BUNDLE_WITHOUT="development test"
# Set a dummy secret key base for build time
ENV SECRET_KEY_BASE=dummy_secret_key_base_for_assets_precompile_only

# --- Build Stage ---
FROM base AS build

# Install packages needed to build gems
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libyaml-dev pkg-config && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Install application gems
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# Copy application code
COPY . .

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/

# Setup database and precompile assets
RUN bundle exec rails db:setup && \
    bundle exec rails assets:precompile

# --- Final Stage ---
FROM base

# Copy built artifacts: gems, application (including the pre-built database)
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails

# Create necessary directories and set permissions
RUN mkdir -p /rails/tmp/pids /rails/tmp/sockets /rails/log && \
    groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails /rails

# Switch to the non-root user
USER 1000:1000

# Expose port 8080
EXPOSE 8080

# Start the Rails server
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "8080"]