# Use an official Python runtime as a parent image
FROM python:3.12-slim

# Set the working directory in the container
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . /app

# Install any needed packages specified in requirements.txt
RUN pip install -r requirements.txt

# Install Playwright and its dependencies
RUN playwright install

# Update package lists and install wget
RUN apt update && apt install -y wget

RUN wget -O google-chrome.deb "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb" \
    && apt install ./google-chrome.deb -y \
    && rm google-chrome.deb

# Ensure chromedriver is installed
RUN apt install -y unzip \
    && wget -O /tmp/chromedriver.zip "https://storage.googleapis.com/chrome-for-testing-public/133.0.6943.53/linux64/chromedriver-linux64.zip" \
    && unzip /tmp/chromedriver.zip -d /tmp \
    && mv /tmp/chromedriver-linux64/chromedriver /usr/bin/chromedriver \
    && rm -rf /tmp/chromedriver-linux64 \
    && rm /tmp/chromedriver.zip

# Make chromedriver executable
RUN chmod +x /usr/bin/chromedriver

# Run the bot when the container launches
CMD ["bash", "run.sh"]
