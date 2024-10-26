FROM freeradius/freeradius-server:latest

RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y freeradius freeradius-common freeradius-dhcp freeradius-postgresql freeradius-utils



# Create a startup script
# Remove these lines
# RUN mkdir -p /var/log/freeradius && \
#     touch /var/log/freeradius/radius.log && \
#     chown -R freerad:freerad /var/log/freeradius

# Modify the startup script
RUN echo '#!/bin/bash\n\
mkdir -p /var/log/freeradius\n\
touch /var/log/freeradius/radius.log\n\
chown -R freerad:freerad /var/log/freeradius\n\
freeradius -f &\n\
tail -f /var/log/freeradius/radius.log' > /start.sh && \
    chmod +x /start.sh


# Set the startup script as the entry point
CMD ["/start.sh"]
