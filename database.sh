#!/bin/bash

DATABASE_FILE="base.txt"

if [ ! -f "$DATABASE_FILE" ]; then
    touch "$DATABASE_FILE"
fi

while true; do
    if [ -z "$1" ]; then
        read -p "What do you want to do? add/search/update/delete/exit: " action
    else
        action="$1"
    fi

    case "$action" in
        add)
            while true; do
                echo "enter data"

                read -p "enter first and last name: " name
                read -p "enter city: " city
                read -p "enter phone number: " number

                if [ -z "$name" ] || [ -z "$city" ] || [ -z "$number" ]; then
                    echo "all data is required."
                    continue
                fi

                if [[ ! "$number" =~ ^[0-9]{2}\ [0-9]{3}\ [0-9]{2}\ [0-9]{2}$ ]]; then
                    echo "bad phone number format. Example: 25 433 33 33"
                    continue
                fi

                if grep -q "^$name |" "$DATABASE_FILE"; then
                    echo "user already exists."
                    continue
                fi

                echo "$name | $city | $number" >> "$DATABASE_FILE"
                echo "user added successfully."
                break
            done
            ;;

        search)
            if [ -z "$2" ]; then
                read -p "Search by name/city/phone, e.g. city=Siedlce: " query
            else
                query="$2"
            fi

            field="${query%%=*}"
            value="${query#*=}"

            case "$field" in
                name)
                    awk -F ' \\| ' -v val="$value" '$1 == val { print }' "$DATABASE_FILE"
                    ;;

                city)
                    awk -F ' \\| ' -v val="$value" '$2 == val { print }' "$DATABASE_FILE"
                    ;;

                phone)
                    awk -F ' \\| ' -v val="$value" '$3 == val { print }' "$DATABASE_FILE"
                    ;;

                *)
                    echo "Unknown field. Use: name, city or phone."
                    ;;
            esac
            ;;

        update)
            echo "update option later"
            ;;

        delete)
            echo "delete option later"
            ;;

        exit)
            echo "Bye"
            break
            ;;

        *)
            echo "Unknown action."
            ;;
    esac

    if [ -n "$1" ]; then
        break
    fi
done
