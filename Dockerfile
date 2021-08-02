FROM ubuntu:latest

RUN apt-get update && apt-get -y install cron curl git

COPY github-mirror-cron /etc/cron.d/github-mirror-cron
COPY mirror-github.sh /root/mirror-github.sh

# Give execution rights on the cron job 
RUN chmod 0644 /etc/cron.d/github-mirror-cron 
 
# Apply cron job 
RUN crontab /etc/cron.d/github-mirror-cron
 
# Create the log file to be able to run tail
RUN touch /var/log/cron.log
 
# Run the command on container startup
# When cron run a job, it does not reuse your environment, not even root's. So
# for the github token to be available to the script, you have to dump the
# environment in a file and load that file in the crontab. Ludicrous.
# See https://stackoverflow.com/a/48651061/2603925
CMD env > /container.env && cron && tail -f /var/log/cron.log

