# Use an official Python runtime as a parent image
FROM python:3.12-slim

# Set the working directory in the container
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY config.yaml /app/
COPY message_de.txt /app/
COPY src /app/src/
COPY requirements.txt /app/
COPY run.sh /app/
COPY wg-gesucht.py /app/

# Install any needed packages specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Install Playwright and its dependencies
RUN playwright install

# only running tests headlessly
# RUN playwright install msedge

# Update package lists and install wget
RUN apt update && apt install wget -y 

RUN wget -O google-chrome.deb "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb" \
    && apt install ./google-chrome.deb -y \
    && rm google-chrome.deb

# Ensure chromedriver is installed
RUN apt update && apt install -y wget unzip \
    && wget -O /tmp/chromedriver.zip "https://storage.googleapis.com/chrome-for-testing-public/133.0.6943.53/linux64/chromedriver-linux64.zip" \
    && unzip /tmp/chromedriver.zip -d /tmp \
    && mv /tmp/chromedriver-linux64/chromedriver /usr/bin/chromedriver \
    && rm -rf /tmp/chromedriver-linux64 \
    && rm /tmp/chromedriver.zip

# Make chromedriver executable
RUN chmod +x /usr/bin/chromedriver

# Make port 80 available to the world outside this container
# EXPOSE 80

# Run the bot when the container launches
CMD ["bash", "run.sh"]
