# Use an official Python runtime as a parent image
FROM python:3.12-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Set the working directory in the container
WORKDIR /app

# Install system dependencies that might be needed for some Python packages
# (e.g., for database connectors or image processing libraries)
# RUN apt-get update && apt-get install -y ...

# Copy the requirements file and install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the Django project code into the container
COPY webhost/ .

# Expose the port the app runs on
EXPOSE 8000

# Run the application using Daphne, the ASGI server
CMD ["daphne", "-b", "0.0.0.0", "-p", "8000", "webhost.asgi:application"]