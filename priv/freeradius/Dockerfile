FROM freeradius/freeradius-server:latest

RUN apt-get update && apt-get upgrade -y && apt-get install freeradius freeradius-common freeradius-dhcp freeradius-postgresql freeradius-utils -y

#ADD ./rad_service_start.sh /rad_service_start.sh
#RUN ["chmod", "+x", "/rad_service_start.sh"]
#CMD ["./rad_service_start.sh"]

#CMD service radiusd start && tail -f /var/log/lastlog
