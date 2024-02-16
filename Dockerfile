FROM python:3.11-slim-bookworm


# Set environment variables (optional)
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# makes a new folder within the container
WORKDIR /taskmanager


# Outside container -> Inside container
# contains libraries nessesary for running our app
COPY ./requirements.txt /taskmanager/


# Inside container
# Installs the python libraries
RUN  pip install -r requirements.txt

# Outside container -> Inside container
# means everything in the current directory. 
# . /AWS (Outside the container), second . /AWS (Inside the container)
COPY . /taskmanager/

# Setting environment variables They remain constant as the container is running

EXPOSE 8000

#Applying Database migrations before running servers
## commands below

# python manage.py runserver --host=127.0.0.1:8000 --port=8000
CMD ["bash", "-c", "python manage.py makemigrations && python manage.py migrate && python manage.py runserver 127.0.0.1:8000"]


# To build the image from these settings
#

# docker build --no-cache -t taskmanager:1.0 -f Dockerfile .

# To check a list of the images that have been built/are available on your machine
# docker images

# For port forwarding to make the app accessible publicly
# docker run -p 8000:[containerport] --name [new-name] [imageid/imagername]


#DEBUGGING

#For checking logs and debugging
# docker logs [containername]

#Getting terminal for a running container  
# docker exec -it [containerid] /bin/bash