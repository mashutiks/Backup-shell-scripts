# Backup shell-scripts

This repository contains a set of scripts for backing up files from a specified directory when certain conditions regarding size and percentage usage are met. The scripts are written in both Bash (`backup.sh`, `tests.sh`) and Batch (`backup.bat`, `tests.bat`) formats, making them versatile for different operating systems.

## Contents

- **backup.sh**: A Bash script for archiving files from a specified directory.
- **tests.sh**: A Bash script for testing the backup functionality.
- **backup.bat**: A Batch script for archiving files from a specified directory on Windows.
- **tests.bat**: A Batch script for testing the backup functionality on Windows.

## Installation

1. Clone this repository to your local machine:
   ```bash
   git clone https://github.com/yourusername/backup-scripts.git
   cd backup-scripts
2. Make the Bash scripts executable:

bash
Копировать код
chmod +x backup.sh tests.sh
Ensure you have bc, tar, and dd installed for the Bash scripts. On Windows, ensure you have a compatible environment to run Batch scripts.

Usage
Backup Script (Bash)
To run the Bash backup script, use the following command:

bash
Копировать код
./backup.sh <path_to_folder> <max_size_in_GB> <backup_path>
<path_to_folder>: The directory you want to back up.
<max_size_in_GB>: The maximum allowed size of the directory in gigabytes.
<backup_path>: The directory where backup archives will be stored.
Example:
bash
Копировать код
./backup.sh /path/to/logs 5 /path/to/backup
Backup Script (Batch)
To run the Batch backup script, use the following command in the Windows Command Prompt:

batch
Копировать код
backup.bat <path_to_folder> <max_size_in_GB> <max_percent> <number_of_files_to_archive> <backup_path>
<path_to_folder>: The directory you want to back up.
<max_size_in_GB>: The maximum allowed size of the directory in gigabytes.
<max_percent>: The maximum percentage of directory usage allowed before backup.
<number_of_files_to_archive>: The number of oldest files to archive.
<backup_path>: The directory where backup archives will be stored.
Example:
batch
Копировать код
backup.bat C:\logs 5 70 3 C:\backup
Testing the Backup Functionality
Bash Tests
To run the tests for the Bash scripts, execute:

bash
Копировать код
./tests.sh
This will generate test files and verify the backup process.

Batch Tests
To run the tests for the Batch scripts, execute:

batch
Копировать код
tests.bat
Notes
Ensure that the backup destination has enough space for the archives.
The scripts will archive the oldest files if the directory exceeds the specified limits.
The archived files will be compressed using gzip (for Bash) or 7-Zip (for Batch).
