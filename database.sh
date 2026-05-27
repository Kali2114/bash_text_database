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
            search_query="$2"
	    update_query="$3"

	    search_field="${search_query%%=*}"
	    search_value="${search_query#*=}"

	    update_field="${update_query%%=*}"
	    update_value="${update_query#*=}"

	    tmp_file=$(mktemp)

	    while IFS= read -r line; do
	    	record_name=$(echo "$line" | cut -d "|" -f1 | xargs)
		record_city=$(echo "$line" | cut -d "|"	 -f2 | xargs)
		record_phone=$(echo "$line" | cut -d "|" -f3 | xargs)

		flag=false

		if [ "$search_field" = "name" ] && [ "$record_name" = "$search_value" ]; then
    		   flag=true
		elif [ "$search_field" = "city" ] && [ "$record_city" = "$search_value" ]; then
    	  	   flag=true
		elif [ "$search_field" = "phone" ] && [ "$record_phone" = "$search_value" ]; then
    		   flag=true
		fi

		if [ "$flag" = true ]; then
		   if [ "$update_field" = "name" ]; then
  		      record_name="$update_value"
		   elif [ "$update_field" = "city" ]; then
   		      record_city="$update_value"
		   elif [ "$update_field" = "phone" ]; then
    		      record_phone="$update_value"
		   fi
		   echo "$record_name | $record_city | $record_phone" >> "$tmp_file"
		else
		     echo "$line" >> "$tmp_file"
		fi
	   done < "$DATABASE_FILE"

	   mv "$tmp_file" "$DATABASE_FILE"
	   echo "record updated."
            ;;

        delete)
            delete_query="$2"

	    delete_field="${delete_query%%=*}"
            delete_value="${delete_query#*=}"

	    tmp_file=$(mktemp)

	    while IFS= read -r line; do
		record_name=$(echo "$line" | cut -d "|" -f1 | xargs)
		record_city=$(echo "$line" | cut -d "|" -f2 | xargs)
		record_phone=$(echo "$line" | cut -d "|" -f3 | xargs)

		flag=false

                if [ "$delete_field" = "name" ] && [ "$record_name" = "$delete_value" ]; then
                   flag=true
                elif [ "$delete_field" = "city" ] && [ "$record_city" = "$delete_value" ]; then
                   flag=true
                elif [ "$delete_field" = "phone" ] && [ "$record_phone" = "$delete_value" ]; then
                   flag=true
                fi
		if [ "$flag" = true ]; then
		   echo "record deleted: $line"
		   continue
		fi
	    	echo "$line" >> "$tmp_file"
	    done < "$DATABASE_FILE"
	    mv "$tmp_file" "$DATABASE_FILE"
	    echo "delete completed."
            ;;

        exit)
            echo "Bye"
            break
            ;;

        *)
            echo "unknown action."
            ;;
    esac

    if [ -n "$1" ]; then
        break
    fi
done
