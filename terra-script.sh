#!/bin/bash

start_terra() {
  terraform fmt
  terraform apply --auto-approve
}

stop_terra() {
  terraform fmt
  terraform destroy --auto-approve
}

start_infra() {
  # echo "Creating ECRs..."
  # cd ecr
  # start_terra
  echo "Starting network..."
  cd network
  start_terra
  echo "Starting webserver..."
  cd ../webserver
  start_terra
  echo "Starting alb..."
  cd ../alb
  start_terra
}

stop_infra() {
  echo "Deleting alb..."
  cd alb
  stop_terra
  echo "Deleting webserver..."
  cd ../webserver
  stop_terra
  echo "Deleting network..."
  cd ../network
  stop_terra
  # echo "Deleting ECRs..."
  # cd ../ecr
  # stop_terra
}

echo "Select an action:"
echo "1. Start infrastructure"
echo "2. Stop infrastructure"
read -p "Enter your choice (1/2): " choice

case "$choice" in
  "1")
    start_infra
    ;;
  "2")
    stop_infra
    ;;
  *)
    echo "Invalid choice. Please select 1 or 2."
    exit 1
    ;;
esac

exit 0
