FROM ruby:2.4
MAINTAINER code@space.computer

# Install apt based dependencies required to run Rails as
# well as RubyGems. As the Ruby image itself is based on a
# Debian image, we use apt-get to install those.
RUN apt-get update && apt-get install -y \
  build-essential \
  socat \
  nodejs

# Configure the main working directory. This is the base
# directory used in any further RUN, COPY, and ENTRYPOINT
# commands.
RUN mkdir -p /scripts
COPY start.sh /scripts/start.sh
RUN mkdir -p /app
WORKDIR /app

# Install dependencies
RUN gem install bundler

# Expose port 3000 to the Docker host, so we can access it
# from the outside.
EXPOSE 3000

# The main command to run when the container starts.
CMD ["/scripts/start.sh"]
