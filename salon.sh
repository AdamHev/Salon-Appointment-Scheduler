#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c "

echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU() {
  # Check if an argument is passed
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  # Display the list of services in a formatted way
  SERVICES=$($PSQL "SELECT service_id, name FROM services")
  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
  
  # Check if the selected service ID exists in the database
  read SERVICE_ID_SELECTED
  HAVE_SERVICE=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  if [[ -z $HAVE_SERVICE ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?"
    return
  fi

  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  # Check if the customer exists in the database based on their phone number
  HAVE_SERVICE=$($PSQL "SELECT customer_id, name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  if [[ -z $HAVE_SERVICE ]]
  then
    # If no record exists, ask for the customer's name
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    # Insert the new customer
    INSERT_NAME=$($PSQL "INSERT INTO customers (name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    # Retrieve the new customer's ID
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  else
    # If the customer exists, extract their ID and name
    CUSTOMER_ID=$(echo $HAVE_SERVICE | cut -d '|' -f1)
    CUSTOMER_NAME=$(echo $HAVE_SERVICE | cut -d '|' -f2 | sed 's/ //g')
  fi

  echo -e "\nWhat time would you like your service, $CUSTOMER_NAME?"
  read SERVICE_TIME
  # Ensure the service time is not empty
  while [[ -z $SERVICE_TIME ]]; do
    echo -e "\nPlease enter a valid time:"
    read SERVICE_TIME
  done
  # Get the name of the selected service from the database
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED" | sed 's/ //g')
  # Insert the new appointment into the database
  INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
  # Confirmation
  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
}

MAIN_MENU
