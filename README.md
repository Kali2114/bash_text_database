# Bash Text Database

Simple text-based database written in Bash.

## Features

- Add records
- Search records by:
  - name
  - city
  - phone number
- Update records
- Delete records
- Input validation
- Duplicate prevention
- File-based storage

## Technologies

- Bash
- grep
- awk
- cut

## Example Usage

### Add record

```bash
./database.sh add
```

### Search record

```bash
./database.sh search city=Warszawa
```

### Update record

```bash
./database.sh update name="Jan Kowalski" city=Krakow
```

### Delete record

```bash
./database.sh delete phone="22 111 22 33"
```

## Storage Format

Records are stored in a text file:

```text
Name | City | Phone
```

## Project Purpose

Project created for Operating Systems course and Bash scripting practice.
