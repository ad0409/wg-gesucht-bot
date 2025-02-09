# Use an official Python runtime as a parent image
FROM python:3.9-slim

# Set the working directory in the container
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . /app

# Install any needed packages specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Install Playwright and its dependencies
RUN playwright install

RUN wget -O google-chrome.deb "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb" \
    && apt install ./google-chrome.deb -y

# Ensure chromedriver is installed
RUN apt-get update && apt-get install -y wget unzip \
    && wget -O /tmp/chromedriver.zip "https://chromedriver.storage.googleapis.com/$(curl -sS chromedriver.storage.googleapis.com/LATEST_RELEASE)/chromedriver_linux64.zip" \
    && unzip /tmp/chromedriver.zip -d /usr/local/bin/ \
    && rm /tmp/chromedriver.zip

# Make chromedriver executable
RUN chmod +x /usr/bin/chromedriver

# Make port 80 available to the world outside this container
EXPOSE 80

# Run the bot when the container launches
CMD ["bash", "run.sh"]