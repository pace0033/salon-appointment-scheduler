#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -t -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

SERVICES_MENU() {
  SERVICES=$($PSQL "SELECT * FROM services")
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  read SERVICE_ID_SELECTED
  # check if service_ID is valid
  SELECTED_SERVICE=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  if [[ -z $SELECTED_SERVICE ]]
  then
    # display message
    echo -e "\nI could not find that service. What would you like today?"
    # display services again
    SERVICES_MENU
  else
    # get CUSTOMER_PHONE
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    # if no customer for phone number
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
    if [[ -z $CUSTOMER_NAME ]]
    then
      echo -e "\nI don't have a record for that phone number, what's your name?"
      # get name
      read CUSTOMER_NAME
      # insert customer into customers table
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
      # get new CUSTOMER_ID
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    fi
    FORMATTED_SERVICE=$(echo $SELECTED_SERVICE | sed 's/^ *| *$//g')
    FORMATTED_NAME=$(echo $CUSTOMER_NAME | sed 's/^ *| *$//g')
    echo -e "\nWhat time would you like your $FORMATTED_SERVICE, $FORMATTED_NAME?"

    # get the appointment time
    read SERVICE_TIME
    
    # if CUSTOMER_ID is empty
    if [[ -z $CUSTOMER_ID ]]
    then
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    fi

    # insert appointment into db
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

    # display final message
    FORMATTED_TIME=$(echo $SERVICE_TIME | sed 's/^ *| *$//g')
    echo -e "\nI have put you down for a $FORMATTED_SERVICE at $FORMATTED_TIME, $FORMATTED_NAME."
  fi
}

SERVICES_MENU